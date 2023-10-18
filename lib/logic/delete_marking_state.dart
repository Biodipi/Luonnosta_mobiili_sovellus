part of 'delete_marking_cubit.dart';

@immutable
abstract class DeleteMarkingState {}

class DeleteMarkingInitial extends DeleteMarkingState {}

class DeleteMarkingSuccess extends DeleteMarkingState {}

class DeleteMarkingError extends DeleteMarkingState {}

class DeleteMarkingLoading extends DeleteMarkingState {}
