import 'dart:io';
import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:vmba/utilities/helper.dart';



void initFirebase() {

}


Future<void> saveToken(String token) async {
  var deviceInfo = DeviceInfoPlugin();
  String deviceId ;
  if (Platform.isIOS) { // import 'dart:io'
    var iosDeviceInfo = await deviceInfo.iosInfo;
    deviceId =  iosDeviceInfo.identifierForVendor; // unique ID on iOS
  } else {
    var androidDeviceInfo = await deviceInfo.androidInfo;
    deviceId = androidDeviceInfo.androidId; // unique ID on Android
  }
  logit('device id = $deviceId tok = $token');

}

