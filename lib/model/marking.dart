import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'marking.g.dart';

@JsonSerializable()
class Marking {
  Marking(this.id, this.creator, this.description, this.image, this.sharedWith,
      this.title, this.position);

  String id;
  String creator;
  String image;
  String title;
  Map<String, dynamic> position;
  String description;
  List<String> sharedWith;

  factory Marking.fromJson(Map<String, dynamic> json) =>
      _$MarkingFromJson(json);

  Map<String, dynamic> toJson() => _$MarkingToJson(this);

  bool isMyOwn() {
    return (FirebaseAuth.instance.currentUser?.email == creator);
  }

  bool isShared() {
    return sharedWith.isNotEmpty;
  }

  Color getColor() {
    if (!isMyOwn()) return Colors.grey;
    if (isShared()) return Colors.blue;
    return Colors.green;
  }

  String getShareStatus() {
    if (!isMyOwn()) return "Käyttäjältä $creator";
    if (isShared()) return "Jaettu ${sharedWith.length} käyttäjälle";
    return "Vain minä";
  }

  static Marking empty() {
    return Marking(const Uuid().v4(), FirebaseAuth.instance.currentUser!.email!,
        "", "", [], "", {});
  }
}
