import 'package:flutter/material.dart';

import 'SystemColors.dart';
import 'package:vmba/data/settings.dart';

// variable shared to whole app
// initialized in main_XX.dart
//
String gblAppTitle ;
String gblLanguage = 'en' ;
String gblLanguages ;
String gblBuildFlavor = 'FL';
String gblError = '';
String gblVersion = '';
String gblAction='';
bool gblIsIos = true;
bool gblIsAds = true;
bool gblIsLive = false;
SystemColors gblSystemColors;
Map gblLangMap ;
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
