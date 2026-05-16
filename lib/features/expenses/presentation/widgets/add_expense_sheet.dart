import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/categories.dart';
import '../../../../core/extensions/context_ext.dart';
import '../../../../core/extensions/datetime_ext.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/ui/widgets/mud_gradient_button.dart';
import '../../domain/usecases/add_expense_usecase.dart';
import '../providers/expenses_notifier.dart';

// ══════════════════════════════════════════════════════════
// AddExpenseSheet
//
// Bottom sheet for adding a variable expense.
// Voice input: tap 🎤 → speak amount + category
// Auto-parses Arabic: "صرفت 150 على المطعم" → fills fields
// ══════════════════════════════════════════════════════════

class AddExpenseSheet extends StatefulWidget {
  final DateTime month;
  final WidgetRef ref;
  const AddExpenseSheet({super.key, required this.month, required this.ref});

  static Future<void> show(BuildContext context, DateTime month, WidgetRef ref) =>
      showModalBottomSheet(
        context:            context,
        isScrollControlled: true,
        builder: (_) => AddExpenseSheet(month: month, ref: ref),
      );

  @override
  State<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<AddExpenseSheet> {

  // ── Form ──────────────────────────────────────────────
  final _formKey    = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _nameCtrl   = TextEditingController();
  String   _catId   = 'food';
  DateTime _date    = DateTime.now();
  bool     _loading = false;
  String?  _error;

  // ── Voice ─────────────────────────────────────────────
  final _speech      = SpeechToText();
  bool  _speechReady = false;
  bool  _listening   = false;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _nameCtrl.dispose();
    _speech.cancel();
    super.dispose();
  }

