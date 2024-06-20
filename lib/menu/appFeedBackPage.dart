
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:vmba/data/repository.dart';
import 'package:vmba/utilities/helper.dart';
import 'package:vmba/data/globals.dart';
import 'package:vmba/components/trText.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vmba/components/selectLang.dart';
import 'package:vmba/calendar/TabPage.dart';
import 'package:vmba/utilities/timeHelper.dart';

import '../controllers/vrsCommands.dart';
import '../utilities/messagePages.dart';
import '../utilities/widgets/appBarWidget.dart';

class AppFeedBackPage extends StatefulWidget {
  AppFeedBackPage({Key key= const Key("appfeed_key"), required this.version}) : super(key: key);
  final String version;

  _AppFeedBackPageState createState() => _AppFeedBackPageState();
}

class _AppFeedBackPageState extends State<AppFeedBackPage> {

  List<Widget> render() {
    List<Widget> widgets = [];
    // List<Widget>();
    String email;

    email = gblSettings.appFeedbackEmail;

    textSpliter(
            translate('We’re interested in how we can improve our app. Please email specific app feedback to'))
        .forEach((widget) {
      widgets.add(widget);
    });
    widgets.add(appLinkWidget(
        'mailto',
        email ,
        Text(email,
            style: TextStyle(
              decoration: TextDecoration.underline,
            )),
            queryParameters: {'subject': 'AppFeedback'+ widget.version}
    )
    );

    return widgets;
  }

  bool _displayProcessingIndicator = false;
  String _displayProcessingText = 'Changing settings...';
  GlobalKey<ScaffoldState> _key = GlobalKey();

  @override
  initState() {
    super.initState();
    _displayProcessingIndicator = false;
  }

