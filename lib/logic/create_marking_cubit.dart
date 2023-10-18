import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:luonnosta_app/logic/auth_cubit.dart';
import 'package:luonnosta_app/model/marking.dart';

import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import '../constants.dart';
part 'create_marking_state.dart';

class CreateMarkingCubit extends Cubit<CreateMarkingState> {
  CreateMarkingCubit() : super(CreateMarkingInitial());

  create(Marking marking, File? pendingImage) async {
    emit(CreateMarkingLoading());
    String fileUploadName = const Uuid().v4();

    // Upload image
    if (pendingImage != null) {
      final storageRef = FirebaseStorage.instance.ref();
      final fileRef = storageRef.child("images/$fileUploadName");
      try {
        await fileRef.putFile(pendingImage);
      } catch (e) {
        emit(CreateMarkingError("Kuvan lataus epäonnistui. Yritä uudelleen"));
        return;
      }
      marking.image = fileUploadName;
    }

    // Create marking
    try {
      final response =
          await http.post(Uri.parse("${Constants.baseUrl}/entries"),
              headers: {
                HttpHeaders.authorizationHeader: await AuthCubit.getAuthToken(),
                'Content-Type': 'application/json; charset=UTF-8',
              },
              body: jsonEncode(marking.toJson()));
      if (response.statusCode == 200) {
        emit(CreateMarkingSuccess());
      } else {
        emit(CreateMarkingError(response.statusCode.toString()));
      }
    } catch (e) {
      emit(CreateMarkingError(e.toString()));
    }
  }
}
