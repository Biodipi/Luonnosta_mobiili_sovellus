import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../model/marking.dart';
import 'auth_cubit.dart';

part 'delete_marking_state.dart';

class DeleteMarkingCubit extends Cubit<DeleteMarkingState> {
  DeleteMarkingCubit() : super(DeleteMarkingInitial());

  delete(Marking marking) async {
    emit(DeleteMarkingLoading());

    if (marking.image != null && marking.image.isNotEmpty) {
      // Delete image
      final storageRef = FirebaseStorage.instance.ref();
      final fileRef = storageRef.child("images/${marking.image}");
      try {
        await fileRef.delete();
      } catch (e) {
        emit(DeleteMarkingError());
        return;
      }
    }

    // Delete post
    try {
      final response = await http.delete(
          Uri.parse("${Constants.baseUrl}/entries/${marking.id}"),
          headers: {
            HttpHeaders.authorizationHeader: await AuthCubit.getAuthToken(),
            'Content-Type': 'application/json; charset=UTF-8',
          });
      if (response.statusCode == 200) {
        emit(DeleteMarkingSuccess());
      } else {
        emit(DeleteMarkingError());
      }
    } catch (e) {
      emit(DeleteMarkingError());
    }
  }
}