  // ══════════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(
      left: 16, right: 16, top: 8,
      bottom: MediaQuery.of(context).viewInsets.bottom + 24,
    ),
    child: Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Header with voice button ─────────────────
          Row(
            children: [
              Expanded(
                child: Center(
                  child: Text(AppStrings.addExpenseTitle2,
                    style: AppTextStyles.title),
                ),
              ),
              // 🎤 Voice button — always visible here
              _VoiceButton(
                listening:  _listening,
                ready:      _speechReady,
                onTap:      _onMicTap,
              ),
            ],
          ),

          // Voice listening banner
          if (_listening)
            Container(
              margin:  const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color:        AppColors.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border:       Border.all(
                  color: AppColors.accent.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const _PulseWave(),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      AppStrings.voiceListening,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.accentAlt),
                    ),
                  ),
                  GestureDetector(
                    onTap: _stopListening,
                    child: const Icon(Icons.stop_circle_outlined,
                      color: AppColors.accentAlt, size: 20),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 14),

          // ── Category ──────────────────────────────────
          DropdownButtonFormField<String>(
            value:        _catId,
            dropdownColor: AppColors.surface2,
            decoration:   const InputDecoration(
              labelText: AppStrings.categoryLabel),
            items: variableCategories.map((c) => DropdownMenuItem(
              value: c.id,
              child: Text('${c.icon} ${c.nameAr}',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textPrimary)),
            )).toList(),
            onChanged: (v) => setState(() => _catId = v ?? 'food'),
          ),
          const SizedBox(height: 12),

          // ── Date ──────────────────────────────────────
          GestureDetector(
            onTap: _pickDate,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color:        AppColors.surface2,
                borderRadius: BorderRadius.circular(12),
                border:       Border.all(color: AppColors.border),
              ),
              child: Row(children: [
                const Text('📅 ', style: TextStyle(fontSize: 16)),
                Text(_date.dayFullAr,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary)),
                const Spacer(),
                const Icon(Icons.arrow_drop_down,
                  color: AppColors.textTertiary),
              ]),
            ),
          ),
          const SizedBox(height: 12),

          // ── Amount ────────────────────────────────────
          TextFormField(
            controller:   _amountCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textDirection: TextDirection.rtl,
            autofocus:    true,
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                RegExp(r'[\d٠-٩.,٫]')),
            ],
            validator: Validators.amount,
            decoration: const InputDecoration(
              labelText: AppStrings.amountLabel,
              hintText:  '0'),
            style: AppTextStyles.body.copyWith(
              color: AppColors.textPrimary, fontSize: 16),
          ),
          const SizedBox(height: 12),

          // ── Description ───────────────────────────────
          TextFormField(
            controller:    _nameCtrl,
            textDirection: TextDirection.rtl,
            decoration: const InputDecoration(
              labelText: AppStrings.descOptional,
              hintText:  AppStrings.descExample),
            style: AppTextStyles.body.copyWith(
              color: AppColors.textPrimary),
          ),

          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.error)),
          ],
          const SizedBox(height: 16),

          MudGradientButton(
            label:   AppStrings.add,
            onTap:   _submit,
            loading: _loading,
          ),
        ],
      ),
    ),
  );

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
    // 1. Request permissions
    final micOk    = await _requestPermission(Permission.microphone);
    final speechOk = await _requestPermission(Permission.speech);

    if (!micOk || !speechOk) {
      if (mounted) {
        context.showSnack(AppStrings.voicePermissionDenied,
          color: AppColors.error);
      }
      return;
    }

    // 2. Initialize (once per instance)
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
        context.showSnack(AppStrings.voiceNotSupported,
          color: AppColors.warning);
        return;
      }
      setState(() => _speechReady = true);
    }

    // 3. Start listening
    setState(() => _listening = true);

    await _speech.listen(
      onResult:  _onResult,
      localeId:  'ar_SA',
      listenFor: const Duration(seconds: 15),
      pauseFor:  const Duration(seconds: 3),
      listenOptions: SpeechListenOptions(
        cancelOnError:  true,
        partialResults: true,
      ),
    );
  }

  void _onResult(SpeechRecognitionResult result) {
    if (!mounted) return;
    final text = result.recognizedWords.trim();
    if (text.isEmpty) return;

    // Parse and fill fields automatically
    _parseAndFill(text);

    // Auto-stop on final result
    if (result.finalResult) _stopListening();
  }

  void _stopListening() {
    _speech.stop();
    if (mounted) setState(() => _listening = false);
  }

  // Parse "صرفت 150 ريال على البقالة" → fill amount + category
  void _parseAndFill(String text) {
    // Normalize Arabic-Indic digits
    final normalized = text
        .replaceAllMapped(
          RegExp(r'[٠-٩]'),
          (m) => (m.group(0)!.codeUnitAt(0) - 0x0660).toString(),
        )
        .replaceAll(RegExp(r'ريال|رس|SAR|SR\b'), '');

    // Extract amount
    final match = RegExp(r'\d+(?:\.\d+)?').firstMatch(normalized);
    if (match != null) {
      final amount = double.tryParse(match.group(0)!);
      if (amount != null && amount > 0) {
        _amountCtrl.text = amount.toStringAsFixed(
            amount == amount.roundToDouble() ? 0 : 2);
      }
    }

    // Detect category
    final detected = _detectCategory(text);
    final desc     = normalized
        .replaceFirst(match?.group(0) ?? '', '')
        .replaceAll(RegExp(r'صرفت|على|في|من|بـ?|ال'), '')
        .trim();

    setState(() {
      _catId = detected;
      if (desc.isNotEmpty) _nameCtrl.text = desc;
    });
  }

  String _detectCategory(String text) {
    bool has(List<String> kws) => kws.any(text.contains);
    if (has(['مطعم','وجبة','كافيه','قهوة','أكل','فطور','غداء','عشاء']))
      return 'restaurants';
    if (has(['بقالة','لولو','كارفور','بنده','هايبر','سوبر','خضار']))
      return 'food';
    if (has(['بنزين','وقود','تاكسي','أوبر','كريم','باص','سيارة']))
      return 'transport';
    if (has(['دواء','صيدلية','دكتور','مستشفى','طبيب','علاج']))
      return 'health';
    if (has(['ملابس','تسوق','مول','هدية','أمازون','نون']))
      return 'shopping';
    if (has(['فاتورة','كهرباء','ماء','انترنت','هاتف','اشتراك']))
      return 'utilities';
    return 'other';
  }

  // ══════════════════════════════════════════════════════
  // FORM HELPERS
  // ══════════════════════════════════════════════════════

  Future<void> _pickDate() async {
    final now  = DateTime.now();
    final from = now.subtract(const Duration(days: 90));
    final pick = await showDatePicker(
      context:     context,
      initialDate: _date,
      firstDate:   from,
      lastDate:    now,
    );
    if (pick != null) setState(() => _date = pick);
  }

  Future<void> _submit() async {
    setState(() => _error = null);
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _loading = true);
    final error = await widget.ref
        .read(expensesNotifierProvider(widget.month.monthKey).notifier)
        .addExpense(AddExpenseParams(
          categoryId: _catId,
          name:       _nameCtrl.text.trim(),
          amountRaw:  _amountCtrl.text.trim(),
          date:       _date,
        ));

    if (!mounted) return;
    setState(() => _loading = false);

    if (error != null) {
      setState(() => _error = error);
    } else {
      context.popScreen();
      context.showSnack(AppStrings.expenseAdded, color: AppColors.success);
    }
  }

  Future<bool> _requestPermission(Permission permission) async {
    var status = await permission.status;
    if (status.isGranted) return true;
    if (status.isPermanentlyDenied) {
      if (mounted) _showSettingsDialog();
      return false;
    }
    status = await permission.request();
    return status.isGranted;
  }

  void _showSettingsDialog() {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface2,
        title:   Text(AppStrings.voicePermissionTitle,
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
            onPressed: () { Navigator.pop(context); openAppSettings(); },
            child: Text(AppStrings.voiceOpenSettings,
              style: AppTextStyles.body.copyWith(
                color: AppColors.accentAlt))),
        ],
      ),
    );
  }
}

// ── Voice button ──────────────────────────────────────────
class _VoiceButton extends StatelessWidget {
  final bool listening, ready;
  final VoidCallback onTap;
  const _VoiceButton({
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
        color:        listening
            ? AppColors.accent.withOpacity(0.15)
            : AppColors.surface2,
        borderRadius: BorderRadius.circular(12),
        border:       Border.all(
          color: listening ? AppColors.accent : AppColors.border),
      ),
      child: Center(
        child: Text(
          listening ? '⏹️' : '🎤',
          style: const TextStyle(fontSize: 20)),
      ),
    ),
  );
}

// ── Pulse wave (shown while listening) ────────────────────
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
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _anim,
    builder: (_, __) => Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(3, (i) => Container(
        width:  3,
        height: (6.0 + i * 4.0) * _anim.value,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color:        AppColors.accent,
          borderRadius: BorderRadius.circular(2),
        ),
      )),
    ),
  );
}
