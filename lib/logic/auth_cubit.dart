import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

import 'package:http/http.dart' as http;

import '../constants.dart';
part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());
  bool didDeleteUser = false;

  deleteAccount() async {
    emit(AuthLoading());
    try {
      final response = await http
          .delete(Uri.parse("${Constants.baseUrl}/user/entries"), headers: {
        HttpHeaders.authorizationHeader: await AuthCubit.getAuthToken(),
      });
      if (response.statusCode == 200) {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await user.delete();
        }
      } else {
        emit(AuthError(response.statusCode.toString()));
        return;
      }
    } catch (e) {
      emit(AuthError(e.toString()));
      return;
    }
    didDeleteUser = true;
    emit(AuthInitial());
  }

  resetPass(email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } catch (e) {
      emit(AuthError(e.toString()));
      return;
    }
    emit(AuthInitial());
  }

  logout() async {
    emit(AuthLoading());
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      emit(AuthError(e.toString()));
      return;
    }
    emit(AuthInitial());
  }

  login(email, password) async {
    emit(AuthLoading());
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        emit(AuthError('Tälle sähköpostille ei löytynyt käyttäjää.'));
        return;
      } else if (e.code == 'wrong-password') {
        emit(AuthError(
            'Virheellinen käyttäjätunnus tai salasana! Yritä uudelleen.'));
        return;
      }
    }
    didDeleteUser = false;
    emit(AuthSuccess());
  }

  register(email, password) async {
    emit(AuthLoading());
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        emit(AuthError('Salasana on liian heikko. Yritä uudelleen.'));
        return;
      } else if (e.code == 'email-already-in-use') {
        emit(AuthError(
            'Tämä sähköpostiosoite on jo käytössä. Yritä uudelleen.'));
        return;
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
    didDeleteUser = false;
    emit(AuthSuccess());
  }

  static Future<String> getAuthToken() async {
    return "Bearer ${await FirebaseAuth.instance.currentUser!.getIdToken()}";
  }

  init() async {
    if (didDeleteUser) {
      return;
    }
    if (FirebaseAuth.instance.currentUser != null) {
      debugPrint("Login exists!");
      emit(AuthSuccess());
    } else {
      debugPrint("Not logged in!");
    }
  }
}
