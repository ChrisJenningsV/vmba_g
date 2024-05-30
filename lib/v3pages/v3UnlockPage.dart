import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:vmba/v3pages/fields/Pax.dart';

import '../components/trText.dart';
import '../components/vidButtons.dart';
import '../data/globals.dart';
import '../data/models/vrsRequest.dart';
import '../data/smartApi.dart';
import '../utilities/helper.dart';

class UnlockPage extends  StatefulWidget {
  UnlockPage({Key key= const Key("MyUnloc_key")}): super(key: key);


  UnlockPageState createState() => UnlockPageState();

}


class UnlockPageState extends State<UnlockPage> {
  bool _isButtonDisabled= false;
  bool _isPart2 = false;
  final formKey = new GlobalKey<FormState>();

  TextEditingController emailTextEditingController =   TextEditingController();
  List<TextEditingController> faEditingController =   [TextEditingController(),TextEditingController(),TextEditingController(),
    TextEditingController(),TextEditingController(),TextEditingController()];

  @override
  void initState() {
    //WidgetsBinding.instance.addPostFrameCallback((_) =>FocusScope.of(context).requestFocus(_focusNode));
//      Timer(const Duration(milliseconds: 1000), () {_focusNode.requestFocus();});
  }

  @override
  Widget build(BuildContext context) {

    Widget flexibleSpace = Padding(padding: EdgeInsets.all(30,));

flexibleSpace = Image.network('${gblSettings.gblServerFiles}/pageImages/unlock.png',
    errorBuilder: (BuildContext context,Object obj,  StackTrace? stackTrace) {
      return Text('', style: TextStyle(color: Colors.red));}
      ); // Image Error.

return  Scaffold(
    body:
    Column (
        children: [
          flexibleSpace,
          AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0))),
            titlePadding: EdgeInsets.only(top: 0),
            contentPadding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 0),
            title: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: gblSystemColors.primaryButtonColor,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0),)),
                padding: EdgeInsets.only(left: 10, top: 10, bottom: 10),
                child: Text(_isPart2 == false ? 'Unlock' : 'Validate Email Address',
                  style: TextStyle(color: Colors.white),)
            ),
            content: contentBox(context),
            //actions: <Widget>[)    ]
          ),
        ])
);


  }
    contentBox(context){
      List<Widget> contentList = [];
      contentList.add(Text('Sign in to access details of bookings made on the website '));
      if( _isPart2 == false ) {
        contentList.add(paxGetEmail(
            emailTextEditingController, onFieldSubmitted: (value) {},
            onSaved: (value) {},autofocus:true));
      } else {
        //contentList.add( SplitInput(format:'1d 1d 1d 1d 1d 1d') );
        contentList.add( pax2faNumber(context, faEditingController, onFieldSubmitted: (value) {},
            onSaved: (value) {},autofocus:true ));
      }

      contentList.add(SizedBox(height: 15,));
      contentList.add(Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
      vidCancelButton( context, "CANCEL", (context) {
      //
      Navigator.of(context).pop();
      },
      ),
      SizedBox(width: 20,),
      ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: gblSystemColors.primaryButtonColor,),
        child: Row(children: <Widget>[
      (_isButtonDisabled)
          ? new Transform.scale( scale: 0.5, child: CircularProgressIndicator(), )
              : Icon(Icons.check,color: Colors.white,),
          _isButtonDisabled
          ? new TrText("Logging in...",
          style: TextStyle(color: Colors.white))
              : TrText('CONTINUE', style: TextStyle(color: Colors.white))
          ]),
          onPressed: () {
            final form = formKey.currentState;
            if (form!.validate()) {
              _isButtonDisabled = true;
              sendUnlockMsg( emailTextEditingController.text);
              _isPart2 = true;
              setState(() {

              });
            }
      //});

      //Navigator.of(context).pop();
      },
      ),
      ])
      );

      return
        SizedBox(
            width: MediaQuery.of(context).size.width,
            child:
                Form(
                    key: formKey,
                  child:
            Stack(
              children: <Widget>[ Column(
                mainAxisSize: MainAxisSize.min,
                children: contentList
              )],
            )
        )
        );
    }
}

Future<void> sendUnlockMsg(String email ) async {
  gblValidationPin = generatePin();
  ValidateEmailRequest rq = ValidateEmailRequest(email: email, pin: gblValidationPin);

  String data = json.encode(rq);
   String rx = await callSmartApi('VALIDATEEMAIL', data);

}
String generatePin(){
  String val = '';
  for (int i = 0; i< 6;i++){
    val += Random().nextInt(9).toString();
  }
  return val;

}