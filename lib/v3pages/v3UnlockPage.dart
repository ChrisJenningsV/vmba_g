import 'package:flutter/material.dart';
import 'package:vmba/Managers/PaxManager.dart';
import 'package:vmba/utilities/navigation.dart';
import 'package:vmba/v3pages/fields/Pax.dart';
import 'package:vmba/v3pages/v3Theme.dart';

import '../components/showDialog.dart';
import '../components/trText.dart';
import '../components/vidButtons.dart';
import '../data/globals.dart';
import '../data/repository.dart';
import '../utilities/helper.dart';

class UnlockPage extends  StatefulWidget {
  UnlockPage({Key key= const Key("MyUnloc_key")}): super(key: key);


  UnlockPageState createState() => UnlockPageState();

}
bool unlockIsPart2 = false;
late bool _isButtonDisabled;

class UnlockPageState extends State<UnlockPage> {

/*
  final formKey = new GlobalKey<FormState>();
*/

/*
  TextEditingController emailTextEditingController = TextEditingController();
  List<TextEditingController> faEditingController = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController()
  ];
*/

  @override
  void initState() {
    //WidgetsBinding.instance.addPostFrameCallback((_) =>FocusScope.of(context).requestFocus(_focusNode));
//      Timer(const Duration(milliseconds: 1000), () {_focusNode.requestFocus();});
    _isButtonDisabled = false;
  }

  @override
  Widget build(BuildContext context) {
    Widget flexibleSpace = Padding(padding: EdgeInsets.all(30,));

    flexibleSpace =
        Image.network('${gblSettings.gblServerFiles}/pageImages/unlock.png',
            errorBuilder: (BuildContext context, Object obj,
                StackTrace? stackTrace) {
              return Text('', style: TextStyle(color: Colors.red));
            }
        ); // Image Error.

    return Scaffold(
        body:
        Column(
            children: [
              flexibleSpace,
              AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0))),
                titlePadding: EdgeInsets.only(top: 0),
                contentPadding: EdgeInsets.only(
                    left: 15, right: 15, top: 5, bottom: 0),
                title: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: gblSystemColors.primaryHeaderColor,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10.0),
                          topRight: Radius.circular(10.0),)),
                    padding: EdgeInsets.only(left: 10, top: 10, bottom: 10),
                    child: Text(
                      unlockIsPart2 == false ? 'Unlock' : 'Validate Email Address',
                      style: TextStyle(color: Colors.white),)
                ),
                content: getUnlockDlg(context, () {
                  setState(() => null);
                }),
                //actions: <Widget>[)    ]
              ),
            ])
    );
  }
}
/*

  Future<void> sendUnlockMsg(BuildContext context, String email, void Function() doCallback) async {
    try {
      gblValidationPin2 = gblValidationPin;
      gblValidationPin = generatePin();
      ValidateEmailRequest rq = ValidateEmailRequest(
          email: email, pin: gblValidationPin);

      String data = json.encode(rq);

      String rx = await callSmartApi('VALIDATEEMAIL', data);
      String ok = rx;
      //String ok = await sendValidateEmailMsg(email, gblValidationPin);
      if (ok != 'OK') {
        showVidDialog(context, 'Error', ok);
      } else {
        _isButtonDisabled = false;
        unlockIsPart2 = true;
        doCallback();
      }
    } catch(e) {
      String er= e.toString();
    }
  }
*/

/*
void setState(Null Function() param0) {
}
*/
TextEditingController emailTextEditingController = TextEditingController();
List<TextEditingController> faEditingController = [
  TextEditingController(),
  TextEditingController(),
  TextEditingController(),
  TextEditingController(),
  TextEditingController(),
  TextEditingController()
];

