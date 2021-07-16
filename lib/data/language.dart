import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
/*
void initLangs() async {
  try {
  var prefs = await SharedPreferences.getInstance();
  if (prefs.getString('language_code') == null) {
    gblLanguage = 'en';
    return ;
  }
  gblLanguage= prefs.getString('language_code');
  } catch(e){
    print('initLang error: $e');
  }
}

 */

void saveLang(String code) async {
  try {
    var prefs = await SharedPreferences.getInstance();
    prefs.setString('language_code', code);
  } catch(e){
    print('saveLang error: $e');
  }
  }