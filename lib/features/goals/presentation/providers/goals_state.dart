import 'package:equatable/equatable.dart';
import '../../domain/entities/goal.dart';

sealed class GoalsState extends Equatable {
  const GoalsState();
  @override List<Object?> get props => [];
}

final class GoalsLoading extends GoalsState { const GoalsLoading(); }

final class GoalsLoaded extends GoalsState {
  final List<Goal> goals;
  final bool       isSaving;
  final String?    errorMessage;
  final String?    justCompletedGoalId; // for celebration

  const GoalsLoaded({
    this.goals              = const [],
    this.isSaving           = false,
    this.errorMessage,
    this.justCompletedGoalId,
  });

  bool get isEmpty            => goals.isEmpty;
  bool get hasActive          => goals.any((g) => !g.isCompleted);
  List<Goal> get activeGoals  => goals.where((g) => !g.isCompleted).toList();
  List<Goal> get doneGoals    => goals.where((g) => g.isCompleted).toList();
  double get totalSaved       => goals.fold(0.0, (s, g) => s + g.saved);
  double get totalTarget      => goals.fold(0.0, (s, g) => s + g.target);

  GoalsLoaded copyWith({
    List<Goal>? goals,
    bool?       isSaving,
    String?     errorMessage,
    String?     justCompletedGoalId,
    bool        clearError            = false,
    bool        clearCompletion       = false,
  }) =>
      GoalsLoaded(
        goals:               goals               ?? this.goals,
        isSaving:            isSaving            ?? this.isSaving,
        errorMessage:        clearError          ? null : errorMessage ?? this.errorMessage,
        justCompletedGoalId: clearCompletion     ? null : justCompletedGoalId ?? this.justCompletedGoalId,
      );

  @override
  List<Object?> get props =>
      [goals, isSaving, errorMessage, justCompletedGoalId];
}

final class GoalsError extends GoalsState {
  final String message;
  const GoalsError(this.message);
  @override List<Object?> get props => [message];
}
