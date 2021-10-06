




import 'dart:html';
import 'package:flutter/material.dart';
import 'package:vmba/data/globals.dart';

Widget smallButton({String text, IconData icon, void Function() onPressed }) {
  return                   new FloatingActionButton.extended(
      elevation: 0.0,
      isExtended: true,
      label: Text(
        text,
        style: TextStyle(
            color: gblSystemColors
                .primaryButtonTextColor),
      ),
      icon: Icon(Icons.check,
          color: gblSystemColors
              .primaryButtonTextColor),
      backgroundColor:
      gblSystemColors.primaryButtonColor,
      onPressed: () {
        onPressed();
      });

}