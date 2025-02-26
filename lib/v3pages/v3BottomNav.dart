
import 'package:flutter/material.dart';

import '../components/bottomNav.dart';
import '../components/selectLang.dart';
import '../components/vidButtons.dart';
import '../data/globals.dart';
import '../utilities/helper.dart';
import '../utilities/navigation.dart';
import 'cards/v3CustomPage.dart';

Widget? getV3BottomNav(BuildContext context, {Widget? popButton , String helpText='',  void Function()? custom } ) {

    List <Widget> list = [];

    //list.add(vidTextButton(context, 'logout', _logout)
    list.add(TextButton(
        onPressed: () {
          logit('logout');
/*
          gblDemoMode = false;
          gblIsLive = true;
          setLiveTest();
          if( gblCurPage != 'HOME') {
            Navigator.of(context).pushNamedAndRemoveUntil(
                '/HomePage', (Route<dynamic> route) => false);
          } else {
            reloadPage(context);
          }
*/
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


  return
    BottomNavigationBar(
      type: BottomNavigationBarType.fixed,

      backgroundColor: Color.fromRGBO(0, 0, 0, 0.6),
      items:   <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),

        BottomNavigationBarItem(
          icon:  Icon(Icons.airplanemode_active),
          label: 'Book',
        ),

        BottomNavigationBarItem(
          icon:  Icon(Icons.table_rows_sharp),
          label: 'Bookings',
        ),
        BottomNavigationBarItem(
          icon:  Icon(Icons.person),
          label: 'Account',
        ),
/*
        BottomNavigationBarItem(
          icon:  Icon(Icons.menu
          ),
          label: 'more',
        ),
*/

      ],
      currentIndex: 0,
      selectedItemColor: Colors.red,
      unselectedItemColor: Colors.white,
      onTap: (value) async {
        switch (value){
          case 0:
            // home
            gblCurPage = 'HOME';
            navToHomepage(context) ;
            break;
          case 1:
            // book now
            navToFlightSearchPage(context);
            break;
          case 2:
            // my bookings
            gblCurPage = 'MYBOOKINGS';
            navToMyBookingsPage(context);
            break;
          case 3:
            // my account
            gblCurPage = 'MYACCOUNT';
            navToMyAccountPage(context);
            break;
          case 4:
            // more
            Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
              V3CustomPage( name: 'menu')));

            break;
        }

      }
    );

}




