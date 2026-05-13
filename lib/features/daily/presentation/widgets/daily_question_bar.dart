import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/categories.dart';
import '../../../../core/extensions/context_ext.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../expenses/domain/usecases/add_expense_usecase.dart';
import '../providers/daily_notifier.dart';

// ══════════════════════════════════════════════════════════
// DailyQuestionBar — "صرفت اليوم؟" — الـ PRD المتطلب الأول
// يظهر في الجزء العلوي من شاشة اليوم
// يدعم:
//   1. إدخال نصي مباشر "150 بقالة"
//   2. إدخال صوتي "قل صرفت 150 ريال على البقالة"
//   3. تصنيف تلقائي من الكلمات المفتاحية
// ══════════════════════════════════════════════════════════

class DailyQuestionBar extends ConsumerStatefulWidget {
  final DateTime month;
  const DailyQuestionBar({super.key, required this.month});

  @override
  ConsumerState<DailyQuestionBar> createState() => _State();
}

class _State extends ConsumerState<DailyQuestionBar> {
  final _ctrl     = TextEditingController();
  final _speech   = SpeechToText();
  bool  _loading  = false;
  bool  _listening = false;
  bool  _speechReady = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    _speechReady = await _speech.initialize(
      onStatus: (s) {
        if (s == 'done' || s == 'notListening') {
          if (mounted) setState(() => _listening = false);
          if (_ctrl.text.isNotEmpty) _parseAndSubmit(_ctrl.text);
        }
      },
    );
    if (mounted) setState(() {});
  }

  @override
  void dispose() { _ctrl.dispose(); _speech.stop(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Container(
    margin:  const EdgeInsets.fromLTRB(16, 4, 16, 8),
    padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
    decoration: BoxDecoration(
      color:        AppColors.surface1,
      borderRadius: BorderRadius.circular(16),
      border:       Border.all(
        color: _listening
            ? AppColors.accent.withOpacity(0.5)
            : AppColors.border),
      boxShadow: _listening
          ? [BoxShadow(color: AppColors.accent.withOpacity(0.08),
              blurRadius: 12, spreadRadius: 1)]
          : null,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Question header
        Row(
          children: [
            Text(AppStrings.dailyQuestion,
              style: AppTextStyles.bodyBold),
            const Spacer(),
            if (_listening)
              const _PulseWave(),
          ],
        ),
        const SizedBox(height: 8),
        // Input row
        Row(
          children: [
            Expanded(
              child: TextField(
                controller:    _ctrl,
                textDirection: TextDirection.rtl,
                onSubmitted:   _parseAndSubmit,
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
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Voice button
            GestureDetector(
              onTap: _toggleListening,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: _listening
                      ? AppColors.accent.withOpacity(0.15)
                      : AppColors.surface2,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _listening ? AppColors.accent : AppColors.border),
                ),
                child: Center(
                  child: Text(
                    _listening ? '⏹️' : '🎤',
                    style: const TextStyle(fontSize: 18)),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Submit button
            GestureDetector(
              onTap: _loading ? null : () => _parseAndSubmit(_ctrl.text),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 44, height: 44,
                decoration: BoxDecoration(
                  gradient:     _ctrl.text.isEmpty ? null : AppColors.primary,
                  color:        _ctrl.text.isEmpty ? AppColors.surface2 : null,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: _loading
                      ? const SizedBox(
                          width: 16, height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.check_rounded,
                          size: 20, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );

  Future<void> _toggleListening() async {
    if (_listening) {
      await _speech.stop();
      setState(() => _listening = false);
    } else if (_speechReady) {
      setState(() { _listening = true; _ctrl.clear(); });
      await _speech.listen(
        onResult: (r) {
          if (mounted) setState(() => _ctrl.text = r.recognizedWords);
        },
        localeId: 'ar_SA',
        listenFor:     const Duration(seconds: 10),
        pauseFor:      const Duration(seconds: 3),
      );
    } else {
      context.showSnack(AppStrings.voiceNotSupported, color: AppColors.warning);
    }
  }

  Future<void> _parseAndSubmit(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    setState(() => _loading = true);

    // Parse: extract amount + category from natural language
    final parsed = _parseNaturalText(trimmed);
    if (parsed == null) {
      if (mounted) {
        context.showSnack(AppStrings.voiceParseError, color: AppColors.error);
        setState(() => _loading = false);
      }
      return;
    }

    final error = await ref.read(dailyActionsProvider).addExpenseAndLog(
      AddExpenseParams(
        categoryId: parsed.categoryId,
        name:       parsed.description.isNotEmpty
            ? parsed.description
            : getCategoryById(parsed.categoryId).nameAr,
        amountRaw:  parsed.amount.toString(),
        date:       DateTime.now(),
      ),
    );

    if (!mounted) return;
    setState(() { _loading = false; _ctrl.clear(); });
    if (error == null) {
      context.showSnack(
        '✅ ${AppStrings.voiceAddedPre}${parsed.amount.toStringAsFixed(0)} '
        '${AppStrings.voiceAddedMid}${getCategoryById(parsed.categoryId).nameAr}',
        color: AppColors.success);
    } else {
      context.showSnack(error, color: AppColors.error);
    }
  }

  // Natural language parser: "صرفت 150 ريال على البقالة"
  _ParseResult? _parseNaturalText(String text) {
    // 1. Extract amount (first number found — Arabic or Latin digits)
    final normalized = text
        .replaceAllMapped(RegExp(r'[٠-٩]'),
            (m) => (m.group(0)!.codeUnitAt(0) - 0x0660).toString())
        .replaceAll('ريال', '')
        .replaceAll('SR', '')
        .trim();

    final amountMatch = RegExp(r'\d+(?:\.\d+)?').firstMatch(normalized);
    if (amountMatch == null) return null;
    final amount = double.tryParse(amountMatch.group(0)!);
    if (amount == null || amount <= 0) return null;

    // 2. Detect category from keywords
    final lower     = text.toLowerCase();
    final categoryId = _detectCategory(lower);

    // 3. Remaining text as description
    final desc = normalized
        .replaceFirst(amountMatch.group(0)!, '')
        .replaceAll(RegExp(r'صرفت|على|في|من|ب|ال'), '')
        .trim();

    return _ParseResult(
      amount:      amount,
      categoryId:  categoryId,
      description: desc,
    );
  }

  String _detectCategory(String text) {
    if (_has(text, ['مطعم','أكل','وجبة','كافيه','قهوة','شاورما','برجر'])) return 'restaurants';
    if (_has(text, ['بقالة','جرير','لولو','كارفور','سوبر','بنده','هايبر'])) return 'food';
    if (_has(text, ['بنزين','وقود','سيارة','تاكسي','أوبر','كريم','باص'])) return 'transport';
    if (_has(text, ['دواء','صيدلية','دكتور','مستشفى','كلينك','طبيب'])) return 'health';
    if (_has(text, ['ملابس','تسوق','مول','شوبينج','هدية','أمازون'])) return 'shopping';
    if (_has(text, ['فاتورة','كهرباء','ماء','انترنت','هاتف','اشتراك'])) return 'utilities';
    return 'other';
  }

  bool _has(String text, List<String> keywords) =>
      keywords.any((k) => text.contains(k));
}

class _ParseResult {
  final double amount;
  final String categoryId, description;
  const _ParseResult({required this.amount, required this.categoryId, required this.description});
}

// Animated sound wave for listening state
class _PulseWave extends StatefulWidget {
  const _PulseWave();
  @override State<_PulseWave> createState() => _PulseWaveState();
}
class _PulseWaveState extends State<_PulseWave>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _anim;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 700))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.5, end: 1.0).animate(_c);
  }
  @override void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _anim,
    builder: (_, __) => Row(
      children: List.generate(3, (i) => Container(
        width:  3, height: 12 + i * 4.0,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color:        AppColors.accent.withOpacity(_anim.value),
          borderRadius: BorderRadius.circular(2),
        ),
      )),
    ),
  );
}
