import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/ui/widgets/mud_gradient_button.dart';
import '../providers/couple_notifier.dart';

class CoupleSetupScreen extends ConsumerStatefulWidget {
  const CoupleSetupScreen({super.key});

  @override
  ConsumerState<CoupleSetupScreen> createState() => _State();
}

class _State extends ConsumerState<CoupleSetupScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final _codeCtrl = TextEditingController();
  bool _loading   = false;
  String? _error;
  String? _createdCode;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() { _tabs.dispose(); _codeCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(coupleNotifierProvider);

    // If already active — show status screen
    if (state is CoupleActive) return _ActiveView(room: state.room);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('💑 ${AppStrings.paywallCouple}', style: AppTextStyles.title),
      ),
      body: Column(
        children: [
          // Error banner
          if (state is CoupleError)
            Container(
              color: AppColors.error.withOpacity(0.1),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(children: [
                const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 16),
                const SizedBox(width: 8),
                Expanded(child: Text((state).message,
                  style: AppTextStyles.caption.copyWith(color: AppColors.error))),
              ]),
            ),

          // Tabs
          Container(
            color: AppColors.surface1,
            child: TabBar(
              controller: _tabs,
              tabs: const [
                Tab(text: '📱 أنشئ رمزاً'),
                Tab(text: '🔗 أدخل رمز شريكك'),
              ],
              labelStyle:           AppTextStyles.bodyBold.copyWith(fontSize: 13),
              unselectedLabelStyle: AppTextStyles.body.copyWith(fontSize: 13),
              labelColor:           AppColors.accentAlt,
              unselectedLabelColor: AppColors.textTertiary,
              indicatorColor:       AppColors.accentAlt,
            ),
          ),

          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                // ── Tab 1: Create room ──────────────────────
                SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      const Text('🏠', style: TextStyle(fontSize: 56)),
                      const SizedBox(height: 16),
                      Text(AppStrings.coupleSpendingSync,
                        style: AppTextStyles.headline2),
                      const SizedBox(height: 8),
                      Text(
                        'أنشئ رمزاً وأعطه لشريكك — سيتزامن التطبيق تلقائياً',
                        style: AppTextStyles.body,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 28),

                      if (_createdCode != null) ...[
                        // QR Code
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color:        Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: QrImageView(
                            data:            _createdCode!,
                            version:         QrVersions.auto,
                            size:            180,
                            backgroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Code display
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 16),
                          decoration: BoxDecoration(
                            color:        AppColors.surface2,
                            borderRadius: BorderRadius.circular(14),
                            border:       Border.all(color: AppColors.accentAlt.withOpacity(0.3)),
                          ),
                          child: Column(
                            children: [
                              Text('رمز الربط',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textSecondary)),
                              const SizedBox(height: 6),
                              Text(
                                _createdCode!.split('').join(' '),
                                style: AppTextStyles.headline2.copyWith(
                                  fontSize: 32,
                                  letterSpacing: 6,
                                  color: AppColors.accentAlt,
                                  fontFeatures: [const FontFeature.tabularFigures()],
                                ),
                              ),
                              const SizedBox(height: 10),
                              GestureDetector(
                                onTap: () {
                                  Clipboard.setData(ClipboardData(text: _createdCode!));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('✅ تم نسخ الرمز')));
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.copy_rounded, size: 14,
                                      color: AppColors.textTertiary),
                                    const SizedBox(width: 6),
                                    Text('انسخ الرمز',
                                      style: AppTextStyles.caption.copyWith(
                                        color: AppColors.textTertiary)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color:        AppColors.success.withOpacity(0.07),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(children: [
                            const Icon(Icons.wifi_outlined, color: AppColors.success, size: 16),
                            const SizedBox(width: 8),
                            Expanded(child: Text(
                              'في انتظار اتصال شريكك...',
                              style: AppTextStyles.caption.copyWith(color: AppColors.success))),
                          ]),
                        ),
                      ] else
                        MudGradientButton(
                          label:   '✨ إنشاء رمز ربط',
                          onTap:   _createRoom,
                          loading: _loading,
                        ),
                    ],
                  ),
                ),

                // ── Tab 2: Join room ────────────────────────
                SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      const Text('🔗', style: TextStyle(fontSize: 56)),
                      const SizedBox(height: 16),
                      Text('ادخلي رمز شريكك', style: AppTextStyles.headline2),
                      const SizedBox(height: 8),
                      Text(
                        'اطلب من شريكك مشاركة الرمز المكوّن من 6 أرقام',
                        style: AppTextStyles.body,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 28),

                      // Code input
                      TextField(
                        controller:     _codeCtrl,
                        textAlign:      TextAlign.center,
                        keyboardType:   TextInputType.number,
                        maxLength:      6,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        style: AppTextStyles.headline2.copyWith(
                          fontSize: 28, letterSpacing: 8,
                          color: AppColors.accentAlt,
                        ),
                        decoration: InputDecoration(
                          hintText:    '000000',
                          counterText: '',
                          errorText:   _error,
                        ),
                        onChanged: (_) { if (_error != null) setState(() => _error = null); },
                      ),
                      const SizedBox(height: 20),

                      MudGradientButton(
                        label:   '🔗 ربط مع الشريك',
                        onTap:   _joinRoom,
                        loading: _loading,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _createRoom() async {
    setState(() { _loading = true; _error = null; });
    final code = await ref.read(coupleNotifierProvider.notifier).createRoom();
    if (!mounted) return;
    setState(() { _loading = false; _createdCode = code; });
  }

  Future<void> _joinRoom() async {
    final code = _codeCtrl.text.trim();
    if (code.length != 6) {
      setState(() => _error = 'أدخل رمزاً مكوناً من 6 أرقام');
      return;
    }
    setState(() { _loading = true; _error = null; });
    final ok = await ref.read(coupleNotifierProvider.notifier).joinRoom(code);
    if (!mounted) return;
    setState(() => _loading = false);
    if (!ok) setState(() => _error = 'الرمز غير صحيح أو منتهي الصلاحية');
  }
}

