


import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../components/trText.dart';
import '../data/globals.dart';
import '../functions/text.dart';

Widget frontPageNotification(BuildContext context) {
  if( gblNotifications == null)    return Container();

  int newCount = 0;
  gblNotifications!.list.forEach((element) {
    if(element.background == 'true' && !element.data!['actions'].toString().contains('promo')){
      newCount++;
    }
  });

  if( newCount == 0)  return Container();

  return InkWell(
      onTap: (){
        gblCurPage = 'MYNOTIFICATIONS';
        Navigator.of(context).pushNamedAndRemoveUntil(
            '/MyNotificationsPage', (Route<dynamic> route) => false);
      },
      child: Container(
        margin: EdgeInsets.only(top: 85, bottom: 10, left: 10, right: 10),
    height: 40,
    // width: (topLevel)? null : 120,
    decoration: BoxDecoration(
      shape: BoxShape.rectangle,
      color: Colors.white,
      borderRadius:
      new BorderRadius.all(new Radius.circular(5.0)),
      border: Border.all(
        color: Colors.red,
        width: 2
      )
    ),
    child: Row(
      children: [
        Padding( padding: EdgeInsets.only(left: 10, right: 10), child: FaIcon(FontAwesomeIcons.bell, color: Colors.red,)),
        v2NotifyText(translate('Travel Notifications') + ' ($newCount)', Colors.red),
      ],
    ),
  ));
}