// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:luonnosta_app/model/marking.dart';

class MapMarker extends StatelessWidget {
  MapMarker(this.onTap, this.marking, {Key? key}) : super(key: key);

  Function onTap;
  Marking marking;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Container(
        decoration: BoxDecoration(
          color: marking.getColor(),
          border: Border.all(color: Colors.white, width: 5),
          borderRadius: const BorderRadius.all(Radius.circular(230)),
        ),
        child: Transform.translate(
          offset: const Offset(0, 52),
          child: SizedBox(
            width: 500,
            child: Text(
              marking.title,
              overflow: TextOverflow.visible,
              style: const TextStyle(
                  fontSize: 15,
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
