import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/insights_notifier.dart';
import 'insight_card.dart';

// ══════════════════════════════════════════════════════════
// InsightsSection — dropped into daily_screen as a sliver
// Shows up to 3 insights, animates in/out
// ══════════════════════════════════════════════════════════

class InsightsSection extends ConsumerWidget {
  const InsightsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state    = ref.watch(insightsNotifierProvider);
    final insights = state.insights;

    if (insights.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          // Section header
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Text(AppStrings.insightsTitle,
                  style: AppTextStyles.caption.copyWith(
                    color:      AppColors.textTertiary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  )),
                const Spacer(),
                Text('${insights.length}',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary)),
              ],
            ),
          ),
          // Cards with enter animation
          ...insights.asMap().entries.map((e) => _AnimatedInsight(
            key:     ValueKey(e.value.id),
            delay:   Duration(milliseconds: e.key * 60),
            child:   InsightCard(insight: e.value),
          )),
        ]),
      ),
    );
  }
}

// Staggered fade+slide animation per card
class _AnimatedInsight extends StatefulWidget {
  final Duration delay;
  final Widget   child;
  const _AnimatedInsight({super.key, required this.delay, required this.child});

  @override
  State<_AnimatedInsight> createState() => _AnimatedInsightState();
}

class _AnimatedInsightState extends State<_AnimatedInsight>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double>   _opacity;
  late final Animation<Offset>   _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 350),
    );
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide   = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end:   Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _opacity,
    child:   SlideTransition(position: _slide, child: widget.child),
  );
}
