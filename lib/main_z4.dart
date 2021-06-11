import 'package:flutter/material.dart';
import 'data/SystemColors.dart';

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

  gblSystemColors =_systemColors;
  gblAppTitle = 'ibomair';
  gblBuildFlavor = 'Z4';

  var configuredApp = AppConfig(
    appTitle: 'ibomair',
    child: App(),
    buildFlavor: 'Z4',
    systemColors: _systemColors,
    settings: gblSettings,
  );
  return runApp(configuredApp);
}

