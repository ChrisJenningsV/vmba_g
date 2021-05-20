import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vmba/data/SystemColors.dart';
import 'package:vmba/data/settings.dart';
import 'package:vmba/data/models/passengerTypesDisplay.dart';

import 'resources/app_config.dart';
import 'main.dart';
import 'data/globals.dart';

void main() {
  SystemColors _systemColors = SystemColors(
      primaryButtonColor: Color.fromRGBO(83, 40, 99, 1),
      accentButtonColor: Color.fromRGBO(83, 40, 99, 1),
         // Color.fromRGBO(73, 201, 245, 1), 
      accentColor: Color.fromRGBO(83, 40, 99, 1),//Color.fromRGBO( 241, 182, 0, 1), //Color.fromRGBO(0, 83, 55, 1), //Colors.white,
      primaryColor: Colors.white,
      primaryButtonTextColor: Colors.white,
      primaryHeaderColor: Colors.white,//Color.fromRGBO(12, 59, 111, 1),
      headerTextColor: Colors.black,
      statusBar: Brightness.light);

  gbl_SystemColors =_systemColors;
  gbl_appTitle = 'airswift';
  gbl_buildFlavor = 'T6';

  var configuredApp = AppConfig(
    appTitle: 'airswift',
    child: App(),
    buildFlavor: 't6',
    systemColors: _systemColors,
  );
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(configuredApp);
  });
}
