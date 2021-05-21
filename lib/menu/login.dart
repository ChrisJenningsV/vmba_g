import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:vmba/data/repository.dart';
import 'package:vmba/data/globals.dart';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:vmba/data/models/models.dart';
import 'package:vmba/data/models/user_profile.dart';
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
  String descriptions = 'descriptions';
  TextEditingController _sineController;
  TextEditingController _passwordController;

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
       title: Row(

        children:[ TrText('Login', style: TextStyle( backgroundColor: gblSystemColors.primaryHeaderColor, color: gblSystemColors.headerTextColor), )]
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Constants.padding),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      content: contentBox(context),
    );
  }

  contentBox(context){
    return Stack(
      children: <Widget>[
        Container(
 /*         padding: EdgeInsets.only(left: Constants.padding,top: Constants.avatarRadius
              + Constants.padding, right: Constants.padding,bottom: Constants.padding
          ),
          margin: EdgeInsets.only(top: Constants.avatarRadius),
          decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: Colors.white,
              borderRadius: BorderRadius.circular(Constants.padding),
              boxShadow: [
                BoxShadow(color: Colors.black,offset: Offset(0,10),
                    blurRadius: 10
                ),
              ]
          ),

  */
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(title,style: TextStyle(fontSize: 22,fontWeight: FontWeight.w600),),
              SizedBox(height: 15,),
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
              SizedBox(height: 22,),
              Align(
                alignment: Alignment.bottomRight,
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
        onPressed: () => Navigator.pop(context, ''),
        child: Text(
          'OK',
          style: new TextStyle(color: Colors.white),
        ));
  }

}






