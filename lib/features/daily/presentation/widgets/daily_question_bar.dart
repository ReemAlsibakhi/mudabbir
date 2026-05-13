import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
// DailyQuestionBar
// The main daily entry point: "صرفت اليوم؟"
// Supports:
//   • Text input:  "150 بقالة"
//   • Voice input: say "صرفت 150 ريال على البقالة"
//   • Auto-categorization from Arabic keywords
// ══════════════════════════════════════════════════════════

class DailyQuestionBar extends ConsumerStatefulWidget {
  final DateTime month;
  const DailyQuestionBar({super.key, required this.month});

  @override
  ConsumerState<DailyQuestionBar> createState() => _DailyQuestionBarState();
}

class _DailyQuestionBarState extends ConsumerState<DailyQuestionBar> {
  final _ctrl        = TextEditingController();
  final _speech      = SpeechToText();
  bool  _speechReady = false;
  bool  _listening   = false;
  bool  _submitting  = false;

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(() => setState(() {})); // rebuild send button
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    final available = await _speech.initialize(
      onError:  (_) => _stopListening(),
      onStatus: (status) {
        if ((status == 'done' || status == 'notListening') && mounted) {
          _stopListening();
        }
      },
    );
    if (mounted) setState(() => _speechReady = available);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _speech.cancel();
    super.dispose();
  }

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
                blurRadius: 12,
                spreadRadius: 1)]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Header row ────────────────────────────────
          Row(
            children: [
              Text(AppStrings.dailyQuestion,
                style: AppTextStyles.bodyBold),
              const Spacer(),
              if (_listening) const _PulseWave(),
            ],
          ),
          const SizedBox(height: 8),

          // ── Input row ─────────────────────────────────
          Row(
            children: [
              Expanded(child: _buildTextField()),
              const SizedBox(width: 8),
              _MicButton(
                listening:   _listening,
                available:   _speechReady,
                onTap:       _toggleListening,
              ),
              const SizedBox(width: 8),
              _SendButton(
                hasText:    _ctrl.text.trim().isNotEmpty,
                submitting: _submitting,
                onTap:      () => _submit(_ctrl.text),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField() {
    return TextField(
      controller:    _ctrl,
      textDirection: TextDirection.rtl,
      onSubmitted:   _submit,
      style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText:       AppStrings.dailyQuestionHint,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.accent, width: 1.5),
        ),
      ),
    );
  }

  // ── Voice ──────────────────────────────────────────────

  Future<void> _toggleListening() async {
    if (_listening) {
      _stopListening();
      return;
    }
    if (!_speechReady) {
      context.showSnack(AppStrings.voiceNotSupported,
        color: AppColors.warning);
      return;
    }

    setState(() { _listening = true; _ctrl.clear(); });

    await _speech.listen(
      onResult:  _onSpeechResult,
      localeId:  'ar_SA',
      listenFor: const Duration(seconds: 10),
      pauseFor:  const Duration(seconds: 3),
    );
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    if (!mounted) return;
    setState(() => _ctrl.text = result.recognizedWords);
  }

  void _stopListening() {
    _speech.stop();
    if (mounted) setState(() => _listening = false);
    // Auto-submit if text was captured by voice
    if (_ctrl.text.trim().isNotEmpty) {
      _submit(_ctrl.text);
    }
  }

  // ── Submit ─────────────────────────────────────────────

  Future<void> _submit(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _submitting) return;

    final parsed = _NaturalLanguageParser.parse(trimmed);
    if (parsed == null) {
      context.showSnack(AppStrings.voiceParseError, color: AppColors.error);
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
}

// ══════════════════════════════════════════════════════════
// Natural Language Parser
// Parses: "صرفت 150 ريال على البقالة" → amount=150, cat=food
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
    // 1. Normalize Arabic-Indic digits → ASCII
    final cleaned = text
        .replaceAllMapped(
          RegExp(r'[٠-٩]'),
          (m) => (m.group(0)!.codeUnitAt(0) - 0x0660).toString(),
        )
        .replaceAll('ريال', '')
        .replaceAll('رس', '')
        .replaceAll('SAR', '')
        .replaceAll('SR', '');

    // 2. Extract first number (the amount)
    final numMatch = RegExp(r'\d+(?:\.\d+)?').firstMatch(cleaned);
    if (numMatch == null) return null;

    final amount = double.tryParse(numMatch.group(0)!);
    if (amount == null || amount <= 0) return null;

    // 3. Detect category from Arabic keywords
    final lower      = text;
    final categoryId = _detectCategory(lower);

    // 4. Build description from remaining text
    final desc = cleaned
        .replaceFirst(numMatch.group(0)!, '')
        .replaceAll(RegExp(r'صرفت|على|في|من|بـ?|ال'), '')
        .trim();

    return _ParseResult(
      amount:      amount,
      categoryId:  categoryId,
      description: desc,
    );
  }

  static String _detectCategory(String text) {
    if (_containsAny(text, ['مطعم','وجبة','كافيه','قهوة','شاورما',
        'برجر','بيتزا','فطور','غداء','عشاء','أكل'])) return 'restaurants';
    if (_containsAny(text, ['بقالة','جرير','لولو','كارفور','بنده',
        'هايبر','سوبر','تمور','خضار','فواكه'])) return 'food';
    if (_containsAny(text, ['بنزين','وقود','تاكسي','أوبر','كريم',
        'باص','مواصلات','سيارة','توصيل'])) return 'transport';
    if (_containsAny(text, ['دواء','صيدلية','دكتور','مستشفى',
        'كلينك','طبيب','حجز','علاج'])) return 'health';
    if (_containsAny(text, ['ملابس','تسوق','مول','شوبينج',
        'هدية','أمازون','نون','زارا'])) return 'shopping';
    if (_containsAny(text, ['فاتورة','كهرباء','ماء','انترنت',
        'هاتف','اشتراك','ايجار','تلفون'])) return 'utilities';
    return 'other';
  }

  static bool _containsAny(String text, List<String> keywords) =>
      keywords.any(text.contains);
}

// ══════════════════════════════════════════════════════════
// Sub-widgets
// ══════════════════════════════════════════════════════════

class _MicButton extends StatelessWidget {
  final bool listening, available;
  final VoidCallback onTap;
  const _MicButton({
    required this.listening,
    required this.available,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
            listening ? '⏹️' : (available ? '🎤' : '🔇'),
            style: const TextStyle(fontSize: 18)),
        ),
      ),
    );
  }
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
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (hasText && !submitting) ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44, height: 44,
        decoration: BoxDecoration(
          gradient: hasText && !submitting ? AppColors.primary : null,
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
}

// Animated pulse wave shown while listening
class _PulseWave extends StatefulWidget {
  const _PulseWave();

  @override
  State<_PulseWave> createState() => _PulseWaveState();
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
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(3, (i) {
          final h = 8.0 + i * 5.0;
          return Container(
            width:  3,
            height: h * _anim.value,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color:        AppColors.accent,
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }),
      ),
    );
  }
}
