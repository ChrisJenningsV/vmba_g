import 'package:flutter/material.dart';
import 'package:vmba/data/models/models.dart';
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
String gblSine = '';
String gblVersion = '';
String gblAction='';
String gblMobileFlags = '';
int gblSecurityLevel = 0;
int gblFqtvBalance = 0;
bool gblIsIos = true;
bool gblIsLive = false;
bool gblTimerExpired = false;
bool gblRedeemingAirmiles = false;
bool gblNewDatepicker = true;
String gblFqtvNumber = '';
//String gblAdsNo = '';
//String gblAdsPin = '';
PassengerDetail gblPassengerDetail;
SystemColors gblSystemColors;
Session gblSession;
Map gblLangMap ;
Settings gblSettings;
bool gblNoNetwork;
bool gblVerbose = false;
bool  gblWantLogin = true;
TextStyle gblTitleStyle;
List<String> gblTitles = <String>[
  'Mr',
  'Mrs',
  'Ms',
  'Dr',
  'Miss',
  'Mstr',
  'Prof',
  'Rev'
];
