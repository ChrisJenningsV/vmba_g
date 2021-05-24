import 'package:flutter/material.dart';
import 'package:vmba/data/app_localizations.dart';


String translate(BuildContext context, String msg) {
  String newText = AppLocalizations.of(context).translate(msg);
  if (newText != null ) {
    // use translation
    return newText;
  }
  // return input
  return msg;
}
