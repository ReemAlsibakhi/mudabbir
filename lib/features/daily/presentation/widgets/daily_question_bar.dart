import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/categories.dart';
import '../../../../core/extensions/context_ext.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../expenses/domain/usecases/add_expense_usecase.dart';
import '../providers/daily_notifier.dart';

// ══════════════════════════════════════════════════════════
// DailyQuestionBar — "صرفت اليوم؟"
//
// Supports:
//   • Text: "150 بقالة"
//   • Voice: "صرفت 150 ريال على البقالة" → auto-categorize
//
// Voice lifecycle:
//   1. Request mic + speech-recognition permissions explicitly
//   2. Initialize SpeechToText (once per widget lifetime)
//   3. Listen → fill text field live
//   4. On pause/done → auto-submit if text present
// ══════════════════════════════════════════════════════════

class DailyQuestionBar extends ConsumerStatefulWidget {
  final DateTime month;
  const DailyQuestionBar({super.key, required this.month});

  @override
  ConsumerState<DailyQuestionBar> createState() => _DailyQuestionBarState();
}

class _DailyQuestionBarState extends ConsumerState<DailyQuestionBar> {

  // ── Voice ─────────────────────────────────────────────
  final _speech       = SpeechToText();
  bool  _speechReady  = false;   // set after initialize()
  bool  _listening    = false;

