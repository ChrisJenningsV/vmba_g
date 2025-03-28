import 'package:flutter/material.dart';
import 'package:vmba/menu/appFeedBackPage.dart';
import 'package:vmba/menu/contact_us_page.dart';
import 'package:vmba/menu/faqs_page.dart';
import 'package:vmba/menu/myAccountPage.dart';
import 'package:vmba/menu/myFqtvPage.dart';
import 'package:vmba/utilities/helper.dart';
import 'package:vmba/components/trText.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:vmba/data/globals.dart';
import 'package:vmba/components/selectLang.dart';
import 'package:vmba/ads/adsPage.dart';
import 'package:vmba/v3pages/v3UnlockPage.dart';

import '../GenericList/ListPage.dart';
import '../Helpers/settingsHelper.dart';
import '../data/repository.dart';
import '../dialogs/genericFormPage.dart';
import '../dialogs/smartDialog.dart';
import '../functions/text.dart';
import '../home/home_page.dart';
import '../utilities/messagePages.dart';
import '../utilities/navigation.dart';
import '../utilities/widgets/snackbarWidget.dart';
import 'debug.dart';
import 'icons.dart';


class DrawerMenu extends StatefulWidget {
  DrawerMenu({
    Key key= const Key("menu_key"),
  }) : super(key: key);


