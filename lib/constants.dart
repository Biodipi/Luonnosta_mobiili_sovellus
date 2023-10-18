import 'package:flutter/material.dart';
import 'package:proj4dart/proj4dart.dart';

class AppColors {
  static const Color greenButton = Color.fromARGB(255, 107, 211, 111);
  static const Color greenButtonText = Color(0xffffffff);
  static const Color logoLime = Color.fromARGB(255, 74, 172, 0);
  static const Color inputBorder = Color.fromARGB(255, 33, 167, 42);
  static const Color link = Color.fromARGB(255, 227, 234, 145);
  static const Color landingButton = Color(0xffBEECB2);
}

class Constants {
  // Firebase
  static const baseUrl =
      "https://europe-west1-biodipi-luonnosta.cloudfunctions.net/api";
  static const storageUrl = "gs://biodipi-luonnosta.appspot.com";

  // Maps
  static const crsDefinition =
      "+proj=utm +zone=35 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs +type=crs";
  static var namedProjection = Projection.add('EPSG:3067', crsDefinition);
  static var projection = Projection.parse(crsDefinition);
}

class AppBorder {
  static textFormBorder(Color color) {
    return OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.0),
        borderSide: BorderSide(
          color: color,
          width: 10.0,
        ));
  }
}
