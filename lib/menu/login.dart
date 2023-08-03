
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:vmba/data/globals.dart';
import 'package:vmba/data/models/models.dart';
import 'package:vmba/components/trText.dart';
import 'package:vmba/data/repository.dart';
import 'package:vmba/utilities/helper.dart';

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

  Future _checkAdsLogin() async {

    try {
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





