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
// VoiceAddSheet
//
// يفتح مباشرة ويبدأ الاستماع — بدون ضغطة إضافية.
// المستخدم يضغط 🎤 مرة واحدة فقط.
//
// States:
//   requesting → asking permission
//   listening  → mic active, showing transcript
//   detected   → amount + category found, confirm/edit
//   submitting → saving to Hive
//   error      → something went wrong
// ══════════════════════════════════════════════════════════

enum _VoiceState { requesting, listening, detected, submitting, error }

class VoiceAddSheet extends ConsumerStatefulWidget {
  final DateTime month;
  const VoiceAddSheet({super.key, required this.month});

  // ── Static helper to open the sheet ───────────────────
  static Future<void> show(BuildContext context, DateTime month) =>
      showModalBottomSheet(
        context:            context,
        isScrollControlled: true,
        backgroundColor:    Colors.transparent,
        isDismissible:      true,
        builder:            (_) => VoiceAddSheet(month: month),
      );

  @override
  ConsumerState<VoiceAddSheet> createState() => _VoiceAddSheetState();
}

class _VoiceAddSheetState extends ConsumerState<VoiceAddSheet>
    with SingleTickerProviderStateMixin {

  // ── Speech ────────────────────────────────────────────
  final _speech    = SpeechToText();
  _VoiceState      _state = _VoiceState.requesting;
  String           _transcript = '';

  // ── Detected result ───────────────────────────────────
  double?          _amount;
  String           _categoryId = 'other';
  String           _description = '';

  // ── Edit controllers (shown after detection) ──────────
  late final TextEditingController _amtCtrl;

  // ── Animation ─────────────────────────────────────────
  late final AnimationController _pulseCtrl;
  late final Animation<double>   _pulseAnim;

  @override
  void initState() {
    super.initState();
    _amtCtrl = TextEditingController();

    _pulseCtrl = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    // Start listening immediately after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  @override
  void dispose() {
    _amtCtrl.dispose();
    _pulseCtrl.dispose();
    _speech.cancel();
    super.dispose();
  }

  // ══════════════════════════════════════════════════════
  // VOICE LOGIC
  // ══════════════════════════════════════════════════════

  Future<void> _start() async {
    // 1. Request permissions
    setState(() => _state = _VoiceState.requesting);

    final micOk    = await Permission.microphone.request();
    final speechOk = await Permission.speech.request();

    if (!mounted) return;

    if (!micOk.isGranted || !speechOk.isGranted) {
      setState(() => _state = _VoiceState.error);
      _transcript = AppStrings.voicePermissionDenied;
      return;
    }

    // 2. Initialize
    final ready = await _speech.initialize(
      onError: (e) {
        if (mounted) {
          setState(() {
            _state      = _VoiceState.error;
            _transcript = '${AppStrings.voiceError}: ${e.errorMsg}';
          });
        }
      },
    );

    if (!mounted) return;
    if (!ready) {
      setState(() {
        _state      = _VoiceState.error;
        _transcript = AppStrings.voiceNotSupported;
      });
      return;
    }

    // 3. Start listening immediately
    setState(() {
      _state      = _VoiceState.listening;
      _transcript = '';
    });

    await _speech.listen(
      onResult:  _onResult,
      localeId:  'ar_SA',
      listenFor: const Duration(seconds: 15),
      pauseFor:  const Duration(seconds: 2),
      listenOptions: SpeechListenOptions(
        cancelOnError:   true,
        partialResults:  true,
        autoPunctuation: false,
      ),
    );
  }

  void _onResult(SpeechRecognitionResult result) {
    if (!mounted) return;
    setState(() => _transcript = result.recognizedWords);

    if (result.finalResult) {
      _speech.stop();
      _parse(result.recognizedWords);
    }
  }

  void _parse(String text) {
    if (text.trim().isEmpty) {
      setState(() {
        _state      = _VoiceState.error;
        _transcript = 'لم أسمع شيئاً — حاول مرة أخرى';
      });
      return;
    }

    // Normalize digits
    final normalized = text
        .replaceAllMapped(
          RegExp(r'[٠-٩]'),
          (m) => (m.group(0)!.codeUnitAt(0) - 0x0660).toString())
        .replaceAll(RegExp(r'ريال|رس|SAR|SR\b'), '')
        .trim();

    // Extract amount
    final match = RegExp(r'\d+(?:\.\d+)?').firstMatch(normalized);
    if (match == null) {
      setState(() {
        _state      = _VoiceState.error;
        _transcript = 'لم أجد مبلغاً — قل مثلاً: صرفت 50 مطعم';
      });
      return;
    }

    final amount = double.tryParse(match.group(0)!);
    if (amount == null || amount <= 0) {
      setState(() {
        _state      = _VoiceState.error;
        _transcript = AppStrings.voiceParseError;
      });
      return;
    }

    // Detect category
    final catId = _detectCategory(text);
    final desc  = normalized
        .replaceFirst(match.group(0)!, '')
        .replaceAll(RegExp(r'صرفت|على|في|من|بـ?|ال'), '')
        .trim();

    setState(() {
      _state       = _VoiceState.detected;
      _amount      = amount;
      _categoryId  = catId;
      _description = desc;
      _amtCtrl.text = amount.toStringAsFixed(0);
    });
  }

  static String _detectCategory(String text) {
    bool has(List<String> kw) => kw.any(text.contains);
    if (has(['مطعم','وجبة','كافيه','قهوة','شاورما','برجر','بيتزا','أكل']))
      return 'restaurants';
    if (has(['بقالة','جرير','لولو','كارفور','بنده','هايبر','سوبر']))
      return 'food';
    if (has(['بنزين','وقود','تاكسي','أوبر','كريم','باص','مواصلات']))
      return 'transport';
    if (has(['دواء','صيدلية','دكتور','مستشفى','طبيب','علاج']))
      return 'health';
    if (has(['ملابس','تسوق','مول','هدية','أمازون','نون']))
      return 'shopping';
    if (has(['فاتورة','كهرباء','ماء','انترنت','هاتف','اشتراك']))
      return 'utilities';
    return 'other';
  }

  Future<void> _confirm() async {
    final amount = double.tryParse(_amtCtrl.text.trim());
    if (amount == null || amount <= 0) return;

    setState(() => _state = _VoiceState.submitting);

    final cat   = getCategoryById(_categoryId);
    final error = await ref.read(dailyActionsProvider).addExpenseAndLog(
      AddExpenseParams(
        categoryId: _categoryId,
        name:       _description.isNotEmpty ? _description : cat.nameAr,
        amountRaw:  amount.toString(),
        date:       DateTime.now(),
      ),
    );

    if (!mounted) return;

    if (error == null) {
      Navigator.pop(context);
      context.showSnack(
        '${AppStrings.voiceAddedPre}${amount.toStringAsFixed(0)} '
        '${AppStrings.voiceAddedMid}${cat.nameAr}',
        color: AppColors.success);
    } else {
      setState(() {
        _state      = _VoiceState.error;
        _transcript = error;
      });
    }
  }

  // ══════════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color:        AppColors.surface1,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      child: switch (_state) {
        _VoiceState.requesting  => _buildRequesting(),
        _VoiceState.listening   => _buildListening(),
        _VoiceState.detected    => _buildDetected(),
        _VoiceState.submitting  => _buildSubmitting(),
        _VoiceState.error       => _buildError(),
      },
    );
  }

  // ── Requesting permission ──────────────────────────────
  Widget _buildRequesting() => _CenteredColumn(children: [
    const Text('🎤', style: TextStyle(fontSize: 56)),
    const SizedBox(height: 12),
    Text('جاري طلب الإذن...', style: AppTextStyles.title),
    const SizedBox(height: 8),
    const CircularProgressIndicator(color: AppColors.accentAlt),
  ]);

  // ── Listening ──────────────────────────────────────────
  Widget _buildListening() => _CenteredColumn(children: [
    // Animated mic
    AnimatedBuilder(
      animation: _pulseAnim,
      builder: (_, __) => Container(
        width:  90 * _pulseAnim.value,
        height: 90 * _pulseAnim.value,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.accent.withOpacity(0.15 * _pulseAnim.value),
        ),
        child: const Center(
          child: Text('🎤', style: TextStyle(fontSize: 44))),
      ),
    ),
    const SizedBox(height: 20),
    Text('أنا أسمعك...', style: AppTextStyles.headline2),
    const SizedBox(height: 8),
    Text('قل مثلاً: صرفت 50 مطعم',
      style: AppTextStyles.body.copyWith(color: AppColors.textTertiary)),
    const SizedBox(height: 20),
    // Live transcript
    if (_transcript.isNotEmpty)
      Container(
        width:   double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color:        AppColors.surface2,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(_transcript,
          textAlign: TextAlign.center,
          style: AppTextStyles.body.copyWith(color: AppColors.textPrimary)),
      ),
    const SizedBox(height: 20),
    // Stop button
    GestureDetector(
      onTap: () { _speech.stop(); _parse(_transcript); },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
        decoration: BoxDecoration(
          color:        AppColors.surface2,
          borderRadius: BorderRadius.circular(12),
          border:       Border.all(color: AppColors.border),
        ),
        child: Text(AppStrings.voiceStop,
          style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
      ),
    ),
  ]);

  // ── Amount + category detected ─────────────────────────
  Widget _buildDetected() {
    final cat = getCategoryById(_categoryId);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(child: Text('✅', style: const TextStyle(fontSize: 44))),
        const SizedBox(height: 12),
        Center(child: Text(AppStrings.voiceDetectedTitle,
          style: AppTextStyles.headline2)),
        const SizedBox(height: 20),

        // Amount field
        TextField(
          controller:    _amtCtrl,
          textDirection: TextDirection.rtl,
          keyboardType:  TextInputType.number,
          textAlign:     TextAlign.center,
          style: AppTextStyles.display.copyWith(
            color: AppColors.accentAlt, fontSize: 36),
          decoration: InputDecoration(labelText: AppStrings.amountLabel),
        ),
        const SizedBox(height: 14),

        // Category chips
        Wrap(
          spacing: 8, runSpacing: 8,
          alignment: WrapAlignment.center,
          children: ['food','restaurants','transport','health','shopping','other']
              .map((id) {
            final c   = getCategoryById(id);
            final sel = _categoryId == id;
            return GestureDetector(
              onTap: () => setState(() => _categoryId = id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color:        sel
                      ? AppColors.accent.withOpacity(0.14)
                      : AppColors.surface2,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: sel ? AppColors.accent : AppColors.border,
                    width: sel ? 1.5 : 1),
                ),
                child: Text('${c.icon} ${c.nameAr}',
                  style: AppTextStyles.caption.copyWith(
                    color:      sel ? AppColors.accentAlt : AppColors.textSecondary,
                    fontWeight: sel ? FontWeight.w700 : FontWeight.w400)),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),

        // Confirm
        GestureDetector(
          onTap: _confirm,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              gradient:     AppColors.primary,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(
                color:      AppColors.accent.withOpacity(0.3),
                blurRadius: 12, offset: const Offset(0, 4))],
            ),
            child: Center(child: Text(AppStrings.voiceConfirmBtn,
              style: AppTextStyles.button)),
          ),
        ),
        const SizedBox(height: 10),
        // Try again
        GestureDetector(
          onTap: _start,
          child: Center(child: Text(AppStrings.voiceRetry,
            style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary))),
        ),
      ],
    );
  }

  // ── Submitting ────────────────────────────────────────
  Widget _buildSubmitting() => _CenteredColumn(children: [
    const CircularProgressIndicator(color: AppColors.accentAlt),
    const SizedBox(height: 16),
    Text(AppStrings.loading, style: AppTextStyles.body),
  ]);

  // ── Error ─────────────────────────────────────────────
  Widget _buildError() => _CenteredColumn(children: [
    const Text('⚠️', style: TextStyle(fontSize: 48)),
    const SizedBox(height: 12),
    Text(_transcript,
      style: AppTextStyles.body.copyWith(color: AppColors.error),
      textAlign: TextAlign.center),
    const SizedBox(height: 20),
    GestureDetector(
      onTap: _start,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          gradient:     AppColors.primary,
          borderRadius: BorderRadius.circular(12)),
        child: Text(AppStrings.voiceTryAgain, style: AppTextStyles.button),
      ),
    ),
    const SizedBox(height: 10),
    GestureDetector(
      onTap: () {
        Navigator.pop(context);
        openAppSettings();
      },
      child: Text(AppStrings.voiceOpenSettings,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.textTertiary,
          decoration: TextDecoration.underline)),
    ),
  ]);
}

// ── Helper widget ─────────────────────────────────────────
class _CenteredColumn extends StatelessWidget {
  final List<Widget> children;
  const _CenteredColumn({required this.children});

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [const SizedBox(height: 8), ...children, const SizedBox(height: 8)],
  );
}