  @override
  Widget build(BuildContext context) {
    if (_displayProcessingIndicator) {
      return Scaffold(
        key: _key,
        appBar: new AppBar(
          leading: getAppBarLeft(),
          backgroundColor:
          gblSystemColors.primaryHeaderColor,
          iconTheme: IconThemeData(
              color: gblSystemColors.headerTextColor),
          title: new TrText('App Feedback',
              style: TextStyle(
                  color:
                  gblSystemColors.headerTextColor)),
        ),
        body: new Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              new CircularProgressIndicator(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: new Text(_displayProcessingText),
              ),
            ],
          ),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          leading: getAppBarLeft(),
          backgroundColor:
          gblSystemColors.primaryHeaderColor,
          iconTheme: IconThemeData(
              color: gblSystemColors.headerTextColor),
          title: TrText('App Feedback',
              style: TextStyle(
                  color:
                  gblSystemColors.headerTextColor)),
          automaticallyImplyLeading: false,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 16, 8, 8),
          child: Column(
            children: <Widget>[
              Wrap(
                children: render(),
              ),
              Padding(
                padding: EdgeInsets.all(8),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(translate('App version: ') + widget.version + '  GMT:${getGmtTime().toString().substring(0,16)}'),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextButton(
                  onLongPress: () async {

                    showLogin(context);
                  },
                  child: Container(),
                  onPressed: () {},
                ),
              ),
               (gblSecurityLevel > 90 ) ? _getSinedInOptions()
/*               Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                  child: TrText('Sined in' ),)
                  */
       : Text(gblError),

            ],
          ),
        ),
      );
    }
    // });
  }
  Widget _getSinedInOptions() {
    return _getSinedIn();
  }


  Widget _getSinedIn() {
    String title = 'Status: Connected to ';
    String btnText = 'Connect to ';
    IconData ico = Icons.android_outlined;
    if (gblIsLive == true ){
      title += 'Live';
      btnText += 'Test';
    } else {
      title += 'Test';
      btnText += 'Live';
    }
    if(gblIsIos ) {
      ico = Icons.person_outline;
    }
    return Center(
      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: Icon(ico),
              title: new TrText( 'Sined In: ' + gblSine),
              subtitle: Text(title),
            ),

            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                TextButton(
                  style: TextButton.styleFrom(
                      side: BorderSide(color:  gblSystemColors.textButtonTextColor, width: 1),
                      foregroundColor: gblSystemColors.textButtonTextColor),
                  child: TrText(btnText),
                  onPressed: () {_swapLiveTest();},
                ),


                //const SizedBox(width: 8),
                TextButton(
                  style: TextButton.styleFrom(
                      side: BorderSide(color:  gblSystemColors.textButtonTextColor, width: 1),
                      foregroundColor: gblSystemColors.textButtonTextColor),
                  child: TrText('Reset cache'),
                  onPressed: () {
                    _resetLangs();
                    deleteLang();
                    },

                ),

                //const SizedBox(width: 8),
                TextButton(
                  style: TextButton.styleFrom(
                      side: BorderSide(color:  gblSystemColors.textButtonTextColor, width: 1),
                      foregroundColor: gblSystemColors.textButtonTextColor),
                  child: TrText('Delete Notifications'),
                  onPressed: () {

                    Repository.get().deleteNotifications();
                  },

                ),


                //const SizedBox(width: 8),
                TextButton(
                  style: TextButton.styleFrom(
                      side: BorderSide(color:  gblSystemColors.textButtonTextColor, width: 1),
                      foregroundColor: gblSystemColors.textButtonTextColor),
                  child: TrText('Demo Page'),
                  onPressed: () {
                    Navigator.push(
                      context, SlideTopRoute(page: TabPage())
                    );
                  },

                ),

                TextButton(
                  style: TextButton.styleFrom(
                      side: BorderSide(color:  gblSystemColors.textButtonTextColor, width: 1),
                      foregroundColor: gblSystemColors.textButtonTextColor),
                  child: TrText('Error msg'),
                  onPressed: () {
                    criticalErrorPage(context, 'this is a test error message', title: 'Error title');
                  },
                ),

                TextButton(
                  style: TextButton.styleFrom(
                      side: BorderSide(color:  gblSystemColors.textButtonTextColor, width: 1),
                      foregroundColor: gblSystemColors.textButtonTextColor),
                  child: TrText('Success msg'),
                  onPressed: () {
                    successMessagePage(context, 'this is a test success message', title: 'Booking Confirmed');
                  },
                ),

                TextButton(
                  style: TextButton.styleFrom(
                      side: BorderSide(color:  gblSystemColors.textButtonTextColor, width: 1),
                      foregroundColor: gblSystemColors.textButtonTextColor),
                  child: TrText('Progress msg'),
                  onPressed: () {
                    progressMessagePage(context, 'this is a progress message', title: 'loading');

                    Timer(Duration(seconds: 3), () {
                      setProgressMessage('3 seconds');
                    });
                    Timer(Duration(seconds: 10), () {
                      endProgressMessage();
                    });
                  },
                ),

              ],
            ),


          ],
        ),
      ),
    );
  }
  void _resetLangs() async {
    var prefs = await SharedPreferences.getInstance();
    // reset
    prefs.setString('language_code', '');
    prefs.setString('cache_time2', '');
    setState(() {
    });
  }

  void _swapLiveTest() {
    gblIsLive = !gblIsLive;

    // cannot reuse session after swap
    gblSession = null;

    if(gblIsLive == true) {
      gblSettings.xmlUrl = gblSettings.liveXmlUrl;
      gblSettings.apisUrl = gblSettings.liveApisUrl;
      gblSettings.apiUrl = gblSettings.liveApiUrl;
      gblSettings.smartApiUrl = gblSettings.liveSmartApiUrl;
      gblSettings.creditCardProvider  = gblSettings.liveCreditCardProvider;
    } else {
      gblSettings.xmlUrl = gblSettings.testXmlUrl;
      gblSettings.apisUrl = gblSettings.testApisUrl;
      gblSettings.apiUrl = gblSettings.testApiUrl;
      gblSettings.smartApiUrl = gblSettings.testSmartApiUrl;
      gblSettings.creditCardProvider  = gblSettings.testCreditCardProvider;
    }

    setState(() {

    });
  }

  void processCompleted() {
    setState(() {
      _displayProcessingIndicator = false;
    });
  }

  /*
  Future updateSettings() async {
    Repository.get().getUserProfile().then((userProfileRecordList) async {
      String firstName;
      if (userProfileRecordList.length > 0) {
        firstName = userProfileRecordList
            .firstWhere((v) => v.name == 'firstname')
            .value;
        if (firstName == 'TEST') {
          GobalSettings.shared.setToTest();
          await Repository.get().getSettingsFromApi();
          await Repository.get()
              .database
              .saveAllSettings(gbl_settings);
        } else if (firstName == 'LIVE') {
          GobalSettings.shared.setToLive();
          await Repository.get().getSettingsFromApi();
          await Repository.get()
              .database
              .saveAllSettings(gbl_settings);
        } else if (firstName == 'CLEAR') {
          await Repository.get().database.deleteAllSettings();
        }
      } else {
        processCompleted();
      }
    }).then((_) => processCompleted());
  }

   */

  showLogin(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
              children:[
/*
                Image.network('${gblSettings.gblServerFiles}/images/lock_user_man.png',
                  width: 50, height: 50, fit: BoxFit.contain,),
*/
                TrText('LOGIN')
              ]
          ),
          content: contentBox(context),
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black12) ,
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
                _sineIn(sine,pas).then( (result) {
                  setState(() {

                });
                  });
                Navigator.of(context).pop();
