part of 'create_marking_cubit.dart';

abstract class CreateMarkingState {}

class CreateMarkingInitial extends CreateMarkingState {}

class CreateMarkingSuccess extends CreateMarkingState {}

class CreateMarkingError extends CreateMarkingState {
  final String message;

  CreateMarkingError(this.message);
}

class CreateMarkingLoading extends CreateMarkingState {}
