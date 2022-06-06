import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:vmba/Services/LoggingService.dart';
import 'package:vmba/Services/PushNotificationService.dart';
import 'package:vmba/components/showDialog.dart';
import 'package:vmba/components/showNotification.dart';
//import 'package:vmba/utilities/widgets/Messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:vmba/data/globals.dart';

import '../data/repository.dart';
import '../main.dart';
import 'helper.dart';


class NotificationService {

  static final NotificationService _notificationService =
  NotificationService._internal();

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal();

  Future<void> init(BuildContext context) async {
    try {
     // showError('test');
      // load saved messages
      Repository.get().getAllNotifications().then((m) {
        gblNotifications = m;
      });

      if( gblIsIos) {
      if (Firebase.apps.length <= 0) {
        try {
          await Firebase.initializeApp(
              options: const FirebaseOptions(
                  apiKey: 'AIzaSyCqd3J-LZhHR3QAyc7Fbe7tlY5Nk53Ff-8',
                  appId: '1:287291202399:ios:be7abf4aee0e8c3a6a74ea',
                  projectId: 'vmba-notify',
                  messagingSenderId: 'videcom',
                  storageBucket: 'VidecomNotify'
              )
          );
        } catch (e) {
          await Firebase.initializeApp();
          print(e.toString());
          showError(e.toString());
        }
      }
      } else {
        await Firebase.initializeApp();
      }

      final AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('app_icon');

      final IOSInitializationSettings initializationSettingsIOS =
      IOSInitializationSettings(
        requestSoundPermission: false,
        requestBadgePermission: false,
        requestAlertPermission: false,
        onDidReceiveLocalNotification: onDidReceiveLocalNotification,
      );

      final InitializationSettings initializationSettings =
      InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
          macOS: null);

      flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

      flutterLocalNotificationsPlugin.initialize(
          initializationSettings, onSelectNotification: onClickNotification);


      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      channel = const AndroidNotificationChannel(
        'com.domain.appname.urgent',//'high_importance_channel', // id
        'High Importance Notifications', // title
        importance: Importance.high,
      );

      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      /// Update the iOS foreground notification presentation options to allow
      /// heads up notifications.
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
      //await firebase.messaging().registerDeviceForRemoteMessages()
      FirebaseMessaging.instance.requestPermission();

      FirebaseMessaging.instance.getToken().then((token){

        print('token= ' + token);
        if( gblIsLive == false ) {
          serverLog('Firebase token=$token');
        }
        saveToken(token);
      });

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {

        RemoteNotification notification = message.notification;
        AndroidNotification android = message.notification?.android;
        logit('Listener msg received');
        Map data = message.data;

       try {
         Repository.get().updateNotification(message, false, false).then((value) {
           Repository.get().getAllNotifications().then((m) {
             gblNotifications = m;
           });
         });
       } catch(e) {

       }

        showNotification( NavigationService.navigatorKey.currentContext, notification, message.data);

     /*     flutterLocalNotificationsPlugin.show(
              notification.hashCode,
              notification.title,
              notification.body,
              NotificationDetails(
                android: AndroidNotificationDetails(
                  channel.id,
                  channel.name,
                  importance: Importance.max,
                  priority: Priority.high,
                  // styleInformation: BigTextStyleInformation(''),
                  //icon: 'app_icon',
                ),
              )
          );*/
    //    }


      });
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('A new onMessageOpenedApp event was published!');

        showNotification( NavigationService.navigatorKey.currentContext, message.notification, message.data);
        /*         Navigator.pushNamed(context, '/message',
              arguments: MessageArguments(message, true));*/
      });
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    } catch(e) {
      logit(e.toString());
      showError(e.toString());
    }
  }


void onClickNotification(String s) {
    print('onClickNotification');
}

  // called in iOS < v10.0
  void onDidReceiveLocalNotification(int a, String b, String c, String d) {

  }

}
Future onSelectNotification(String payload,BuildContext context) async {
  showDialog(
    context: context,
    builder: (_) {
      return new AlertDialog(
        title: Text("PayLoad"),
        content: Text("Payload : $payload"),
      );
    },
  );
}

/// Create a [AndroidNotificationChannel] for heads up notifications
AndroidNotificationChannel channel;

/// Initialize the [FlutterLocalNotificationsPlugin] package.
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  //await Firebase.initializeApp();
  print('Handling a background message ${message.messageId}');
  try {
    Repository.get().updateNotification(message, true, false).then((value) {
      Repository.get().getAllNotifications().then((m) {
        gblNotifications = m;
      });
    });

  } catch(e) {

  }


}
