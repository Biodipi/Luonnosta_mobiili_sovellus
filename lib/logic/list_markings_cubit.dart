import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'package:luonnosta_app/constants.dart';
import 'package:luonnosta_app/logic/auth_cubit.dart';

import '../model/marking.dart';
part 'list_markings_state.dart';

class ListMarkingsCubit extends Cubit<ListMarkingsState> {
  ListMarkingsCubit() : super(ListMarkingsInitial());

  listAll() async {
    emit(ListMarkingsLoading());

    try {
      final response = await http.get(
        Uri.parse("${Constants.baseUrl}/entries"),
        headers: {
          HttpHeaders.authorizationHeader: await AuthCubit.getAuthToken(),
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      if (response.statusCode == 200) {
        List<Marking> result = [];
        List ownEntries = jsonDecode(response.body)["data"]["ownEntries"];
        List sharedEntries = jsonDecode(response.body)["data"]["sharedEntries"];

        for (var element in ownEntries) {
          result.add(Marking.fromJson(element));
        }
        for (var element in sharedEntries) {
          result.add(Marking.fromJson(element));
        }
        emit(ListMarkingsSuccess(result));
      } else {
        emit(ListMarkingsError(response.statusCode.toString()));
      }
    } catch (e) {
      emit(ListMarkingsError(e.toString()));
    }
  }
}
