//import 'dart:html';
import 'package:flutter/material.dart';
import 'package:vmba/components/trText.dart';
import 'package:vmba/data/globals.dart';

import 'colourHelper.dart';

Widget smallButton({required  String text, IconData? icon, required void Function() onPressed, Color? backClr, String? id }) {
  Color back = gblSystemColors.primaryButtonColor;
  if( backClr != null ) back = backClr;

  if(icon == null ){
    return new FloatingActionButton.extended(
        elevation: 0.0,
        heroTag: id,
        isExtended: true,
        label: Text(
          text,
          style: TextStyle(
              color: gblSystemColors
                  .primaryButtonTextColor),
        ),
        backgroundColor: back,
        onPressed: () {
          onPressed();
        });

  } else {
    return new FloatingActionButton.extended(
        elevation: 0.0,
        heroTag: id,
        isExtended: true,
        label: Text(
          text,
          style: TextStyle(
              color: gblSystemColors
                  .primaryButtonTextColor),
        ),
        icon: Icon(icon,
            color: gblSystemColors
                .primaryButtonTextColor),
        backgroundColor: back,
        onPressed: () {
          onPressed();
        });
  }
}

Widget saveButton({required String text, IconData? icon, required void Function() onPressed }) {
  return ElevatedButton(
    onPressed: () {
      if( gblNoNetwork == false ) {
        onPressed();
      }
    },
    style: ElevatedButton.styleFrom(
        backgroundColor: actionButtonColor(), //Colors.black,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0))),
    child: Row(
//mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(
          icon,
          color: Colors.white,
        ),
        TrText(
          'SAVE',
          style: TextStyle(color: Colors.white),
        ),
      ],
    ),
  );
}