getUnlockDlg(BuildContext context, void Function() doCallback, {bool? isStep1}) {
  //final formKey = new GlobalKey<FormState>();
  if( isStep1 != null && isStep1 == true){
    _isButtonDisabled = false;
//    gblValidationPinTries = 0;
    isStep1 = true;
  }

  List<Widget> contentList = [];
  if (unlockIsPart2 == false) {
    contentList.add(
        Text('Sign in to access details of bookings made on the website.\n\n A validation PIN will be sent to this email.\n\n '));

    contentList.add(paxGetEmail(
        emailTextEditingController, onFieldSubmitted: (value) {},
        onSaved: (value) {}, /*autofocus: true*/));
  } else {
    contentList.add(
        Text('Please check youe email inbox, and enter the validation PIN below. '));
    //contentList.add( SplitInput(format:'1d 1d 1d 1d 1d 1d') );
    contentList.add(pax2faNumber(
        context, faEditingController, onFieldSubmitted: (value) {},
        onSaved: (value) {}, autofocus: true));

    if( gblValidationPinTries > 1) {
      contentList.add(VBodyText('${5 - gblValidationPinTries} tries left'));
    }
    contentList.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          vidIconButton(context,
            icon: Icons.arrow_back,
            onPressed: (context, i1, i2) {
              unlockIsPart2 = false;
              doCallback();
/*
              setState(() {});
*/
            }
          ),
        vidTextButton(context, 'Resend email',
            ({p1, p2, p3}) {
              logit('resend email');
              _isButtonDisabled = true;
              doCallback();
//              sendUnlockMsg(context, gblValidationEmail, doCallback);
              _isButtonDisabled = false;
              doCallback();

            })
          ]
    ));
  }

  contentList.add(SizedBox(height: 15,));
  contentList.add(Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
      /*  vidCancelButton(context, "CANCEL", (context) {
          //
          Navigator.of(context).pop();
        },
        ),
        SizedBox(width: 20,),*/
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: gblSystemColors.primaryButtonColor,),
          child: Row(children: <Widget>[
            (_isButtonDisabled)
                ? new Transform.scale(
              scale: 0.5, child: CircularProgressIndicator(),)
                : Icon(Icons.check, color: Colors.white,),
            _isButtonDisabled
                ? new TrText("Logging in...",
                style: TextStyle(color: Colors.white))
                : TrText('CONTINUE', style: TextStyle(color: Colors.white))
          ]),
          onPressed: () async {
    //        final form = formKey.currentState;
      //      if (form!.validate()) {
              if( unlockIsPart2) {
                gblValidationPinTries +=1;
                String pinInput = faEditingController[0].text +  faEditingController[1].text +  faEditingController[2].text +
                    faEditingController[3].text +  faEditingController[4].text +  faEditingController[5].text;
                if( pinInput == gblValidationPin || (gblValidationPin2 != '' && pinInput == gblValidationPin2 )){
                  // goto new member home page
                  //Navigator.push(context, SlideTopRoute(page: LoggedInHomePage()));
                  logit('PIN OK');
                  hideSnackBarMessage();
                  _isButtonDisabled = true;
                  doCallback();
                  PaxManager.populate(gblValidationEmail);
                  PaxManager.save();
                  await Repository.get().settings();
                  // save new email etc in my account
                  String firstName = '', lastName = '', title = '', dOB = '';
                  if( gblTrips != null &&  gblTrips!.trips != null && gblTrips!.trips!.length > 0){
                    firstName = gblTrips!.trips![0].firstname;
                    lastName = gblTrips!.trips![0].lastname;
                    title = gblTrips!.trips![0].title;
                    dOB = gblTrips!.trips![0].DOB;
                  }
                  PaxManager.populate(gblValidationEmail, firstName: firstName, title: title, lastName: lastName, dOB: dOB);
                  PaxManager.save();
                  navToHomepage(context);
                } else {
                  logit('bad PIN $gblValidationPinTries');
                  doCallback();
                  showSnackBar('PIN does not match [$pinInput] [$gblValidationPin] ', context,duration: Duration(minutes: 1),);
                  if( gblValidationPinTries >= 5) {
                    _isButtonDisabled = true;
                    doCallback();
                    hideSnackBarMessage();
                    navToHomepage(context);
                  } else {
                    hideSnackBarMessage();
                    showSnackBar('PIN does not match [$pinInput] [$gblValidationPin] ', context,duration: Duration(minutes: 1),);
                  }
                }
              } else {
                gblValidationPinTries +=1;
                String value = emailTextEditingController.text;
                String er = validateEmail(value.trim());
                if( er == '') {
                  gblValidationEmail = value.trim();
                  _isButtonDisabled = true;
                  unlockIsPart2 = true;
                  doCallback();
//                  sendUnlockMsg(context, value, doCallback);
                } else {
                  showVidDialog(context, 'Error', 'Please enter valid email address');
                }
              }
        //    }
            //});

            //Navigator.of(context).pop();
          },
        ),
      ])
  );

  return
    SizedBox(
        width: MediaQuery
            .of(context)
            .size
            .width,
        child: Padding( padding: EdgeInsets.all(15),
        child:/* Form(
            key: formKey,
            child:*/
           /* Stack(*/
               Column(
                  mainAxisSize: MainAxisSize.min,
                  children: contentList
              )
            )
        //)
    );
}
/*

String generatePin(){
  String val = '';

  String v1= Random().nextInt(9).toString();
  String v2= Random().nextInt(9).toString();
  String v3= Random().nextInt(9).toString();
  String v4= Random().nextInt(9).toString();

  val = v1 + v2 + v3 + v1 + v4 + v3;

  return val;

}*/
