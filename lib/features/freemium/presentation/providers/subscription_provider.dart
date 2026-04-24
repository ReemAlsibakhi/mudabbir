import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/subscription.dart';

// ── Single source of truth for subscription state ─────────
final subscriptionProvider =
    StateNotifierProvider<SubscriptionNotifier, Subscription>(
  (_) => SubscriptionNotifier(),
);

final class SubscriptionNotifier extends StateNotifier<Subscription> {
  static const _tag   = 'SubNotifier';
  static const _key   = 'subscription';

  Box get _box => Hive.box(AppConstants.settingsBox);

  SubscriptionNotifier() : super(Subscription.free) {
    _load();
  }

  void _load() {
    try {
      final raw = _box.get(_key);
      if (raw == null) { state = Subscription.free; return; }
      final expStr = raw['expiresAt'] as String?;
      final expDate = expStr != null ? DateTime.tryParse(expStr) : null;
      state = expDate != null
          ? Subscription.premium(expDate)
          : Subscription.free;
      AppLogger.info(_tag, 'Loaded: ${state.isFree ? "free" : "premium until $expDate"}');
    } catch (e) {
      AppLogger.error(_tag, 'load error', e);
      state = Subscription.free;
    }
  }

  // Called after successful purchase (RevenueCat webhook)
  Future<void> activate({required Duration duration}) async {
    final expiry = DateTime.now().add(duration);
    state = Subscription.premium(expiry);
    await _box.put(_key, {'expiresAt': expiry.toIso8601String()});
    AppLogger.info(_tag, 'Activated premium until $expiry');
  }

  // Called on restore purchase
  Future<void> restore() async {
    _load(); // re-reads from box
  }

  // Called when subscription expires
  Future<void> deactivate() async {
    state = Subscription.free;
    await _box.delete(_key);
    AppLogger.info(_tag, 'Deactivated — back to free');
  }

  // ── Convenience helpers used by UI ────────────────────
  bool get isPremium => state.isPremium;
  bool get isFree    => state.isFree;
}

// ── Feature gate providers ─────────────────────────────────
final canUseAiChatProvider  = Provider((ref) => ref.watch(subscriptionProvider).canUseAiChat);
final canUseGpsProvider     = Provider((ref) => ref.watch(subscriptionProvider).canUseGPS);
final canExportPdfProvider  = Provider((ref) => ref.watch(subscriptionProvider).canExportPDF);
final maxFixedExpProvider   = Provider((ref) => ref.watch(subscriptionProvider).maxFixedExpenses);
final rescueTokensProvider  = Provider((ref) => ref.watch(subscriptionProvider).rescueTokens);
