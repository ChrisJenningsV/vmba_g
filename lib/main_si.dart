import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vmba/data/SystemColors.dart';

import 'resources/app_config.dart';
import 'main.dart';
import 'data/globals.dart';

void main() {
  SystemColors _systemColors = SystemColors(
      primaryButtonColor: Color.fromRGBO(12, 59, 111, 1),
      accentButtonColor:
          Color.fromRGBO(241, 182, 0, 1), //Color.fromRGBO(243, 135, 57, 1),
      accentColor: Color.fromRGBO(
          241, 182, 0, 1), //Color.fromRGBO(0, 83, 55, 1), //Colors.white,
      primaryColor: Colors.white,
      primaryButtonTextColor: Colors.white,
      primaryHeaderColor: Color.fromRGBO(12, 59, 111, 1),
      headerTextColor: Colors.white,
      statusBar: Brightness.dark);

  gblSystemColors =_systemColors;
  gblAppTitle = 'blueislands';
  gblBuildFlavor = 'SI';
  gblSettings.wantLeftLogo = true;

  var configuredApp = AppConfig(
    appTitle: 'blueislands',
    child: App(),
    buildFlavor: 'SI',
    systemColors: _systemColors,
    settings: gblSettings,
  );
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(configuredApp);
  });
}
