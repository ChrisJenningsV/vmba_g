import 'package:flutter/material.dart';

import 'SystemColors.dart';
import 'package:vmba/data/settings.dart';

// variable shared to whole app
// initialized in main_XX.dart
//
String gbl_appTitle ;
String gbl_language = 'en' ;
String gbl_languages ;
String gbl_buildFlavor = 'FL';
String gbl_error = '';
String gbl_version = '';
String gbl_action='';
bool gbl_isIos = true;
bool gbl_isLive = false;
SystemColors gbl_SystemColors;
Map gbl_langMap ;
Settings gbl_settings;
bool gbl_NoNetwork;
bool gbl_verbose = true;
bool  gbl_wantLogin = true;
TextStyle gbl_titleStyle;
List<String> gbl_titles = <String>[
  'Mr',
  'Mrs',
  'Ms',
  'Dr',
  'Miss',
  'Mstr',
  'Prof',
  'Rev'
];
