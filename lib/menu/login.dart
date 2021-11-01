import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:vmba/data/globals.dart';
import 'package:vmba/data/models/models.dart';
import 'dart:ui';
import 'package:vmba/components/trText.dart';

class Constants{
  Constants._();
  static const double padding =20;
  static const double avatarRadius =45;
}

class LoginPage extends StatefulWidget {
  LoginPage(
      {Key key})
      : super(key: key);

  _LoginPageState createState() => _LoginPageState();

}


class _LoginPageState extends State<LoginPage> {
  String title = 'Login';
  String _error;
  String descriptions = 'descriptions';
  TextEditingController _adsNumberTextEditingController = TextEditingController();
  TextEditingController _adsPinTextEditingController = TextEditingController();

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        //brightness: gblSystemColors.statusBar,
        backgroundColor: gblSystemColors.primaryHeaderColor,
        iconTheme: IconThemeData(
            color: gblSystemColors.headerTextColor),
        title: new TrText('Air Discount Scheme',
            style: TextStyle(
                color:
                gblSystemColors.headerTextColor)),
      ),
      body: contentBox(context),
    );
  }

  contentBox(context) {
    return Stack(
      children: <Widget>[
        Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(title,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),),
              SizedBox(height: 15,),
              new TextFormField(
                maxLength: 20,
                decoration: InputDecoration(
                  contentPadding:
                  new EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
                  labelText: 'Number',
                  fillColor: Colors.white,
                  border: new OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(15.0),
                    borderSide: new BorderSide(),
                  ),
                ),
                controller: _adsNumberTextEditingController,
                keyboardType: TextInputType.streetAddress,

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
                maxLength: 4,
                controller: _adsPinTextEditingController,
                decoration: InputDecoration(
                  contentPadding:
                  new EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
                  labelText: 'Pin',
                  fillColor: Colors.white,
                  border: new OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(15.0),
                    borderSide: new BorderSide(),
                  ),
                ),
                keyboardType: TextInputType.number,

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
              SizedBox(height: 22,),
              Align(
                alignment: Alignment.center,
                child: _getOkButton(),
              ),
            ],
          ),
        ),
        /* Positioned(
          left: Constants.padding,
          right: Constants.padding,
          child: CircleAvatar(
            backgroundColor: Colors.transparent,
            radius: Constants.avatarRadius,
            child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(Constants.avatarRadius)),
                child: Image.asset("assets/model.jpeg")
            ),
          ),

        ),
        */
      ],
    );
  }


  ElevatedButton _getOkButton() {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            primary: Colors.black),
        onPressed: () {
          _checkAdsLogin();
        },
        child: Text(
          'LOGIN',
          style: new TextStyle(color: Colors.white),
        ));
  }

  Future _checkAdsLogin() async {
    http.Response response = await http
        .get(Uri.parse(
        "${gblSettings.xmlUrl}${gblSettings
            .xmlToken}&command=ZADSVERIFY/${_adsNumberTextEditingController
            .text}/${_adsPinTextEditingController.text}'"))
        .catchError((resp) {
      print(resp);
    });

    if (response == null) {
      //return new ParsedResponse(NO_INTERNET, []);
    }

    //If there was an error return an empty list
    if (response.statusCode < 200 || response.statusCode >= 300) {
      //return new ParsedResponse(response.statusCode, []);
    }
    String adsJson;
    try {
      adsJson = response.body
          .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
          .replaceAll('<string xmlns="http://videcom.com/">', '')
          .replaceAll('</string>', '');

      Map map = json.decode(adsJson);

      if (map['VrsServerResponse']['data']['ads']['users']['user']['isvalid'] ==
          'true') {
        print('Login success');
        Navigator.of(context).pushNamedAndRemoveUntil(
            '/AdsFlightSearchPage', (Route<dynamic> route) => false);

        if( gblPassengerDetail == null ) {
          gblPassengerDetail = new PassengerDetail( email:  '', phonenumber: '');
        }
        gblPassengerDetail.adsNumber = _adsNumberTextEditingController.text;
        gblPassengerDetail.adsPin = _adsPinTextEditingController.text;
      } else {
        _error = 'Ads login failed - check details and try again';
        _showDialog();
      }
    } catch (e) {
      _error = adsJson;
      _showDialog();
      print(e);
    }
  }


  void _showDialog() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Error"),
          content: _error != null && _error != ''
              ? new Text(_error)
              : new Text("Please try again"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new TextButton(
              child: new Text("Close"),
              onPressed: () {
                _error = '';

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

}