  // ── Text ──────────────────────────────────────────────
  final _ctrl         = TextEditingController();
  bool  _submitting   = false;

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(() => setState(() {}));
    // Don't initialize speech here — wait for user tap
    // Avoids early permission popup on app open
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _speech.cancel();
    super.dispose();
  }

  // ══════════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:  const EdgeInsets.fromLTRB(16, 4, 16, 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:        AppColors.surface1,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _listening
              ? AppColors.accent.withOpacity(0.5)
              : AppColors.border,
        ),
        boxShadow: _listening
            ? [BoxShadow(
                color:      AppColors.accent.withOpacity(0.08),
                blurRadius: 12, spreadRadius: 1)]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(children: [
            Text(AppStrings.dailyQuestion,
              style: AppTextStyles.bodyBold),
            const Spacer(),
            if (_listening) const _PulseWave(),
          ]),
          const SizedBox(height: 8),
          // Input row
          Row(children: [
            Expanded(child: _TextField(ctrl: _ctrl, onSubmit: _submit)),
            const SizedBox(width: 8),
            _MicButton(
              listening:  _listening,
              ready:      _speechReady,
              onTap:      _onMicTap,
            ),
            const SizedBox(width: 8),
            _SendButton(
              hasText:    _ctrl.text.trim().isNotEmpty,
              submitting: _submitting,
              onTap:      () => _submit(_ctrl.text),
            ),
          ]),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  // VOICE LOGIC
  // ══════════════════════════════════════════════════════

  Future<void> _onMicTap() async {
    if (_listening) {
      _stopListening();
      return;
    }
    await _startListening();
  }

  Future<void> _startListening() async {
    // Step 1 — check & request permissions explicitly
    final micOk    = await _requestPermission(Permission.microphone);
    final speechOk = await _requestPermission(Permission.speech);

    if (!micOk || !speechOk) {
      if (mounted) {
        context.showSnack(AppStrings.voicePermissionDenied,
          color: AppColors.error);
      }
      return;
    }

    // Step 2 — initialize speech engine (first call only)
    if (!_speechReady) {
      final ok = await _speech.initialize(
        onError: (e) {
          if (mounted) {
            setState(() { _listening = false; _speechReady = false; });
            context.showSnack(
              '${AppStrings.voiceError}: ${e.errorMsg}',
              color: AppColors.error);
          }
        },
        debugLogging: false,
      );

      if (!mounted) return;
      if (!ok) {
        context.showSnack(AppStrings.voiceNotSupported, color: AppColors.warning);
        return;
      }
      setState(() => _speechReady = true);
    }

    // Step 3 — start listening
    setState(() { _listening = true; _ctrl.clear(); });

    await _speech.listen(
      onResult:  _onResult,
      localeId:  'ar_SA',
      listenFor: const Duration(seconds: 15),
      pauseFor:  const Duration(seconds: 3),
      listenOptions: SpeechListenOptions(
        cancelOnError:      true,
        partialResults:     true,
        autoPunctuation:    false,
      ),
    );
  }

  void _onResult(SpeechRecognitionResult result) {
    if (!mounted) return;
    setState(() => _ctrl.text = result.recognizedWords);

    // Auto-submit on final result
    if (result.finalResult && result.recognizedWords.trim().isNotEmpty) {
      _stopListening();
    }
  }

  void _stopListening() {
    _speech.stop();
    if (!mounted) return;
    setState(() => _listening = false);

    // Submit whatever was captured
    if (_ctrl.text.trim().isNotEmpty) {
      _submit(_ctrl.text);
    }
  }

  // ══════════════════════════════════════════════════════
  // SUBMIT
  // ══════════════════════════════════════════════════════

  Future<void> _submit(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _submitting) return;

    final parsed = _NaturalLanguageParser.parse(trimmed);
    if (parsed == null) {
      if (mounted) {
        context.showSnack(AppStrings.voiceParseError, color: AppColors.error);
      }
      return;
    }

    setState(() => _submitting = true);

    final cat   = getCategoryById(parsed.categoryId);
    final error = await ref.read(dailyActionsProvider).addExpenseAndLog(
      AddExpenseParams(
        categoryId: parsed.categoryId,
        name:       parsed.description.isNotEmpty
            ? parsed.description : cat.nameAr,
        amountRaw:  parsed.amount.toString(),
        date:       DateTime.now(),
      ),
    );

    if (!mounted) return;
    setState(() { _submitting = false; _ctrl.clear(); });

    if (error == null) {
      context.showSnack(
        '${AppStrings.voiceAddedPre}'
        '${parsed.amount.toStringAsFixed(0)} '
        '${AppStrings.voiceAddedMid}'
        '${cat.nameAr}',
        color: AppColors.success);
    } else {
      context.showSnack(error, color: AppColors.error);
    }
  }

  // ══════════════════════════════════════════════════════
  // PERMISSION HELPER
  // ══════════════════════════════════════════════════════

  Future<bool> _requestPermission(Permission permission) async {
    var status = await permission.status;

    if (status.isGranted) return true;

    if (status.isPermanentlyDenied) {
      if (mounted) {
        _showOpenSettingsDialog(permission);
      }
      return false;
    }

    status = await permission.request();
    return status.isGranted;
  }

  void _showOpenSettingsDialog(Permission permission) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface2,
        title: Text(AppStrings.voicePermissionTitle,
          style: AppTextStyles.title),
        content: Text(AppStrings.voicePermissionBody,
          style: AppTextStyles.body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.cancel,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary))),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: Text(AppStrings.voiceOpenSettings,
              style: AppTextStyles.body.copyWith(
                color: AppColors.accentAlt))),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
// Natural Language Parser — pure static class
// ══════════════════════════════════════════════════════════

class _ParseResult {
  final double amount;
  final String categoryId;
  final String description;
  const _ParseResult({
    required this.amount,
    required this.categoryId,
    required this.description,
  });
}

abstract final class _NaturalLanguageParser {

  static _ParseResult? parse(String text) {
    final normalized = _normalize(text);
    final amount     = _extractAmount(normalized);
    if (amount == null) return null;

    final categoryId = _detectCategory(text);
    final description = _extractDescription(normalized, amount);

    return _ParseResult(
      amount:      amount,
      categoryId:  categoryId,
      description: description,
    );
  }

  // Arabic-Indic → ASCII, remove currency words
  static String _normalize(String text) => text
      .replaceAllMapped(
        RegExp(r'[٠-٩]'),
        (m) => (m.group(0)!.codeUnitAt(0) - 0x0660).toString(),
      )
      .replaceAll(RegExp(r'ريال|رس|SAR|SR\b'), '')
      .trim();

  static double? _extractAmount(String normalized) {
    final match = RegExp(r'\d+(?:\.\d+)?').firstMatch(normalized);
    if (match == null) return null;
    final n = double.tryParse(match.group(0)!);
    if (n == null || n <= 0 || n > 100000) return null;
    return n;
  }

