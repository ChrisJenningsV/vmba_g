
import 'package:flutter/material.dart';
import '../data/globals.dart';
import '../dialogs/genericFormPage.dart';
import '../menu/icons.dart';
import '../utilities/helper.dart';
import '../utilities/navigation.dart';

Widget? getV3BottomNav(BuildContext context, String curPage,  {Widget? popButton , String helpText='',  void Function()? custom } ) {

    List <Widget> list = [];

/*    //list.add(vidTextButton(context, 'logout', _logout)
    list.add(TextButton(
        onPressed: () {
          logit('logout');
*//*
          gblDemoMode = false;
          gblIsLive = true;
          setLiveTest();
          if( gblCurPage != 'HOME') {
            Navigator.of(context).pushNamedAndRemoveUntil(
                '/HomePage', (Route<dynamic> route) => false);
          } else {
            reloadPage(context);
          }
*//*
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
    }*/

    int index = 0;
    switch(curPage) {
      case 'HOME':
        index = 0;
        break;
      case 'FLIGHTSEARCH':
        index = 1;
        break;
      case 'MYBOOKINGS':
        index = 2;
        break;
      case 'FLIGHTSTATUS':
        index = 3;
        break;
      default:
        logit('bottom nav page = $curPage');
        break;
    }

  return
    Container(
        decoration: BoxDecoration(
        color: Colors.red,
        border: Border(top: BorderSide(color: Colors.red, width: 2.0))),
  child:
  BottomNavigationBar(
      type: BottomNavigationBarType.fixed,

      backgroundColor: Colors.black, //Color.fromRGBO(0, 0, 0, 0.6),
      items:   <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),

        BottomNavigationBarItem(
          icon:  getNamedIcon('FLIGHTSEARCH'), // Icon(Icons.airplanemode_active),
          label: 'Book',
        ),

        BottomNavigationBarItem(
          icon:  Icon(Icons.luggage_rounded),
          label: 'My Trips',
        ),
        BottomNavigationBarItem(
          icon:  Icon(Icons.person),
          label: 'Login',
        ),

        BottomNavigationBarItem(
          icon:  getNamedIcon('FLIGHTSTATUS'),
          label: 'Track',
        ),
      ],
      currentIndex: index,
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
//            navToMyAccountPage(context);
            navToSmartDialogHostPage(context, new FormParams(formName: 'FQTVLOGIN',
                formTitle: '${gblSettings.fqtvName} Login'));
            break;
          case 4:
            navToFlightStatusPage(context);
            break;
        }

      }
  )
    );

}




