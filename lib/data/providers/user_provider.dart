import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/app_constants.dart';
import '../models/user_profile.dart';

final userProvider = StreamProvider<UserProfile?>((ref) {
  final box = Hive.box<UserProfile>(AppConstants.userBox);
  return box.watch().map((_) => box.get('profile'));
});

final userActionsProvider = Provider((ref) => UserActions(ref));

class UserActions {
  final Ref _ref;
  UserActions(this._ref);

  Box<UserProfile> get _box => Hive.box<UserProfile>(AppConstants.userBox);

  Future<void> saveProfile(UserProfile profile) async {
    await _box.put('profile', profile);
  }

  UserProfile? get profile => _box.get('profile');

  Future<void> updateStreak() async {
    final profile = this.profile;
    if (profile == null) return;
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month.toString().padLeft(2,'0')}-${today.day.toString().padLeft(2,'0')}';
    if (profile.lastLogDate == todayStr) return;

    final yesterday = today.subtract(const Duration(days: 1));
    final yStr = '${yesterday.year}-${yesterday.month.toString().padLeft(2,'0')}-${yesterday.day.toString().padLeft(2,'0')}';

    if (profile.lastLogDate == yStr) {
      profile.streakCount++;
    } else if (profile.lastLogDate.isEmpty) {
      profile.streakCount = 1;
    } else {
      profile.streakCount = 1;
    }

    profile.lastLogDate = todayStr;
    if (profile.streakCount > int.parse(profile.bestStreak)) {
      profile.bestStreak = profile.streakCount.toString();
    }
    await profile.save();
  }
}
