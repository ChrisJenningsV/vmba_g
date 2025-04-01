
import 'package:flutter/material.dart';
import '../components/trText.dart';
import '../data/globals.dart';
import '../dialogs/genericFormPage.dart';
import '../dialogs/smartDialog.dart';
import '../menu/icons.dart';
import '../menu/myFqtvPage.dart';
import '../utilities/helper.dart';
import '../utilities/navigation.dart';

Widget? getV3BottomNav(BuildContext context, String curPage,  {Widget? popButton , String helpText='',  void Function()? custom } ) {

    List <Widget> list = [];

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

  List<BottomNavigationBarItem> bList = [];

    bList.add(BottomNavigationBarItem(icon: Icon(Icons.home),label: 'Home'));

    bList.add(BottomNavigationBarItem(icon: getNamedIcon('FLIGHTSEARCH'), label: 'Book' ));

    bList.add(BottomNavigationBarItem(icon: Icon(Icons.luggage_rounded), label: 'My Trips' ));

    if( gblInReview == false) {
      if (gblFqtvLoggedIn == false) {
        bList.add(
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Login'));
      } else {
        bList.add(BottomNavigationBarItem(
            icon: Icon(Icons.person), label: '${gblSettings.fqtvName}'));
      }
    }

    if( gblSettings.wantFlightStatus) {
      bList.add(BottomNavigationBarItem(
          icon: getNamedIcon('FLIGHTSTATUS'), label: 'Track'));
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
      items:   bList,
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
            if( gblInReview == false) {
              if (gblFqtvLoggedIn == false) {
                navToSmartDialogHostPage(
                    context, new FormParams(formName: 'FQTVLOGIN',
                    formTitle: '${gblSettings.fqtvName} Login'));
              } else {
                Navigator.push(
                    context, SlideTopRoute(page: MyFqtvPage(
                  isAdsBooking: false,
                  isLeadPassenger: true,
                )
                ));
              }
            } else {
              navToFlightStatusPage(context);
            }
            break;
          case 4:
            navToFlightStatusPage(context);
            break;
        }

      }
  )
    );

}




