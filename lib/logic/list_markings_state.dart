part of 'list_markings_cubit.dart';

abstract class ListMarkingsState {}

class ListMarkingsInitial extends ListMarkingsState {}

class ListMarkingsSuccess extends ListMarkingsState {
  final List<Marking> response;

  ListMarkingsSuccess(this.response);
}

class ListMarkingsError extends ListMarkingsState {
  final String message;

  ListMarkingsError(this.message);
}

class ListMarkingsLoading extends ListMarkingsState {}
