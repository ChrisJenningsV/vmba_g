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

import '../controllers/vrsCommands.dart';
import '../data/models/notifyMsgs.dart';
import '../data/repository.dart';
import '../home/home_page.dart';
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

      final DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings(
        requestSoundPermission: false,
        requestBadgePermission: false,
        requestAlertPermission: false,
        onDidReceiveLocalNotification: onDidReceiveLocalNotification,
      );
/*
      final DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings(
        requestSoundPermission: false,
        requestBadgePermission: false,
        requestAlertPermission: false,
        onDidReceiveLocalNotification: onDidReceiveLocalNotification,
      );
*/
      final InitializationSettings initializationSettings =
      InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
          macOS: null);

      flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

      flutterLocalNotificationsPlugin.initialize(
          initializationSettings, onDidReceiveNotificationResponse : onClickNotification);


      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      channel = AndroidNotificationChannel(
        gblSettings.androidAppId as String ,   //'com.domain.appname.urgent',//'high_importance_channel', // id
        'High Importance Notifications', // title
        importance: Importance.high,
      );

      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel!);

      /// Update the iOS foreground notification presentation options to allow
      /// heads up notifications.
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
      //await firebase.messaging().registerDeviceForRemoteMessages()
      NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,);
      logit('**** permission: ${settings.authorizationStatus}');
      if(settings.authorizationStatus !=  AuthorizationStatus.authorized){
        logit('PERMISSION NOT GRANTED');
        //gblError = 'PERMISSION NOT GRANTED';
        gblWarning = 'Notifications switched off for this phone. To receive booking updates go to this app in you phone settings and enable Notifications';
      }

      FirebaseMessaging.instance.getToken().then((token){

        //print('token= ' + token);
        if( gblIsLive == false ) {
          serverLog('Firebase token=$token');
        }
        saveToken(token!);
      });

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {

        RemoteNotification? notification = message.notification;
        //AndroidNotification android = message.notification?.android;
        logit('onMessage.listen msg received ${message.messageId}');
        //Map data = message.data;

       try {
         Repository.get().updateNotification(message, false, false).then((value) {
           Repository.get().getAllNotifications().then((m) {
             gblNotifications = m;
           });
         });
       } catch(e) {

       }
        processNotification(message.data);
        showNotification( NavigationService.navigatorKey.currentContext, notification, message.data, 'om listen');


      });
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        logit('A new onMessageOpenedApp msg received ${message.messageId}');
        try {
          Repository.get().updateNotification(message, false, false).then((value) {
            Repository.get().getAllNotifications().then((m) {
              gblNotifications = m;
            });
          });
        } catch(e) {

        }
        processNotification(message.data);
        showNotification( NavigationService.navigatorKey.currentContext, message.notification, message.data, 'appOpen listen');
        /*         Navigator.pushNamed(context, '/message',
              arguments: MessageArguments(message, true));*/
      });
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    } catch(e) {
      logit(e.toString());
      showError(e.toString());
    }
  }

void processNotification(Map data){
    logit('processNotify data=$data');
    if( data == null  ) {

      return ;
    }

    if( data['actions'] != null && data['rloc'] != null) {
      String action = data['actions'];
      String rloc = data['rloc'];

      if (action == 'paycomplete') {
        // reload booking
        refreshBooking(rloc);
      }
    }
  }
void onClickNotification(NotificationResponse? s) {
    print('onClickNotification');
}

  // called in iOS < v10.0
  void onDidReceiveLocalNotification(int a, String? b, String? c, String? d) {

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
AndroidNotificationChannel? channel;

/// Initialize the [FlutterLocalNotificationsPlugin] package.
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  //await Firebase.initializeApp();
  logit('Handling a background message ${message.messageId}');
  try {
    Repository.get().updateNotification(message, true, false).then((value) {
      Repository.get().getAllNotifications().then((m) {
        gblNotifications = m;

        RemoteNotification n = RemoteNotification(title: message.notification!.title, body: message.notification!.body);
        if( scaffoldKey.currentContext != null ) {
          showNotification(
              scaffoldKey.currentContext, message.notification, message.data,
              'Background');
        } else if (NavigationService.navigatorKey.currentContext != null ) {
          showNotification(
              NavigationService.navigatorKey.currentContext as BuildContext,
              message.notification, message.data, 'Background');
        }

      });
    });

  } catch(e) {

  }


}
