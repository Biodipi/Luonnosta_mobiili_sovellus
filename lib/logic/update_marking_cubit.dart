import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:luonnosta_app/constants.dart';
import 'package:luonnosta_app/logic/auth_cubit.dart';
import 'package:uuid/uuid.dart';

import '../model/marking.dart';
part 'update_marking_state.dart';

class UpdateMarkingCubit extends Cubit<UpdateMarkingState> {
  UpdateMarkingCubit() : super(UpdateMarkingInitial());

  update(Marking marking, File? pendingImage) async {
    emit(UpdateMarkingLoading());
    // Update image

    if (pendingImage != null) {
      final storageRef = FirebaseStorage.instance.ref();
      Reference? fileRef;

      if (marking.image.isNotEmpty) {
        fileRef = storageRef.child("images/${marking.image}");
      } else {
        String uid = const Uuid().v4();
        fileRef = storageRef.child("images/$uid");
        marking.image = uid;
      }

      try {
        await fileRef.putFile(pendingImage);
      } catch (e) {
        emit(UpdateMarkingError());
        return;
      }
    }

    // Update post
    try {
      final response = await http.put(
          Uri.parse("${Constants.baseUrl}/entries/${marking.id}"),
          headers: {
            HttpHeaders.authorizationHeader: await AuthCubit.getAuthToken(),
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(marking.toJson()));
      if (response.statusCode == 200) {
        emit(UpdateMarkingSuccess());
      } else {
        emit(UpdateMarkingError());
      }
    } catch (e) {
      emit(UpdateMarkingError());
    }
  }
}
