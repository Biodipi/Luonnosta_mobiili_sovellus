// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map_layer_meta.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MapLayerMeta _$MapLayerMetaFromJson(Map<String, dynamic> json) => MapLayerMeta(
      json['displayName'] as String,
      json['name'] as String,
      json['maxZoom'] as int,
      json['minZoom'] as int,
    );

Map<String, dynamic> _$MapLayerMetaToJson(MapLayerMeta instance) =>
    <String, dynamic>{
      'displayName': instance.displayName,
      'name': instance.name,
      'maxZoom': instance.maxZoom,
      'minZoom': instance.minZoom,
    };
