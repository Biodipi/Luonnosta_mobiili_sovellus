// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'marking.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Marking _$MarkingFromJson(Map<String, dynamic> json) => Marking(
      json['id'] as String,
      json['creator'] as String,
      json['description'] as String,
      json['image'] as String,
      (json['sharedWith'] as List<dynamic>).map((e) => e as String).toList(),
      json['title'] as String,
      json['position'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$MarkingToJson(Marking instance) => <String, dynamic>{
      'id': instance.id,
      'creator': instance.creator,
      'image': instance.image,
      'title': instance.title,
      'position': instance.position,
      'description': instance.description,
      'sharedWith': instance.sharedWith,
    };
