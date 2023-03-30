

import 'package:firebase_messaging/firebase_messaging.dart';
//import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vmba/components/showNotification.dart';
import 'package:vmba/components/vidButtons.dart';

import '../Helpers/pageHelper.dart';
import '../Helpers/settingsHelper.dart';
import '../data/globals.dart';
import '../utilities/blueScreen.dart';
import '../utilities/helper.dart';
import '../utilities/messagePages.dart';
import 'trText.dart';
void Function() _custom;

Widget getBottomNav(BuildContext context, {Widget popButton, String helpText, void Function() custom } ) {

  if( gblDebugMode == true ){
    return DebugBottomNav(custom: custom,);
  }

  if( gblDemoMode == true){
    List <Widget> list = [];

    //list.add(vidTextButton(context, 'logout', _logout)
    list.add(TextButton(
        onPressed: () {
          logit('logout');
          gblDemoMode = false;
          gblIsLive = true;
          setLiveTest();
          if( gblCurPage != 'HOME') {
            Navigator.of(context).pushNamedAndRemoveUntil(
                '/HomePage', (Route<dynamic> route) => false);
          } else {
            reloadPage(context);
          }
            //(context as Element).reassemble();
        },

        child:Text('logout')));

      if ( popButton != null ){
        list.add(popButton);
      }
      //Text('Demo Mode'),
      if( helpText != null && helpText.isNotEmpty) {
      list.add(VidBlinkingButton(title: 'Demo mode', color: Colors.lightBlue.shade400, onClick: (c) {
        demoDialog(context, helpText: helpText);
        },));
      } else {
        list.add(vidDemoButton(context, 'Demo mode',  (c) {
          demoDialog(context, helpText: helpText);
        },));
      }



    return Container(
        decoration: BoxDecoration(
          color: Colors.lightBlue.shade50,
          border: Border(top: BorderSide(color: Colors.grey, width: 1)),
        ),
      //
        child: Row(

      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.max,
    children: list
      )
    );
  }

  if( gblCurPage != 'HOME'){
    return null;
  }

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
void demoDialog(BuildContext context, {String helpText} ) {
  if( helpText == null || helpText.isEmpty){
    helpText = 'You are now in Demo mode, connected to our test system. This system is also used for training and Beta testing, some may not always be available. ' +
        '\n\nThe test system doe not have as many fares and route configures as LIVE. \n\nIf the demo button is flashing more information for the current page is available.';
  }
  showDialog(
      context: context,
      builder: (BuildContext context)
  {
    return msgDialog(context, translate('Demo mode'),
        Text(helpText));
  }
  );
}


class DebugBottomNav extends StatefulWidget {
  void Function() custom;
  DebugBottomNav({ Key key, void Function() custom });

  @override
  DebugBottomNavState createState() => DebugBottomNavState();
}

class DebugBottomNavState extends State<DebugBottomNav> {

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    int _selectedPageIndex = 0;
    List<BottomNavigationBarItem> list = [];

    // logout
    list.add(BottomNavigationBarItem(
      icon: Icon(Icons.logout, color: Colors.red),
      activeIcon: Icon(Icons.logout, color: Colors.red),
      label: 'Logout',));

    // blue screen
    list.add(BottomNavigationBarItem(
      icon: Icon(Icons.screen_search_desktop_outlined, color: Colors.blue),
      backgroundColor: Colors.lightBlue,
      activeIcon:
      Icon(Icons.screen_search_desktop_outlined, color: Colors.green),
      label: 'emu',
    ));

    // live / test
    list.add(BottomNavigationBarItem(
      icon: Icon(Icons.swap_horiz_outlined, color: gblIsLive ? Colors.red : Colors.blue),
      activeIcon:
      Icon(Icons.swap_horiz_outlined, color:  gblIsLive ? Colors.red : Colors.blue),
      label: gblIsLive ?  'Live' : 'Test',
    ));

    logit( 'cc=${gblSettings.creditCardProvider} page=${gblCurPage}');
    if( gblCurPage == 'CREDITCARDPAGE' && gblSettings.creditCardProvider.toLowerCase() == 'videcard' ) {
      logit('add');
      _custom = widget.custom;
      // populate test CC
      list.add( BottomNavigationBarItem(
        icon: Icon(Icons.credit_card, color: Colors.blue),
        activeIcon: Icon(Icons.credit_card, color: Colors.green),
        label: 'add CC',
      ));
    }


    return BottomNavigationBar(
        onTap:(index) {
          _selectPage(context, index, _custom);
        },
        currentIndex: _selectedPageIndex,
        type: BottomNavigationBarType.fixed,
        items: list
    );

  }
  void _selectPage(BuildContext context, int index, void Function() custom) {
    switch (index) {
      case 0:
      // logout
        logit('logout');
        gblDebugMode = false;
        if( gblCurPage != 'HOME') {
          Navigator.of(context).pushNamedAndRemoveUntil(
              '/HomePage', (Route<dynamic> route) => false);
        } else {
          reloadPage(context);
        }

        break;
      case 1:
      // blue screen
        logit('launch BlueScreen');
        startBlueScreen(context);
        break;
      case 2:
      // swap live / text
        logit('swap live test');
        gblIsLive = !gblIsLive;
        setLiveTest() ;
        // force reload
        gblProviders = null;
        if( gblCurPage != 'HOME') {
          Navigator.of(context).pushNamedAndRemoveUntil(
              '/HomePage', (Route<dynamic> route) => false);
        } else {
          reloadPage(context);
        }
        break;
      case 3:
      // custom
        logit('custom action');
        if( custom != null ){
          custom();
        }
        break;


    }
  }
  }


