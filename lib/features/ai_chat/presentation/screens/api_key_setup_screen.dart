import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/ui/widgets/mud_gradient_button.dart';
import '../providers/chat_notifier.dart';

class ApiKeySetupScreen extends ConsumerStatefulWidget {
  final bool fromChat;
  const ApiKeySetupScreen({super.key, this.fromChat = false});

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
    // Pre-fill existing key
    _ctrl.text = ref.read(apiKeyProvider);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final hasKey = ref.watch(apiKeyProvider).isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        // ✅ Always show back button
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('مفتاح Claude API', style: AppTextStyles.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:        AppColors.accent.withOpacity(0.07),
                borderRadius: BorderRadius.circular(14),
                border:       Border.all(color: AppColors.accent.withOpacity(0.15)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('كيف تحصل على المفتاح؟',
                    style: AppTextStyles.bodyBold.copyWith(color: AppColors.accentAlt)),
                  const SizedBox(height: 8),
                  ...[
                    '١. اذهبي لـ console.anthropic.com',
                    '٢. سجّلي دخول أو أنشئي حساباً',
                    '٣. من API Keys → Create Key',
                    '٤. انسخي المفتاح والصقيه هنا',
                  ].map((s) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(s, style: AppTextStyles.body),
                  )),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Text('API Key', style: AppTextStyles.bodyBold),
            const SizedBox(height: 8),
            TextField(
              controller:   _ctrl,
              obscureText:  _obscure,
              textDirection: TextDirection.ltr, // intentional: API keys are always LTR format
              style: AppTextStyles.body.copyWith(
                color:      AppColors.textPrimary,
                fontFamily: 'monospace',
                fontSize:   13,
              ),
              decoration: InputDecoration(
                hintText:    'sk-ant-...',
                hintStyle:   AppTextStyles.body.copyWith(color: AppColors.textTertiary),
                suffixIcon:  IconButton(
                  icon: Icon(
                    _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    color: AppColors.textTertiary, size: 20,
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
                errorText: _error,
              ),
              onChanged: (_) { if (_error != null) setState(() => _error = null); },
            ),
            const SizedBox(height: 8),
            Text('المفتاح يُحفظ على هاتفك فقط ولا يُرفع لأي مكان',
              style: AppTextStyles.caption.copyWith(color: AppColors.success)),
            const SizedBox(height: 24),

            MudGradientButton(
              label:   hasKey ? '💾 تحديث المفتاح' : '🔑 حفظ المفتاح',
              onTap:   _save,
              loading: _saving,
            ),

            if (hasKey) ...[
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _clear,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  decoration: BoxDecoration(
                    color:        AppColors.error.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(12),
                    border:       Border.all(color: AppColors.error.withOpacity(0.2)),
                  ),
                  child: Text('🗑️ حذف المفتاح',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyBold.copyWith(color: AppColors.error)),
                ),
              ),
            ],
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
    if (mounted) {
      setState(() => _saving = false);
      if (widget.fromChat) Navigator.pop(context);
    }
  }

  Future<void> _clear() async {
    await ref.read(apiKeyProvider.notifier).clear();
    _ctrl.clear();
    if (mounted) setState(() {});
  }
}
