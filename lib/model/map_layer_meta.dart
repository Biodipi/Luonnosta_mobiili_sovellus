import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'map_layer_meta.g.dart';

@JsonSerializable()
class MapLayerMeta {
  final String displayName;
  final String name;
  final int maxZoom;
  final int minZoom;
  MapLayerMeta(this.displayName, this.name, this.maxZoom, this.minZoom);
}
