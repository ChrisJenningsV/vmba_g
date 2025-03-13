
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:vmba/components/pageStyleV2.dart';
import 'package:vmba/data/globals.dart';
import 'package:vmba/data/models/models.dart';
import 'package:vmba/components/trText.dart';
import 'package:vmba/data/repository.dart';
import 'package:vmba/utilities/helper.dart';

import '../Helpers/settingsHelper.dart';
import '../components/vidButtons.dart';
import '../v3pages/cards/typogrify.dart';
import '../v3pages/controls/V3AppBar.dart';
import '../v3pages/controls/V3Constants.dart';

//ADS40 00 00 02 09 095
//Pin: 9831


class Constants{
  Constants._();
  static const double padding =20;
  static const double avatarRadius =45;
}

class LoginPage extends StatefulWidget {
  LoginPage(
      {Key key= const Key("loginpa_key")})
      : super(key: key);

  _LoginPageState createState() => _LoginPageState();

}


class _LoginPageState extends State<LoginPage> {
  String title = 'Login';
  String _error='';
  bool _btnDisabled=false;
  String descriptions = 'descriptions';
  TextEditingController _adsNumberTextEditingController = TextEditingController();
  TextEditingController _adsPinTextEditingController = TextEditingController();

  @override
  initState() {
    super.initState();
    _btnDisabled = false;

    if( gblPassengerDetail != null ){
      _adsNumberTextEditingController.text = gblPassengerDetail!.adsNumber;
      _adsPinTextEditingController.text = gblPassengerDetail!.adsPin;

    }
    //


  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: V3AppBar( PageEnum.dayPicker,
        //backgroundColor: gblSystemColors.primaryHeaderColor,
/*
        iconTheme: IconThemeData(
            color: gblSystemColors.headerTextColor),
*/
        title: new TrText('ADS / Island Resident Scheme',
            style: TextStyle(
                color:
                gblSystemColors.headerTextColor)),
      ),
      body: contentBox(context),
        floatingActionButton:  wantHomePageV3() ? vidWideActionButton(context,'Log in', _doAdsLogin , offset: 35.0 ) : null,
    );
  }

  contentBox(context) {
    return Padding(padding: EdgeInsets.all(10),
        child: Stack(
      children: <Widget>[
        Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              inPageTitleText(title),
/*
              Text(title,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),),
*/
              SizedBox(height: 15,),
          v2BorderBox(context,  ' ' + translate('Number'),
              TextFormField(
                maxLength: 20,
                decoration: v2Decoration(),

                controller: _adsNumberTextEditingController,
                keyboardType: TextInputType.streetAddress,
                onSaved: (value) {
                  if (value != null) {
                    //.contactInfomation.phonenumber = value.trim()
                  }
                },
              )),
              SizedBox(height: 15,),
              v2BorderBox(context,  ' ' + translate('Pin'),
                  TextFormField(
                maxLength: 4,
                controller: _adsPinTextEditingController,
                decoration:v2Decoration(),
                keyboardType: TextInputType.number,
                onSaved: (value) {
                  if (value != null) {
                    //.contactInfomation.phonenumber = value.trim()
                  }
                },
              )),
              SizedBox(height: 22,),
              wantHomePageV3() ? Container() : Align(
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
    )
    );
  }


  ElevatedButton _getOkButton() {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            foregroundColor: Colors.black),
        onPressed: () {
          if( _btnDisabled == false ) {
            _btnDisabled = true;
            setState(() {

            });
            logit('logit clicked');
            _checkAdsLogin();
          }
        },
        child: _getBtnText()
        );
  }
  Widget _getBtnText() {
    List <Widget> list = [];

    if(_btnDisabled){
      list.add(new Transform.scale(
        scale: 0.5,
        child: CircularProgressIndicator(valueColor:AlwaysStoppedAnimation<Color>(Colors.white)),
      ));
    }
    list.add(Text(
      'LOGIN',
      style: new TextStyle(color: Colors.white),));
    return Row( mainAxisAlignment: MainAxisAlignment.center, children: list,);
  }

  void _doAdsLogin(BuildContext p1, dynamic p2){
    _checkAdsLogin();
  }


  Future _checkAdsLogin() async {

    try {
      logit('adsValidate L');
    String data = await runVrsCommand('ZADSVERIFY/${_adsNumberTextEditingController
        .text}/${_adsPinTextEditingController.text}');
    String adsJson;
      adsJson = data
          .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
          .replaceAll('<string xmlns="http://videcom.com/">', '')
          .replaceAll('</string>', '');

      Map map = json.decode(adsJson);

      if (map['VrsServerResponse']['data']['ads']['users']['user']['isvalid'] ==
          'true') {
        print('Login success');
        _btnDisabled = false;
        Navigator.of(context).pushNamedAndRemoveUntil(
            '/AdsFlightSearchPage', (Route<dynamic> route) => false);

        if( gblPassengerDetail == null ) {
          gblPassengerDetail = new PassengerDetail( email:  '', phonenumber: '');
        }
        gblPassengerDetail!.adsNumber = _adsNumberTextEditingController.text;
        gblPassengerDetail!.adsPin = _adsPinTextEditingController.text;
      } else {
        _btnDisabled = false;
        setState(() {

        });
        _error = 'Ads login failed - check details and try again';
        _showDialog();
      }
    } catch (e) {
      _btnDisabled = false;
      setState(() {

      });
      _error = e.toString();
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
          title: new TrText("Error"),
          content: _error != null && _error != ''
              ? new Text(_error)
              : new TrText("Please try again"),
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





