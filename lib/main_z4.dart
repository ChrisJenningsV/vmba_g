import 'package:flutter/material.dart';
import 'data/SystemColors.dart';
import 'package:vmba/data/settings.dart';
import 'package:vmba/data/models/passengerTypesDisplay.dart';

import 'resources/app_config.dart';
import 'main.dart';
import 'data/globals.dart';

void main() {
  SystemColors _systemColors = SystemColors(
      primaryButtonColor: Color.fromRGBO(0, 83, 55, 1),
      accentButtonColor:
          Color.fromRGBO(243, 135, 57, 1), //Color.fromRGBO(243, 135, 57, 1),
      accentColor: Color.fromRGBO(0, 83, 55, 1), //Colors.white,
      primaryColor: Colors.white,
      primaryButtonTextColor: Colors.white,
      statusBar: Brightness.light);

  gbl_SystemColors =_systemColors;
  gbl_appTitle = 'ibomair';
  gbl_buildFlavor = 'Z4';

  var configuredApp = AppConfig(
    appTitle: 'ibomair',
    child: App(),
    buildFlavor: 'Z4',
    systemColors: _systemColors,
  );
  return runApp(configuredApp);
}