  static String _detectCategory(String text) {
    if (_has(text, ['مطعم','وجبة','كافيه','قهوة','شاورما','برجر','بيتزا',
        'فطور','غداء','عشاء','أكل','طعام'])) return 'restaurants';
    if (_has(text, ['بقالة','جرير','لولو','كارفور','بنده','هايبر',
        'سوبر','تمور','خضار','فواكه','بضاعة'])) return 'food';
    if (_has(text, ['بنزين','وقود','تاكسي','أوبر','كريم','باص',
        'مواصلات','سيارة','توصيل','نقل'])) return 'transport';
    if (_has(text, ['دواء','صيدلية','دكتور','مستشفى','كلينك',
        'طبيب','حجز','علاج','طب'])) return 'health';
    if (_has(text, ['ملابس','تسوق','مول','شوبينج','هدية',
        'أمازون','نون','زارا','اتش'])) return 'shopping';
    if (_has(text, ['فاتورة','كهرباء','ماء','انترنت','هاتف',
        'اشتراك','ايجار','تلفون','موبايل'])) return 'utilities';
    return 'other';
  }

  static bool _has(String text, List<String> keywords) =>
      keywords.any(text.contains);

  static String _extractDescription(String normalized, double amount) =>
      normalized
          .replaceFirst(amount.toStringAsFixed(
              amount == amount.roundToDouble() ? 0 : 2), '')
          .replaceAll(RegExp(r'صرفت|على|في|من|بـ?|ال'), '')
          .trim();
}

// ══════════════════════════════════════════════════════════
// Sub-widgets — each has one responsibility
// ══════════════════════════════════════════════════════════

class _TextField extends StatelessWidget {
  final TextEditingController ctrl;
  final ValueChanged<String>  onSubmit;
  const _TextField({required this.ctrl, required this.onSubmit});

  @override
  Widget build(BuildContext context) => TextField(
    controller:    ctrl,
    textDirection: TextDirection.rtl,
    onSubmitted:   onSubmit,
    style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
    decoration: InputDecoration(
      hintText:       AppStrings.dailyQuestionHint,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide:   BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide:   BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide:   BorderSide(color: AppColors.accent, width: 1.5),
      ),
    ),
  );
}

class _MicButton extends StatelessWidget {
  final bool listening, ready;
  final VoidCallback onTap;
  const _MicButton({
    required this.listening,
    required this.ready,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 44, height: 44,
      decoration: BoxDecoration(
        color: listening
            ? AppColors.accent.withOpacity(0.15)
            : AppColors.surface2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: listening ? AppColors.accent : AppColors.border),
      ),
      child: Center(
        child: Text(
          listening ? '⏹️' : '🎤',
          style: const TextStyle(fontSize: 18)),
      ),
    ),
  );
}

class _SendButton extends StatelessWidget {
  final bool hasText, submitting;
  final VoidCallback onTap;
  const _SendButton({
    required this.hasText,
    required this.submitting,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: (hasText && !submitting) ? onTap : null,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 44, height: 44,
      decoration: BoxDecoration(
        gradient: (hasText && !submitting) ? AppColors.primary : null,
        color:    (!hasText || submitting) ? AppColors.surface2 : null,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: submitting
            ? const SizedBox(
                width: 18, height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.white))
            : Icon(
                Icons.check_rounded,
                size:  20,
                color: hasText ? Colors.white : AppColors.textTertiary),
      ),
    ),
  );
}

// Animated pulse wave shown while listening
class _PulseWave extends StatefulWidget {
  const _PulseWave();
  @override State<_PulseWave> createState() => _PulseWaveState();
}

class _PulseWaveState extends State<_PulseWave>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double>   _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.4, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _anim,
    builder: (_, __) => Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(3, (i) => Container(
        width:  3,
        height: (8.0 + i * 5.0) * _anim.value,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color:        AppColors.accent,
          borderRadius: BorderRadius.circular(2),
        ),
      )),
    ),
  );
}
