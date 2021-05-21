import 'package:flutter/material.dart';
import 'package:vmba/menu/appFeedBackPage.dart';
import 'package:vmba/menu/contact_us_page.dart';
import 'package:vmba/menu/faqs_page.dart';
import 'package:vmba/menu/special_assistance_page.dart';
import 'package:vmba/menu/myAccountPage.dart';
import 'package:vmba/resources/app_config.dart';
import 'package:vmba/utilities/helper.dart';
import 'package:vmba/components/trText.dart';
import 'package:package_info/package_info.dart';
import 'package:vmba/data/globals.dart';
import 'package:vmba/components/selectLang.dart';
import 'package:vmba/menu/profileList.dart';
import 'package:http/http.dart' as http;


class DrawerMenu extends StatelessWidget {
  DrawerMenu({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      // Add a ListView to the drawer. This ensures the user can scroll
      // through the options in the Drawer if there isn't enough vertical
      // space to fit everything.
      child: Container(
        color: Colors.white,
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            Container(
              height: 130,
              child: DrawerHeader(
                child: Image.asset('lib/assets/${gblAppTitle}/images/logo.png'),
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
              ),
            ),
            ListTile(
              title: _getMenuItem( Icons.home, 'Home' ),
              onTap: () {
                // Update the state of the app
                // ...
                Navigator.of(context).pushNamedAndRemoveUntil(
                    '/HomePage', (Route<dynamic> route) => false);

                //Navigator.pop(context);
              },
            ),
            ListTile(
              title: _getMenuItem( Icons.flight_takeoff, 'Book a flight' ),
              onTap: () {
                // Update the state of the app
                // ...
                Navigator.of(context).pushNamedAndRemoveUntil(
                    '/FlightSearchPage', (Route<dynamic> route) => false);
                //Navigator.pop(context);
              },
            ),
            gblBuildFlavor == 'LM' ?
            ListTile(
              // contentPadding: EdgeInsets.zero,
              title: _getMenuItem( Icons.flight_takeoff, 'Book an ADS flight' ),
              onTap: () {
                // Update the state of the app
                // ...
                Navigator.of(context).pushNamedAndRemoveUntil(
                    '/AdsPage', (Route<dynamic> route) => false);
                //Navigator.pop(context);
              },
            ): Padding(padding: EdgeInsets.all(0)),
            //Divider(),
            ListTile(
              title: _getMenuItem( Icons.card_travel, 'My bookingss' ),
              onTap: () {
                // Update the state of the app
                // ...
                Navigator.of(context).pushNamedAndRemoveUntil(
                    '/MyBookingsPage', (Route<dynamic> route) => false);
              },
            ),
            ListTile(
              title: _getMenuItem( Icons.add, 'Add an existing booking' ),
              onTap: () {
                // Update the state of the app
                // ...
                Navigator.of(context).pushNamedAndRemoveUntil(
                    '/AddBookingPage', (Route<dynamic> route) => false);
              },
            ),
            if(gblLanguages != null)
            ListTile(
              title: _getMenuItem( Icons.flag, 'Language' ),
              onTap: () {
                Navigator.push(
                    context, SlideTopRoute(page: LanguageSelection()
                ));
              },
            )  ,

            if(gbl_settings.wantProfileList) ListTile(
              title: _getMenuItem( Icons.list_alt_outlined, 'Profile list' ),
              onTap: () {
                Navigator.push(
                    context, SlideTopRoute(page: ProfileListPage()
                ));
              },
            ),
            if(gbl_settings.wantMyAccount) ListTile(
              title: _getMenuItem( Icons.person_outline, 'My account' ),
              onTap: () {
                Navigator.push(
                    context, SlideTopRoute(page: MyAccountPage(
                  isAdsBooking: false,
                  isLeadPassenger: true,
                )
                ));
              },
            ),
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
            ListTile(
              title: _getMenuItem( Icons.live_help, 'FAQs' ),
              onTap: () {
                switch (gbl_settings.aircode) {
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
            ),
            ListTile(
              title: _getMenuItem( Icons.phone, 'Contact us' ),
              onTap: () {
                //Navigator.push(context, SlideTopRoute(page: ContactUsPage()
                switch (gbl_settings.aircode) {
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
            ),  
            ListTile(
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
            ),
            if( gbl_wantLogin == true) ListTile(
              title:  _getMenuItem( null, '' ),
              onTap: () {
                showLogin(context);

              },
            ),
          ],
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

  showLogin(BuildContext context) {
      showDialog(
      context: context,
      builder: (BuildContext context) {
      return AlertDialog(
        title: Row(
          children:[
            Image.network('https://customertest.videcom.com/videcomair/vars/public/test/images/lock_user_man.png',
              width: 50, height: 50, fit: BoxFit.contain,),
            Text('  LOGIN ')
          ]
      ),
      content: contentBox(context),
      actions: <Widget>[
        ElevatedButton(
            style: ElevatedButton.styleFrom(primary: Colors.black12) ,
            child: TrText("CANCEL", style: TextStyle(backgroundColor: Colors.black12, color: Colors.black),),
            onPressed: () {
          //Put your code here which you want to execute on Cancel button click.
        Navigator.of(context).pop();
    },
    ),
        ElevatedButton(
          child: TrText("CONTINUE"),
          onPressed: () {
            String sine = _sineController.text;
            String pas = _passwordController.text;
              _sineIn(sine,pas);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
     },
    );
    }

  TextEditingController _sineController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  contentBox(context){
    return Stack(
      children: <Widget>[
        Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              new TextFormField(
                decoration: InputDecoration(
                  contentPadding:
                  new EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
                  labelText: 'Sine',
                  fillColor: Colors.white,
                  border: new OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(15.0),
                    borderSide: new BorderSide(),
                  ),
                ),
                controller: _sineController,
                keyboardType: TextInputType.phone,

                // do not force phone no here
                /*              validator: (value) => value.isEmpty
                    ? 'Phone number can\'t be empty'
                    : null,

   */
                onSaved: (value) {
                  if (value != null) {
                    //.contactInfomation.phonenumber = value.trim()
                  }
                },
              ),
              SizedBox(height: 15,),
              new TextFormField(
                controller: _passwordController ,
                decoration: InputDecoration(
                  contentPadding:
                  new EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
                  labelText: 'Password',
                  fillColor: Colors.white,
                  border: new OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(15.0),
                    borderSide: new BorderSide(),
                  ),
                ),
                keyboardType: TextInputType.visiblePassword,

                // do not force phone no here
                /*              validator: (value) => value.isEmpty
                    ? 'Phone number can\'t be empty'
                    : null,

   */
                onSaved: (value) {
                  if (value != null) {
                    //.contactInfomation.phonenumber = value.trim()
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future   _sineIn(String sine, String pas) async {

    var msg = '$sine[]#$pas';
    if( !sine.contains('BSIA')) {
      msg = 'BSIA';
    }

    final http.Response response = await http.post(
        Uri.parse(gbl_settings.apiUrl + "/authenticate"),
        headers: {
          'Content-Type': 'application/json',
          'Videcom_ApiKey': gbl_settings.apiKey
        },
        body: msg);

    if (response.statusCode == 200) {
//      Map map = json.decode(response.body);
//      LoginResponse loginResponse = new LoginResponse.fromJson(map);
  //    if (loginResponse.isSuccessful) {
        print('successful login');
    //    return loginResponse.getSession();
      //}
    } else {
      print('failed');
      //return  LoginResponse();
    }


  }
}
