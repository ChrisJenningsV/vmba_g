import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vmba/menu/appFeedBackPage.dart';
import 'package:vmba/menu/contact_us_page.dart';
import 'package:vmba/menu/faqs_page.dart';
import 'package:vmba/menu/myAccountPage.dart';
import 'package:vmba/menu/myFqtvPage.dart';
import 'package:vmba/utilities/helper.dart';
import 'package:vmba/components/trText.dart';
import 'package:package_info/package_info.dart';
import 'package:vmba/data/globals.dart';
import 'package:vmba/components/selectLang.dart';
import 'package:vmba/menu/profileList.dart';
import 'package:vmba/ads/adsPage.dart';


class DrawerMenu extends StatelessWidget {
  DrawerMenu({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    List<Widget> list = [];

    list.add(Container(
      height: 130,
      child: DrawerHeader(
        child: Image.asset('lib/assets/$gblAppTitle/images/logo.png'),
        decoration: BoxDecoration(
          color: Colors.white,
        ),
      ),
    ));

    // Home
    list.add(  ListTile(
        title: _getMenuItem( Icons.home, 'Home' ),
        onTap: () {
          // Update the state of the app
          // ...
          Navigator.of(context).pushNamedAndRemoveUntil(
              '/HomePage', (Route<dynamic> route) => false);

          //Navigator.pop(context);
        },
      ));

    if( gblNoNetwork == false ) {
      list.add(ListTile(
        title: _getMenuItem(Icons.flight_takeoff, 'Book a flight'),
        onTap: () {
          // Update the state of the app
          // ...
          Navigator.of(context).pushNamedAndRemoveUntil(
              '/FlightSearchPage', (Route<dynamic> route) => false);
          //Navigator.pop(context);
        },
      ));
    }

      if(  gblBuildFlavor == 'LM' ) {
        list.add(ListTile(
          // contentPadding: EdgeInsets.zero,
          title: _getMenuItem(Icons.flight_takeoff, 'Book an ADS flight'),
          onTap: () {
            Navigator.push(context, SlideTopRoute(page: AdsPage()));
          },
        ));

        //Divider(),
        list.add(ListTile(
          title: _getMenuItem(Icons.card_travel, 'My Bookings'),
          onTap: () {
            // Update the state of the app
            // ...
            Navigator.of(context).pushNamedAndRemoveUntil(
                '/MyBookingsPage', (Route<dynamic> route) => false);
          },
        ));
      }
        if( gblNoNetwork == false ) {
          list.add(ListTile(
            title: _getMenuItem( Icons.add, 'Add an existing booking' ),
            onTap: () {
              // Update the state of the app
              // ...
              Navigator.of(context).pushNamedAndRemoveUntil(
                  '/AddBookingPage', (Route<dynamic> route) => false);
            },
          ));
        }

        if(gblSettings.gblLanguages != null && gblNoNetwork == false ) {
          list.add(ListTile(
            title: _getMenuItem(Icons.flag, 'Language'),
            onTap: () {
              Navigator.push(
                  context, SlideTopRoute(page: LanguageSelection()
              ));
            },
          ));
        }

    if(gblSettings.wantProfileList) {
      list.add(ListTile(
        title: _getMenuItem(Icons.list_alt_outlined, 'Profile list'),
        onTap: () {
          Navigator.push(
              context, SlideTopRoute(page: ProfileListPage()
          ));
        },
      ));
    }

    // My Account
    if(gblSettings != null &&  gblSettings.wantMyAccount != null && gblSettings.wantMyAccount) {
      list.add(ListTile(
        title: _getMenuItem(Icons.person_outline, 'My account'),
        onTap: () {
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
    if(gblNoNetwork == false  && gblSettings != null && gblSettings.wantFQTV!= null && gblSettings.wantFQTV) {
      list.add(ListTile(
        title: _getMenuItem( Icons.person_pin, 'My ${gblSettings.fqtvName}' ),
        onTap: () {
          Navigator.push(
              context, SlideTopRoute(page: MyFqtvPage(
            isAdsBooking: false,
            isLeadPassenger: true,
          )
          ));
        },
      ));
      }

    // FAQ
    if(gblNoNetwork == false) {
      list.add(ListTile(
        title: _getMenuItem( Icons.live_help, 'FAQs' ),
        onTap: () {
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
        },
      ));
    }

    // contact us
    if( gblNoNetwork == false ) {
      list.add(ListTile(
    title: _getMenuItem( Icons.phone, 'Contact us' ),
    onTap: () {
    //Navigator.push(context, SlideTopRoute(page: ContactUsPage()
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
    },
    ));
  }

    // custom1
    if( gblSettings.customMenu1 != null && gblSettings.customMenu1.isNotEmpty) {
      try{
      var menuText = gblSettings.customMenu1.split(',')[0];
      var pageText = gblSettings.customMenu1.split(',')[1];
      var url = gblSettings.customMenu1.split(',')[2];
      if( menuText.isNotEmpty && pageText.isNotEmpty && url.isNotEmpty) {
        list.add(ListTile(
            title: _getMenuItem(Icons.web, menuText),
            onTap: () {
              Navigator.push(context, SlideTopRoute(page: CustomPageWeb(pageText, url)));
            }));
      }
          } catch(e) {
        logit(e);
    }
    }

    // custom2
    if( gblSettings.customMenu2 != null && gblSettings.customMenu2.isNotEmpty) {
      try{
        var menuText = gblSettings.customMenu2.split(',')[0];
        var pageText = gblSettings.customMenu2.split(',')[1];
        var url = gblSettings.customMenu2.split(',')[2];
        if( menuText.isNotEmpty && pageText.isNotEmpty && url.isNotEmpty) {
          list.add(ListTile(
              title: _getMenuItem(Icons.web, menuText),
              onTap: () {
                Navigator.push(context, SlideTopRoute(page: CustomPageWeb(pageText, url)));
              }));
        }
      } catch(e) {
        logit(e);
      }
    }
    // feed back
    list.add(ListTile(
    title:  _getMenuItem( Icons.stay_primary_portrait, 'App feedback' ),
    onTap: () {
    PackageInfo.fromPlatform()
        .then((PackageInfo packageInfo) =>
    packageInfo.version + '.' + packageInfo.buildNumber)
        .then((String version) {
    Navigator.push(context,
    SlideTopRoute(page: AppFeedBackPage(version: version)
    ));
    });
    },
    ));

    return Drawer(
      // Add a ListView to the drawer. This ensures the user can scroll
      // through the options in the Drawer if there isn't enough vertical
      // space to fit everything.
      child: Container(
        color: Colors.white,
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: list,
            /* gbl_settings.specialAssistanceUrl.isNotEmpty ?
            ListTile(
              title: _getMenuItem( Icons.accessible_forward, 'Special assistance' ),
              onTap: () {
                Navigator.push(
                    context, SlideTopRoute(page: SpecialAssistancePage()
                    ));
              },
            ) : '',

             */
        ),
      ),
    );
  }






  Widget _getMenuItem( IconData ico, String txt ) {
    return Row(
      children: <Widget>[
        Padding(
          // padding: EdgeInsets.only(right: 55),
          padding: EdgeInsets.only(right: 15),
          child: Icon(ico),
        ),
        TrText(txt),
      ],
    );
  }

}
