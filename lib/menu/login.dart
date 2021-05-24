import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:vmba/data/globals.dart';
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
  String descriptions = 'descriptions';
  TextEditingController _sineController;
  TextEditingController _passwordController;

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        brightness: gblSystemColors.statusBar,
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

  contentBox(context){
    return Stack(
      children: <Widget>[
        Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(title,style: TextStyle(fontSize: 22,fontWeight: FontWeight.w600),),
              SizedBox(height: 15,),
              new TextFormField(
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
                  labelText: 'Pin',
                  fillColor: Colors.white,
                  border: new OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(15.0),
                    borderSide: new BorderSide(),
                  ),
                ),
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
        onPressed: () => Navigator.pop(context, ''),
        child: Text(
          'LOGIN',
          style: new TextStyle(color: Colors.white),
        ));
  }

}






