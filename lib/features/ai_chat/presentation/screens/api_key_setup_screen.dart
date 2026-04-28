import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/ui/widgets/mud_gradient_button.dart';
import '../providers/chat_notifier.dart';

class ApiKeySetupScreen extends ConsumerStatefulWidget {
  /// fromChat: opened from chat AppBar key icon — show back nav
  /// embedded: rendered inside another scroll view (no Scaffold)
  final bool fromChat;
  final bool embedded;

  const ApiKeySetupScreen({
    super.key,
    this.fromChat = false,
    this.embedded = false,
  });

  @override
  ConsumerState<ApiKeySetupScreen> createState() => _State();
}

class _State extends ConsumerState<ApiKeySetupScreen> {
  final _ctrl    = TextEditingController();
  bool  _obscure = true;
  bool  _saving  = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _ctrl.text = ref.read(apiKeyProvider);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  Widget _buildBody() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // ── Input field ───────────────────────────────
      Text('أدخل مفتاح API',
        style: AppTextStyles.bodyBold),
      const SizedBox(height: 8),
      TextField(
        controller:    _ctrl,
        obscureText:   _obscure,
        // API keys are always LTR format (sk-ant-...)
        textDirection: TextDirection.ltr, // intentional: API keys are always LTR format
        style: AppTextStyles.body.copyWith(
          color:      AppColors.textPrimary,
          letterSpacing: 0.5,
          fontSize:   13,
        ),
        onChanged: (_) {
          if (_error != null) setState(() => _error = null);
        },
        decoration: InputDecoration(
          hintText:  'sk-ant-api...',
          hintStyle: AppTextStyles.body.copyWith(
            color: AppColors.textTertiary, fontSize: 13),
          errorText: _error,
          suffixIcon: IconButton(
            icon: Icon(
              _obscure
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
              color: AppColors.textTertiary, size: 20),
            onPressed: () => setState(() => _obscure = !_obscure),
          ),
        ),
      ),
      const SizedBox(height: 6),

      // Privacy note
      Row(
        children: [
          const Icon(Icons.lock_outline_rounded,
            size: 13, color: AppColors.success),
          const SizedBox(width: 5),
          Text('يُحفظ على هاتفك فقط — لا يُرفع لأي مكان',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.success)),
        ],
      ),
      const SizedBox(height: 16),

      // Save button
      MudGradientButton(
        label:   _hasExisting ? '💾 تحديث المفتاح' : '🔑 حفظ والبدء',
        onTap:   _save,
        loading: _saving,
      ),

      // Delete button (only if key exists)
      if (_hasExisting) ...[
        const SizedBox(height: 10),
        GestureDetector(
          onTap: _clear,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.07),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.error.withOpacity(0.2)),
            ),
            child: Text('🗑️ حذف المفتاح',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyBold.copyWith(
                color: AppColors.error)),
          ),
        ),
      ],
    ],
  );

  bool get _hasExisting => ref.read(apiKeyProvider).isNotEmpty;

  @override
  Widget build(BuildContext context) {
    // Embedded mode — just the form, no Scaffold
    if (widget.embedded) return _buildBody();

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
            color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('مفتاح Claude API', style: AppTextStyles.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // How-to box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.07),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.accent.withOpacity(0.15)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('كيف تحصل على المفتاح؟',
                    style: AppTextStyles.bodyBold.copyWith(
                      color: AppColors.accentAlt)),
                  const SizedBox(height: 8),
                  ...[
                    '١. افتح: console.anthropic.com',
                    '٢. سجّل دخول أو أنشئ حساباً',
                    '٣. API Keys ← Create Key',
                    '٤. انسخ المفتاح والصقه أدناه',
                  ].map((s) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(s, style: AppTextStyles.body),
                  )),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildBody(),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final key = _ctrl.text.trim();
    if (key.isEmpty) {
      setState(() => _error = 'أدخل المفتاح');
      return;
    }
    if (!key.startsWith('sk-ant-')) {
      setState(() => _error = 'المفتاح يجب أن يبدأ بـ sk-ant-');
      return;
    }
    setState(() => _saving = true);
    await ref.read(apiKeyProvider.notifier).set(key);
    if (!mounted) return;
    setState(() => _saving = false);
    // fromChat = opened from inside chat → pop back
    if (widget.fromChat) Navigator.of(context).pop();
    // embedded = will re-route automatically via ChatScreen rebuild
    // standalone = show success snack
    if (!widget.fromChat && !widget.embedded) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('✅ تم حفظ المفتاح',
          style: TextStyle(fontFamily: 'Cairo')),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  Future<void> _clear() async {
    await ref.read(apiKeyProvider.notifier).clear();
    _ctrl.clear();
    setState(() {});
  }
}
