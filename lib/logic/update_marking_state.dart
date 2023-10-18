part of 'update_marking_cubit.dart';

abstract class UpdateMarkingState {}

class UpdateMarkingInitial extends UpdateMarkingState {}

class UpdateMarkingSuccess extends UpdateMarkingState {}

class UpdateMarkingError extends UpdateMarkingState {}

class UpdateMarkingLoading extends UpdateMarkingState {}