// ── Active view ───────────────────────────────────────────
class _ActiveView extends ConsumerWidget {
  final CoupleRoom room;
  const _ActiveView({required this.room});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    backgroundColor: AppColors.bg,
    appBar: AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text('💑 ${AppStrings.paywallCouple}', style: AppTextStyles.title),
    ),
    body: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            width:  72, height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.success.withOpacity(0.12),
            ),
            child: const Center(child: Text('💑', style: TextStyle(fontSize: 36))),
          ),
          const SizedBox(height: 16),
          Text('متزامنان بنجاح 🎉', style: AppTextStyles.headline2),
          const SizedBox(height: 8),
          Text(
            room.isOwner
                ? 'شريكك متصل — كل المصاريف تتزامن تلقائياً'
                : 'متصل مع شريكك — كل المصاريف تتزامن تلقائياً',
            style: AppTextStyles.body,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Status card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color:        AppColors.success.withOpacity(0.07),
              borderRadius: BorderRadius.circular(14),
              border:       Border.all(color: AppColors.success.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Container(
                  width: 8, height: 8,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: AppColors.success),
                ),
                const SizedBox(width: 10),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('مزامنة نشطة',
                      style: AppTextStyles.bodyBold.copyWith(color: AppColors.success)),
                    Text('رمز الغرفة: ${room.code}',
                      style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                  ],
                )),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Features list
          ...['✅ المصاريف تتزامن في الوقت الفعلي',
              '✅ الأهداف المشتركة متزامنة',
              '✅ الدخل والميزانية محدّثان',
              '✅ كل تغيير يصل لشريكك فوراً',
          ].map((f) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(children: [
              Text(f, style: AppTextStyles.body.copyWith(height: 1.6)),
            ]),
          )),

          const Spacer(),

          // Leave button
          GestureDetector(
            onTap: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  backgroundColor: AppColors.surface2,
                  title: Text('قطع الاتصال', style: AppTextStyles.title),
                  content: Text('هل تريد قطع المزامنة مع شريكك؟',
                    style: AppTextStyles.body),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(AppStrings.cancel,
                        style: AppTextStyles.body.copyWith(color: AppColors.textSecondary))),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(AppStrings.delete,
                        style: AppTextStyles.body.copyWith(color: AppColors.error))),
                  ],
                ),
              );
              if (ok == true) {
                await ref.read(coupleNotifierProvider.notifier).leaveRoom();
                if (context.mounted) Navigator.of(context).pop();
              }
            },
            child: Text('قطع الاتصال',
              style: AppTextStyles.body.copyWith(color: AppColors.error)),
          ),
          const SizedBox(height: 20),
        ],
      ),
    ),
  );
}
