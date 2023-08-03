import 'dart:io';
import 'dart:async';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:vmba/data/globals.dart';
import 'package:vmba/data/repository.dart';
import 'package:vmba/utilities/helper.dart';



void initFirebase() {

}


Future<void> saveToken(String token) async {
  var deviceInfo = DeviceInfoPlugin();
  String deviceId ;
  if (Platform.isIOS) { // import 'dart:io'
    var iosDeviceInfo = await deviceInfo.iosInfo;
    deviceId =  iosDeviceInfo.identifierForVendor as String; // unique ID on iOS
  } else {
    var androidDeviceInfo = await deviceInfo.androidInfo;
    deviceId = androidDeviceInfo.androidId as String; // unique ID on Android
  }
  logit('device id = $deviceId tok = $token');
  gblNotifyToken = token;
  gblDeviceId = deviceId;
}

Future<void> subscribeForNotifications() async {
  await runFunctionCommand('SubscribeForNotifications','');
}

Future<void> unsubscribeForNotifications() async {
  await runFunctionCommand('UnsubscribeForNotifications','');

}

