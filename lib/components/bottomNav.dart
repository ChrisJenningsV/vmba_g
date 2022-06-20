

import 'package:firebase_messaging/firebase_messaging.dart';
//import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vmba/components/showNotification.dart';

import '../data/globals.dart';

Widget getBottomNav(BuildContext context ) {
  int _selectedIndex = 0;
    if( gblNotifications == null ){
      return null;
    }

    int newNotifications = 0;
    int promos = 0;

    gblNotifications.forEach((element) {
      if(element.data['actions'] != null && element.data['actions'] == 'promo') {
        promos +=1;
      } else if( element.background == 'true') {
        newNotifications +=1;
      }
    });
    if( newNotifications == 0) {
      // no notifications
      return null;
    }
    return
      BottomNavigationBar(
        items:   <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: getNotification(promos, Icons.star),
            label: 'Promotions',
          ),
/*
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'Business',
          ),
*/
          BottomNavigationBarItem(
            icon: getNotification(newNotifications, Icons.notifications),
            label: 'Notifications',

          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: (value) => _onItemTapped(context, value, newNotifications, promos),
      );

}

Widget getNotification(int counter, IconData icon){
  return Stack(
    children: <Widget>[
      new Icon(icon),
      new Positioned(
        right: 0,
        child: new Container(
          padding: EdgeInsets.all(1),
          decoration: new BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(6),
          ),
          constraints: BoxConstraints(
            minWidth: 12,
            minHeight: 12,
          ),
          child: new Text(
            '$counter',
            style: new TextStyle(
              color: Colors.white,
              fontSize: 8,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      )
    ],
  );
  //return Icon(Icons.notifications);
}

 _onItemTapped(BuildContext context, int value, int newNotifications, int promos) {
    // Update the state of the app
    // ...
   if( value == 0) {
     if( promos > 0 ){
        print('promo clicked');
        List<String> args = [];
        args.add('promo');

        Navigator.of(context).pushNamedAndRemoveUntil(
            '/MyNotificationsPage', (Route<dynamic> route) => false, arguments: args);
     }
   }
   if( value == 1) {
     if( newNotifications == 1){
       gblNotifications.forEach((element) {
         if( element.background == 'true') {
           RemoteNotification n = RemoteNotification(title: element.notification.title, body: element.notification.body);
           showNotification( context, n, element.data);
           return;
         }
       });
     } else {
       List<String> args = [];
       args.add('new');

       Navigator.of(context).pushNamedAndRemoveUntil(
           '/MyNotificationsPage', (Route<dynamic> route) => false, arguments: args);
     }
   }
}