/*                Navigator.of(context).pushNamedAndRemoveUntil(
                    '/HomePage', (Route<dynamic> route) => false);*/
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
                  labelText: 'Sine (4ch)  ',
                  fillColor: Colors.white,
                  border: new OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(15.0),
                    borderSide: new BorderSide(),
                  ),
                ),
                controller: _sineController,
                keyboardType: TextInputType.number ,

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
                obscureText: true,
                obscuringCharacter: "*",
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

  Future <String>  _sineIn(String sine, String pas) async {

    // check for debug mode
    if( gblSettings.debugUser != null && gblSettings.debugUser.isNotEmpty &&
        gblSettings.debugPassword != null  && gblSettings.debugPassword.isNotEmpty){

        if( sine == gblSettings.debugUser && pas == gblSettings.debugPassword){
          gblDebugMode = true;

          Navigator.of(context).pushNamedAndRemoveUntil(
              '/HomePage', (Route<dynamic> route) => false);
          return 'OK';
        }
    }


    setError( '');
    var msg = 'zua[sine=$sine,pwd=$pas]~X';

    String data = await runVrsCommand(msg);
    if (data != null) {
      try {
        String str = data
            .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
            .replaceAll('<string xmlns="http://videcom.com/">', '')
            .replaceAll('\r\n', '')
            .replaceAll('</string>', '');
        if( !str.startsWith('{')) {
          print(str);
          setError('not found or bad password');
          return gblError;
        }
        Map map = json.decode(str);
        //String settingsString = map["zua"];
        Map settingsMap = map["zua"]; // List <dynamic> settingsJson
        if( settingsMap['sineresult'] != null ) {
          Map sineMap = settingsMap['sineresult'];

          if (sineMap['securitylevel'] == '' ||
              sineMap['securitylevel'] == '0') {
            setError('not found or bad password');
            return gblError;
          }
          if (sineMap['agentsuspended']
              .toString()
              .isEmpty || sineMap['agentsuspended'] == '1') {
            // failed,
            setError('SUSPENDED');
            return gblError;
          }
          if (sineMap['Restricted']
              .toString()
              .isNotEmpty && sineMap['Restricted'] != '0') {
            // failed,
            setError('RESTRICTED');
            return gblError;
          }
          gblSecurityLevel = int.parse(sineMap['securitylevel'].toString());
        }

        gblSine = sine;
        //gblMobileFlags = sineMap['mobileflags'];
        if( gblVerbose == true ) {print('successful login'); }
        return 'OK';
      } catch (e) {
        print(e);
      }
    } else {
      print('failed');
      //return  LoginResponse();
    }
    return 'OK';
  }


}
