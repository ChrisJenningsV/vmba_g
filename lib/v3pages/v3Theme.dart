import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/globals.dart';
import 'homePageHelper.dart';

class V3Theme {
  V3Theme();

  late V3Calendar calendar = new V3Calendar();
  late V3Generic generic = new V3Generic();
  late V3BottomNavBar bottomNavBar = new V3BottomNavBar();
  String version = '';

  V3Theme.fromJson(Map<String, dynamic> json) {
    if(json['version'] != null ) version = json['version'];

    if( json['calendar'] != null ) calendar = V3Calendar.fromJson(json['calendar']);
    if( json['generic'] != null ) generic = V3Generic.fromJson(json['generic']);
    if( json['bottomNavBar'] != null ) bottomNavBar = V3BottomNavBar.fromJson(json['bottomNavBar']);
  }

}

class V3Input {
  V3Input();

}

class V3BottomNavBar{
  V3BottomNavBar();

  V3BottomNavBar.fromJson(Map<String, dynamic> json) {
   // if (json['setStatusBarColor'] != null) setStatusBarColor = bool.parse(json['setStatusBarColor']);
    //if( json['centerTitleText'] != null) centerTitleText = bool.parse(json['centerTitleText']);
  }
}
class V3NavBarButton {

}

class V3Generic {
  V3Generic();
  bool setStatusBarColor = false;
  bool centerTitleText = false;
  bool? actionButtonIcons;
  Color? actionButtonColor;
  double? actionButtonRadius;
  double? actionButtonPadding;
  bool actionButtonShadow = false;

  V3Generic.fromJson(Map<String, dynamic> json) {
    if (json['setStatusBarColor'] != null) setStatusBarColor = bool.parse(json['setStatusBarColor']);
    if( json['centerTitleText'] != null) centerTitleText = bool.parse(json['centerTitleText']);
    if( json['actionButtonIcons'] != null) actionButtonIcons = bool.parse(json['actionButtonIcons']);
    if( json['actionButtonShadow'] != null) actionButtonShadow = bool.parse(json['actionButtonShadow']);
    if( json['actionButtonColor'] != null ) actionButtonColor = lookUpColor(json['actionButtonColor']);
    if( json['actionButtonRadius'] != null ) actionButtonRadius = double.tryParse(json['actionButtonRadius']);
    if( json['actionButtonPadding'] != null ) actionButtonPadding = double.tryParse(json['actionButtonPadding']);

  }
}


class V3Calendar {

  V3Calendar();

  // set default colors
  Color backColor = Color.fromRGBO(0XF0, 0xF0, 0xF0, 1);
  Color textColor = Colors.black;
  Color selectableColor = Color.fromRGBO(0XCA, 0xCA, 0xCA, 1);
  Color disabledColor = Color.fromRGBO(0XE0, 0xE0, 0xE0, 1);

  late Color selectedBackColor = Colors.red;
  late Color selectedTextColor = Colors.white;

  V3Calendar.fromJson(Map<String, dynamic> json) {
      if(json['backColor'] != null ) backColor = lookUpColor(json['backColor']);
      if(json['textColor'] != null ) textColor = lookUpColor(json['textColor']);
      if(json['selectedBackColor'] != null ) selectedBackColor = lookUpColor(json['selectedBackColor']);
      if(json['selectedTextColor'] != null ) selectedTextColor = lookUpColor(json['selectedTextColor']);
      if(json['selectableColor'] != null ) selectableColor = lookUpColor(json['selectableColor']);
      if(json['disabledColor'] != null ) disabledColor = lookUpColor(json['disabledColor']);
  }
}

Future<void> loadTheme() async {
  try {
    // load theme from json file (Asset or server)
    String jsonString = await rootBundle.loadString(
        'lib/assets/$gblAppTitle/json/theme.json');

    final Map<String, dynamic> map = json.decode(jsonString);
    gblV3Theme = V3Theme.fromJson(map);

    // try network file
    try {
      loadNetTheme('theme.json');
    } catch(e) {
    }
  } catch(e) {
    // use defaults
    gblV3Theme = new V3Theme();
  }

}
Future<void> loadNetTheme(String fileName) async {
  final jsonString = await http.get(Uri.parse('${gblSettings.gblServerFiles}$fileName'), headers: {HttpHeaders.contentTypeHeader: "application/json",
    HttpHeaders.acceptEncodingHeader: 'gzip,deflate,br'}); // , HttpHeaders.acceptCharsetHeader: "utf-8"

  // need to use byte and decode here otherwise special characters corrupted !
  String data = utf8.decode(jsonString.bodyBytes);
  if( data.startsWith('{')) {
    try {
      final Map<String, dynamic> map = json.decode(data);
      gblV3Theme = V3Theme.fromJson(map);
    } catch(e) {
      gblErrorTitle = 'Error loading home.json';
    }

  } else {
 //   logit('home file data error ' + data.substring(0,20));
  }
}

Widget V3Divider(){
  return Divider(height: 15, thickness: 1,);
}