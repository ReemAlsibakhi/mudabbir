import 'package:equatable/equatable.dart';

enum PlanType { free, premium }

final class Subscription extends Equatable {
  final PlanType  plan;
  final DateTime? expiresAt;
  final bool      isActive;

  const Subscription({
    required this.plan,
    this.expiresAt,
    this.isActive = false,
  });

  bool get isFree    => plan == PlanType.free;
  bool get isPremium => plan == PlanType.premium && isActive;

  // ── Feature gates ─────────────────────────────────────
  // Free plan limits
  bool get canAddGoal        => true;  // unlimited in free too
  bool get canUseAiChat      => isPremium;
  bool get canUseGPS         => isPremium;
  bool get canExportPDF      => isPremium;
  int  get maxFixedExpenses  => isPremium ? 999 : 5;
  int  get rescueTokens      => isPremium ? 3   : 1;
  bool get canUseCouplMode   => isPremium;
  bool get canSeeDetailedReports => true; // free too

  static const Subscription free = Subscription(plan: PlanType.free);

  factory Subscription.premium(DateTime expiresAt) => Subscription(
    plan:      PlanType.premium,
    expiresAt: expiresAt,
    isActive:  DateTime.now().isBefore(expiresAt),
  );

  @override
  List<Object?> get props => [plan, expiresAt, isActive];
}
