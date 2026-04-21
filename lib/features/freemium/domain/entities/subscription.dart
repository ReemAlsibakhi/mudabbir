import 'package:equatable/equatable.dart';

enum PlanType { free, premium }

final class Subscription extends Equatable {
  final PlanType planType;
  final DateTime? expiresAt;
  final bool      isActive;

  const Subscription({
    required this.planType,
    this.expiresAt,
    this.isActive = true,
  });

  bool get isPremium => planType == PlanType.premium && isActive;
  bool get isFree    => !isPremium;

  // ── Feature gates ──────────────────────────────────────
  bool get canUseAIChat        => isPremium;
  bool get canUseSMSReader     => isPremium;
  bool get canUseCoupleMode    => isPremium;
  bool get canAddUnlimitedGoals => isPremium;
  int  get maxGoals            => isPremium ? 999 : 1;
  int  get maxFixedExpenses    => isPremium ? 999 : 5;
  int  get rescueTokens        => isPremium ? 3 : 1;

  static const free    = Subscription(planType: PlanType.free);
  static const premium = Subscription(planType: PlanType.premium);

  @override
  List<Object?> get props => [planType, expiresAt, isActive];
}
