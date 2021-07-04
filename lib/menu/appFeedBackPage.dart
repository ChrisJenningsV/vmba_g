import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:vmba/utilities/helper.dart';
import 'package:vmba/data/globals.dart';
import 'package:vmba/components/trText.dart';

class AppFeedBackPage extends StatefulWidget {
  AppFeedBackPage({Key key, this.version}) : super(key: key);
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
            'We’re interested in how we can improve our app. Please email specific app feedback to')
        .forEach((widget) {
      widgets.add(widget);
    });
    widgets.add(appLinkWidget(
        'mailto:' + email + '?subject=AppFeedback ' + widget.version,
        Text(email,
            style: TextStyle(
              decoration: TextDecoration.underline,
            ))));

    return widgets;
  }

  bool _displayProcessingIndicator;
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
          leading: Padding(
              padding: EdgeInsets.only(left: 10.0),
              child: Image.asset(
                  'lib/assets/$gblAppTitle/images/appBarLeft.png',
                  color: Color.fromRGBO(255, 255, 255, 0.1),
                  colorBlendMode: BlendMode.modulate)),
          brightness: gblSystemColors.statusBar,
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
          leading: Padding(
              padding: EdgeInsets.only(left: 10.0),
              child: Image.asset(
                  'lib/assets/$gblAppTitle/images/appBarLeft.png',
                  color: Color.fromRGBO(255, 255, 255, 0.1),
                  colorBlendMode: BlendMode.modulate)),
          brightness: gblSystemColors.statusBar,
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
                child: TrText('App version: ' + widget.version),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextButton(
                  onLongPress: () async {

                    showLogin(context);
                  },
                  child: null,
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
              title: new Text( 'Sined In: ' + gblSine),
              subtitle: Text(title),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                TextButton(
                  style: TextButton.styleFrom(
                      side: BorderSide(color:  gblSystemColors.textButtonTextColor, width: 1),
                      primary: gblSystemColors.textButtonTextColor),
                  child: gblNewDatepicker ?  Text('Old Datepicker') : Text('New Datepicker') ,
                  onPressed: () {
                    gblNewDatepicker = !gblNewDatepicker;
                    setState(() {

                    });
                  },
                ),
                const SizedBox(width: 8),

                TextButton(
                  style: TextButton.styleFrom(
                      side: BorderSide(color:  gblSystemColors.textButtonTextColor, width: 1),
                      primary: gblSystemColors.textButtonTextColor),
                  child: Text(btnText),
                  onPressed: () {_swapLiveTest();},
                ),


                const SizedBox(width: 8),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _swapLiveTest() {
    gblIsLive = !gblIsLive;

    if(gblIsLive == true) {
      gblSettings.xmlUrl = gblSettings.liveXmlUrl;
      gblSettings.apisUrl = gblSettings.liveApisUrl;
      gblSettings.apiUrl = gblSettings.liveApiUrl;
      gblSettings.creditCardProvider  = gblSettings.liveCreditCardProvider;
    } else {
      gblSettings.xmlUrl = gblSettings.testXmlUrl;
      gblSettings.apisUrl = gblSettings.testApisUrl;
      gblSettings.apiUrl = gblSettings.testApiUrl;
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
                Image.network('https://customertest.videcom.com/videcomair/vars/public/test/images/lock_user_man.png',
                  width: 50, height: 50, fit: BoxFit.contain,),
                TrText('LOGIN')
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
                _sineIn(sine,pas).then( (result) {
                  setState(() {

                });
                  });


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
    gblError = '';
    var msg = 'zua[sine=$sine,pwd=$pas]~X';
    /*   if( !sine.contains('BSIA')) {
      msg = 'BSIA';
    }

  */

    http.Response response = await http
        .get(Uri.parse(
        "${gblSettings.xmlUrl}${gblSettings.xmlToken}&command=$msg"))
        .catchError((resp) {
      print(resp);
    });

    if (response.statusCode == 200) {
      try {
        String str = response.body
            .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
            .replaceAll('<string xmlns="http://videcom.com/">', '')
            .replaceAll('</string>', '');
        Map map = json.decode(str);
        //String settingsString = map["zua"];
        Map settingsMap = map["zua"]; // List <dynamic> settingsJson
        Map sineMap = settingsMap['sineresult'];

        if (sineMap['securitylevel'] =='' || sineMap['securitylevel'] == '0') {
          gblError = 'not found or bad password';
          return gblError;
        }
        if (sineMap['agentsuspended']
            .toString()
            .isEmpty || sineMap['agentsuspended'] == '1') {
          // failed,
          gblError = 'SUSPENDED';
          return gblError;
        }
        if (sineMap['Restricted']
            .toString()
            .isNotEmpty && sineMap['Restricted'] != '0') {
          // failed,
          gblError = 'RESTRICTED';
          return gblError;
        }


        gblSine = sine;
        gblMobileFlags = sineMap['mobileflags'];
        gblSecurityLevel = int.parse(sineMap['securitylevel'].toString());
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