  _DrawerMenuState createState() => _DrawerMenuState();
}

  class _DrawerMenuState extends State<DrawerMenu> {

    @override
    initState() {
      super.initState();
    }

  @override
  Widget build(BuildContext context) {

    List<Widget> list = [];

    if(wantHomePageV3() ) {
        list.add(Padding( padding: EdgeInsets.only(left: 10, top: 30),
            child: Image.asset('lib/assets/$gblAppTitle/images/appBar.png',
        width: 150,
        alignment: Alignment.bottomLeft,)));
    } else {
      list.add(Container(
        height: wantHomePageV3() ? null : 130,
        width: wantHomePageV3() ? 150 : null,
        child: DrawerHeader(
          child: Image.asset('lib/assets/$gblAppTitle/images/logo.png',
            width: wantHomePageV3() ? 150 : null,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
          ),
        ),
      ));
    }
    // Home
    list.add( menuItem(Icons.home, 'Home' , (){ navToHomepage(context) ;} ));

    if( gblNoNetwork == false && gblSettings.disableBookings == false ) {
      list.add( menuItem(Icons.flight_takeoff, 'Book a flight' , (){
        gblCurPage = 'FLIGHTSEARCH';
        navToFlightSearchPage(context);
      }, iconName: 'flightSearch') );
    }

      if(  gblBuildFlavor == 'LM' && gblNoNetwork == false && gblSettings.disableBookings == false ) {
        list.add( menuItem(Icons.flight_takeoff, 'Book an ADS / Island Resident Flight' , (){
          gblCurPage = 'BOOKADS';
          Navigator.push(context, SlideTopRoute(page: AdsPage()));
        },  iconName: 'flight', smallFont: true));
      }

        //Divider(),
    list.add( menuItem(Icons.card_travel, 'My Bookings' , (){
      gblCurPage = 'MYBOOKINGS';
      Navigator.of(context).pushNamedAndRemoveUntil(
          '/MyBookingsPage', (Route<dynamic> route) => false);
    }, ));
      if( gblSettings.wantPushNoticications){
        //Divider(),
        list.add( menuItem(Icons.push_pin_outlined, 'Notifications' , (){
          gblCurPage = 'MYNOTIFICATIONS';
          Navigator.of(context).pushNamedAndRemoveUntil(
              '/MyNotificationsPage', (Route<dynamic> route) => false);
        }));
      }

        if( gblNoNetwork == false ) {
          list.add( menuItem(Icons.add, 'Add an existing booking' , (){
            gblCurPage = 'ADDBOOKING';
            Navigator.of(context).pushNamedAndRemoveUntil(
                '/AddBookingPage', (Route<dynamic> route) => false);
          }));
        }

        if(gblSettings.gblLanguages != null && gblSettings.gblLanguages.isNotEmpty && gblNoNetwork == false ) {
          list.add( menuItem(Icons.flag, 'Language' , (){
            Navigator.push(
                context, SlideTopRoute(page: LanguageSelection()
            ));
          },
          ));
        }


    if(gblSettings.wantHelpCentre) {
      list.add( menuItem(Icons.help_center, 'Contact Us' , (){
        Navigator.push(context,
            SlideTopRoute(page: CustomPageWeb('Contact Us', gblSettings.contactUsUrl)));
      },  iconColor: Colors.red));
    }

    if(gblSettings.wantUnlock && gblIsLive == false) {
      list.add( menuItem(Icons.lock, 'Unlock' , () {
        Navigator.push(
            context, SlideTopRoute(page: UnlockPage()
        ));
      }));
    }


    // My Account
    if(gblSettings != null &&  gblSettings.wantMyAccount != null && gblSettings.wantMyAccount) {
      list.add( menuItem(Icons.person_outlined, 'My Account' , () {
        Navigator.push(
            context, SlideTopRoute(page: MyAccountPage(
          isAdsBooking: false,
          isLeadPassenger: true,
        )
        ));
        },
      ));
    }

    //FQTV
    String fqtvName = 'My ${gblSettings.fqtvName}';
    if( gblSettings.fqtvName.startsWith('My')) {
      fqtvName = '${gblSettings.fqtvName}';
    }

    if(gblNoNetwork == false  && gblSettings != null && gblSettings.wantFQTV!= null && gblSettings.wantFQTV) {
      list.add( menuItem(Icons.person_pin, fqtvName , () {
        if( gblFqtvLoggedIn == false ) {
          navToSmartDialogHostPage(context, new FormParams(formName: 'FQTVLOGIN',
              formTitle: '${gblSettings.fqtvName} Login'));
/*
          if (gblSettings.wantNewDialogs) {
            String sTitle = translate('${gblSettings.fqtvName} ') +
                translate('LOGIN');
            if (sTitle.length > 20) sTitle = translate('LOGIN');
            gblCurDialog = getDialogDefinition('FQTVLOGIN', sTitle);

            showSmartDialog(context, null, () {
              setState(() {});
            });
*/
          //}
        } else {
              Navigator.push(
                  context, SlideTopRoute(page: MyFqtvPage(
                isAdsBooking: false,
                isLeadPassenger: true,
              )
              ));
        }
      }));
      }

    if( gblSettings != null && gblSettings!.wantFlightStatus ){
      list.add( menuItem(Icons.airplanemode_active, 'Flight Status' , () {
        gblDestination = '';
        gblOrigin = '';
        navToFlightStatusPage(context);
      }, iconName: 'FlightStatus' ));
    }

    if( gblSettings != null && gblSettings!.wantFopVouchers && gblIsLive == false){
      list.add( menuItem(Icons.airplane_ticket_outlined, 'My Vouchers' , () {
        Navigator.push(
            context, SlideTopRoute(page: GenericListPageWidget('VOUCHERS')
        ));
      }));
    }

    if( gblSettings != null && gblSettings!.wantNews && gblIsLive == false){
      list.add( menuItem(Icons.newspaper_outlined, 'NEWS'  , () {
        Navigator.push(
            context, SlideTopRoute(page: GenericListPageWidget('NEWS')));
      }));
    }

    // FAQ
    if(gblNoNetwork == false &&
        (gblSettings.aircode == 'LM' || gblSettings.aircode == 'SI' ||
            (gblSettings.faqUrl != null && gblSettings.faqUrl != ''))) {

      list.add( menuItem(Icons.live_help, 'FAQs'   , () {
        switch (gblSettings.aircode) {
          case 'LM':
            Navigator.push(context, SlideTopRoute(page: FAQsPage()));
            break;
          case 'SI':
            Navigator.push(context, SlideTopRoute(page: FAQsPage()));
            break;
          default:
            Navigator.push(context, SlideTopRoute(page: FAQsPageWeb()));
        }
      }));
    }

    // contact us
    if( gblNoNetwork == false && gblSettings.wantHelpCentre == false &&
        (gblSettings.aircode == 'LM' || gblSettings.aircode == 'SI' || gblSettings.contactUsUrl != '')) {

      list.add( menuItem( Icons.phone, 'Contact us' , () {
          switch (gblSettings.aircode) {
      case 'LM':
      Navigator.push(context, SlideTopRoute(page: ContactUsPage()));
      break;
      case 'SI':
      Navigator.push(context, SlideTopRoute(page: ContactUsPage()));
      break;
      default:
      Navigator.push(context, SlideTopRoute(page: ContactUsPageWeb()));
      }
      }));

  }

    // custom1
    if( gblNoNetwork == false) {
      if (gblSettings.customMenu1 != null &&
          gblSettings.customMenu1.isNotEmpty) {
        try {
          var menuText = gblSettings.customMenu1.split(',')[0];
          var pageText = gblSettings.customMenu1.split(',')[1].trim();
          var url = gblSettings.customMenu1.split(',')[2];
          if (menuText.isNotEmpty && pageText.isNotEmpty && url.isNotEmpty) {
            // SizedBox(height: 24,
            //             child:
            list.add( menuItem( Icons.web, menuText , () {}));
            Navigator.push(context,
                SlideTopRoute(page: CustomPageWeb(pageText, url)));
            }
        } catch (e) {
          logit(e.toString());
        }
      }

      // custom2
      if (gblSettings.customMenu2 != null &&
          gblSettings.customMenu2.isNotEmpty) {
        try {
          var menuText = gblSettings.customMenu2.split(',')[0];
          var pageText = gblSettings.customMenu2.split(',')[1].trim();
          var url = gblSettings.customMenu2.split(',')[2];
          if (menuText.isNotEmpty && pageText.isNotEmpty && url.isNotEmpty) {
            list.add( menuItem(Icons.web, menuText , () {
              Navigator.push(context,
                  SlideTopRoute(page: CustomPageWeb(pageText, url)));
            }));
          }
        } catch (e) {
          logit(e.toString());
        }
      }
      // custom3
      if (gblSettings.customMenu3 != null &&
          gblSettings.customMenu3.isNotEmpty) {
        try {
          var menuText = gblSettings.customMenu3.split(',')[0];
          var pageText = gblSettings.customMenu3.split(',')[1].trim();
          var url = gblSettings.customMenu3.split(',')[2];
          if (menuText.isNotEmpty && pageText.isNotEmpty && url.isNotEmpty) {
            list.add( menuItem(Icons.web, menuText , () {
              Navigator.push(context,
                  SlideTopRoute(page: CustomPageWeb(pageText, url)));
            }));
          }
        } catch (e) {
          logit(e.toString());
        }
      }
    }

    if(gblSecurityLevel >= 99 ){
      list.add( menuItem(Icons.web, 'Admin Page', () {
        Navigator.push(context,
            SlideTopRoute(page: DebugPage(name: 'ADMIN',)));
      }));

      list.add( menuItem(Icons.web, 'Log', () {
        Navigator.push(context,
            SlideTopRoute(page: GenericListPageWidget('LOG')));
      }));

      list.add( menuItem(Icons.web, 'Clear Log', () {
        Repository.get().clearLogfile();
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(snackbar('Done'));
      }));

    }
    
    if( gblIsLive == false && gblWantLogBuffer) {
      list.add( menuItem(Icons.web, 'Log Buffer', () {
        List<Widget> list = [];
        gblLogBuffer.forEach((element) {
          if(element.length > 40){
            list.add(Row( children: [Icon(Icons.adjust, size: 10,), Padding(padding: EdgeInsets.all(2)), Text(element.substring(0,40))]));
          } else {
            list.add(Row( children: [Icon(Icons.adjust, size: 10,), Padding(padding: EdgeInsets.all(2)), Text(element)]));
          }
        });

        showDialog(
            context: context,
            builder: (BuildContext context)
            {
              return msgDialog(context, translate('Log Buffer'),
                  SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: new Column(crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: list)), ipad: EdgeInsets.zero, wide: true);
            }
        );
      }));

/*
      list.add(ListTile(
          dense: true,
          title: _getMenuItem(Icons.web, 'Log Buffer'),
          onTap: () {
            List<Widget> list = [];
            gblLogBuffer.forEach((element) {
              if(element.length > 40){
                list.add(Row( children: [Icon(Icons.adjust, size: 10,), Padding(padding: EdgeInsets.all(2)), Text(element.substring(0,40))]));
              } else {
                list.add(Row( children: [Icon(Icons.adjust, size: 10,), Padding(padding: EdgeInsets.all(2)), Text(element)]));
              }
            });

            showDialog(
                context: context,
                builder: (BuildContext context)
                {
                  return msgDialog(context, translate('Log Buffer'),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                  child: new Column(crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: list)), ipad: EdgeInsets.zero, wide: true);
                }
            );
          }));
*/
    }
/*
    if( gblSettings.wantAdminLogin){
      if( gblSecurityLevel >= 99 ) {
        list.add(ListTile(
            dense: dense,
            title: _getMenuItem(Icons.login, 'Admin Page'),
            onTap: () {
              Navigator.push(context,
                  SlideTopRoute(page: DebugPage(name: 'ADMIN',)));

            }
        )
        );
      } else {
        list.add(ListTile(
            dense: dense,
            title: _getMenuItem(Icons.login, 'Log in'),
            onTap: () {
              gblCurDialog = getDialogDefinition('AGENTLOGIN','Agent Login' );
//              return smartDialogPage();

              showSmartDialog(context, null, () {
                setState(() {});
              });
            }));
      }
    }
*/

    // DEMO login - for Apple acreditation
    if(  (gblSettings.iOSDemoBuilds != null && gblSettings.iOSDemoBuilds.isNotEmpty  && gblIsIos == true ) ||
        (gblSettings.androidDemoBuilds != null && gblSettings.androidDemoBuilds.isNotEmpty  && gblIsIos == false )){
      try{
        String buildNo = '';
          buildNo = gblVersion.split('.')[3];
          if ((gblIsIos && gblSettings.iOSDemoBuilds.contains('#$buildNo#')) ||
              (gblIsIos == false && gblSettings.androidDemoBuilds.contains('#$buildNo#'))){
            if(  gblDemoMode == true ) {
   /*           list.add(ListTile(
                  dense: dense,
                  title: _getMenuItem(Icons.web, translate('Logout')),
                  onTap: () {
                    // do logout
                    gblIsLive = true;
                    setLiveTest();

                    gblDemoMode = false;
                    if( gblCurPage != 'HOME') {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                          '/HomePage', (Route<dynamic> route) => false);
                    } else {
                      Navigator.of(context).pop();
                     // homePageKeyProgress.currentState.refresh();
                       //reloadPage(context);
                    }
                   // if ( ModalRoute.of(context).hasActiveRouteBelow ) {
                    //}
                   // Navigator.push(context, SlideTopRoute(page: HomePage()));
      *//*              Navigator.of(context).pushNamedAndRemoveUntil(
                        '/HomePage', (Route<dynamic> route) => false);
*//*
                  }));
*/
            } else if( gblIsLive == true) {
              list.add(ListTile(
                  dense: true,
                  title: _getMenuItem(Icons.web, translate('Login')),
                  onTap: () {
                    // do login
                    loginPage(context, '',
                        onOk: (dynamic p, String user, String pw) {
                          if( user == gblSettings.demoUser && pw == gblSettings.demoPassword) {
                            gblIsLive = false;
                            setLiveTest();
                            gblDemoMode = true;
                            // abandon any search / booking

                            if( gblCurPage != 'HOME') {
                            /*  Navigator.of(context).pushNamedAndRemoveUntil(
                                  '/HomePage', (Route<dynamic> route) => false);*/
                              /*Navigator.of(context).pushNamedAndRemoveUntil(
                                  '/HomePage', (Route<dynamic> route) => false);*/
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                              Navigator.of(context).push(MaterialPageRoute(builder: (context) => HomePage()));
                            } else {
                              Navigator.of(context).pop();
                            }
                            return 'OK';
                          } else {
                            return 'Login FAILED';
                          }
                        }
                    );
                  }));
            }
          }
      } catch(e) {
        logit(e.toString());
      }

    }



    // feed back
    list.add( menuItem(Icons.stay_primary_portrait, 'App feedback', () {
      Navigator.of(context).pop();
      PackageInfo.fromPlatform()
          .then((PackageInfo packageInfo) =>
      packageInfo.version + '.' + packageInfo.buildNumber)
          .then((String version) {
        Navigator.push(
            context, SlideTopRoute(page: AppFeedBackPage(version: version)));
      });
    }));


    return Drawer(
      // Add a ListView to the drawer. This ensures the user can scroll
      // through the options in the Drawer if there isn't enough vertical
      // space to fit everything.
      child: Container(
        color: Colors.white,
        child: ListView(
          // Important: Remove any padding from the ListView.
          shrinkWrap: true,
          padding: EdgeInsets.zero,
         // itemExtent: 50,
          children: list,
        ),
      ),
    );
  }

  Widget _getMenuItem( IconData ico, String txt, {Color? iconColor, String iconName='', bool smallFont = false} ) {

      if( iconColor == null ){
        iconColor = Colors.black;
      }
      Widget mIcon = Icon(ico, color: iconColor,);
      if( iconName != '' ){
          mIcon = getNamedIcon(iconName, color: iconColor);
    }

    return Row(
      children: <Widget>[
        Padding(
          // padding: EdgeInsets.only(right: 55),
          padding: EdgeInsets.only(right: 10),
          child: mIcon,
        ),
        v2MenuText(txt, smallFont: smallFont),
      ],
    );
  }


    Widget menuItem( IconData icon, String caption , void Function () onClick, {Color? iconColor, String iconName='', bool smallFont = false} ) {
      return Container(child:
          Column(
          children: [
            ListTile(
              contentPadding: EdgeInsets.only(left: 10),
              dense: true,
              visualDensity: VisualDensity(vertical: -1),
              title: _getMenuItem( icon, caption, iconName: iconName, iconColor: iconColor, smallFont: smallFont ),
              onTap: () {
                onClick();
              },
            ),
            Padding(padding: EdgeInsets.only(left: 15, right: 10), child:Divider(thickness: 1,
              color: Colors.grey.shade300, height: 2,))
        ])
/*
          decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.black26)))
*/
      );
    }
  }