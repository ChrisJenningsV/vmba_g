
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:vmba/v3pages/cards/v3FormFields.dart';

import '../../components/showDialog.dart';
import '../../components/trText.dart';
import '../../components/vidButtons.dart';
import '../../controllers/vrsCommands.dart';
import '../../data/globals.dart';
import '../../data/models/models.dart';
import '../../data/models/vrsRequest.dart';
import '../../data/smartApi.dart';
import '../../utilities/helper.dart';
import '../../utilities/messagePages.dart';


class FqtvLoginBox extends StatefulWidget {
  PassengerDetail? passengerDetail;
  String joiningDate='';

  FqtvLoginBox();

  @override
  State<StatefulWidget> createState() => new FqtvLoginBoxState();
}

class FqtvLoginBoxState extends State<FqtvLoginBox> {
  TextEditingController _fqtvTextEditingController = TextEditingController();
  TextEditingController _passwordEditingController = TextEditingController();
  TextEditingController _oldPasswordEditingController =   TextEditingController();
  TextEditingController _newPasswordEditingController =   TextEditingController();
  String _error = '';
  String fqtvEmail = '';
  String fqtvNo = '';
  String fqtvPass='';

  bool _isHidden = true;
  bool _isButtonDisabled = false;
  bool _loadingInProgress = false;
  @override void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> list = [];

    list.add(Padding( padding: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
        child: V3TextFormField(
          '${gblSettings.fqtvName} ' + translate('number'),
           _fqtvTextEditingController,
      icon: Icons.numbers,
      keyboardType: TextInputType.number,
      onSaved: (value) {
        if (value != null) {
          //.contactInfomation.phonenumber = value.trim()
        }
      },
    ))
    );


    list.add( Padding( padding: EdgeInsets.only(left: 10, right: 10, top: 0, bottom: 10),
        child:  V3TextFormField(
          translate('Password'),
          _passwordEditingController,
      icon: Icons.lock,
      obscureText: _isHidden,
      obscuringCharacter: "*",

/*                  suffix: InkWell(
                    onTap: _togglePasswordView,
                    child: Icon( Icons.visibility),
                  ),
                ),*/
      keyboardType: TextInputType.visiblePassword,
      onSaved: (value) {
        if (value != null) {
          //.contactInfomation.phonenumber = value.trim()
        }
      },
    ))
    );


    list.add(Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        v3ActionButton( context,
            'Reset Password',
            (c) {
             resetPasswordDialog();
          },
            wantIcon: false,
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: gblSystemColors.primaryButtonColor),
          child: Row(children: <Widget>[
            (_isButtonDisabled)
                ? new Transform.scale(
              scale: 0.5,
              child: CircularProgressIndicator(),
            )
                : Icon(
              Icons.check,
              color: Colors.white,
            ),
            _isButtonDisabled
                ? new TrText("Logging in...",
                style: TextStyle(color: Colors.white))
                : TrText('CONTINUE', style: TextStyle(color: Colors.white))
          ]),
          onPressed: () {
                      if (_isButtonDisabled == false) {
                        if (_fqtvTextEditingController.text.isNotEmpty &&
                            _passwordEditingController.text.isNotEmpty) {
                          _isButtonDisabled = true;
                          _loadingInProgress = true;
                          //setState(() {});
                          _fqtvLogin();
                        } else {
                          _error = "Please complete both fields";
                          _loadingInProgress = false;
                          _isButtonDisabled = false;
                          // _actionCompleted();
                          showAlertDialog(context, 'Error', _error);
                        }
                      }
          },
        ),
      ],
    )
    );
    list.add(Divider( color: Colors.grey, height: 1,));
    list.add(TextButton(onPressed: (){

    }, child: TrText('Continue as Guest', style: TextStyle( fontSize: 18, fontWeight: FontWeight.bold),)));

    return Column(
      children: list,
    );
  }
  void resetPasswordDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            titlePadding: EdgeInsets.only(top: 0),
            title: Column(
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.person_pin, color: Colors.red, size: 40,),
                    title: TrText('Reset Password'),
                  ),
                  Divider(
                    color: Colors.grey,
                    height: 4.0,
                  ),
                ]),

            content: Stack(
              children: <Widget>[
                Container(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      new V3TextFormField(
                        translate('Email'),
                         _oldPasswordEditingController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) => validateEmail(value!.trim()),
                      ),
                      SizedBox(height: 15,),
                    ],
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black12),
                child: TrText("CANCEL", style: TextStyle(
                    backgroundColor: Colors.black12, color: Colors.black),),
                onPressed: () {
                  //Put your code here which you want to execute on Cancel button click.
                  Navigator.of(context).pop();
                },
              ),
              ElevatedButton(
                child: gblActionBtnDisabled ? Row(children: [
                  CircularProgressIndicator(),
                   TrText("CONTINUE")
                ],)
                    : TrText("CONTINUE"),
                onPressed: () {
                  if( gblActionBtnDisabled == false ) {
                    var str = validateEmail(_oldPasswordEditingController.text);
                    if (str == null || str == '') {
                      gblActionBtnDisabled = true;
                      setState(() {

                      });
                      _fqtvResetPassword();
                    } else {
                      _error = str;
                      _actionCompleted();
                      showAlertDialog(context, 'Error', _error);
                    }
                  }
                  //});

                  //Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
    }
  String validateEmail(String value) {
/*
    String pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
*/
    RegExp regex = new RegExp(gblEmailValidationPattern);
    if (!regex.hasMatch(value))
      return 'Enter Valid Email';
    else
      return '';
  }
  void _actionCompleted() {
    setState(() {
//      _loadingInProgress = false;
    });
  }



  // commands
  void _fqtvResetPassword() async {
    String msg = json.encode(ApiFqtvResetPasswordRequest(
        _oldPasswordEditingController.text).toJson());
    String method = 'ResetPassword';

    //print(msg);
    sendVRSCommand(msg).then((result){
      Map<String, dynamic> map = json.decode(result);
      ApiResponseStatus resp = new ApiResponseStatus.fromJson(map);
      _isButtonDisabled = false;
      if( resp.statusCode != 'OK') {
        _error = resp.message;
        _actionCompleted();
        showAlertDialog(context, 'Error', _error);

      } else {
        _error = resp.message;
        _actionCompleted();
        _error = 'Reset email sent';
        Navigator.of(context).pop();
        //_showDialog();
        showAlertDialog(context, 'Information', _error);
      }
    });

  }
  void _fqtvLogin() async {
    progressMessagePage(context, translate('Login'), title:  '${gblSettings.fqtvName}');
    gblRedeemingAirmiles = false;
    try {
      String pw = Uri.encodeComponent(_passwordEditingController.text);
      //String pw = _passwordEditingController.text;
      FqtvLoginRequest rq = new FqtvLoginRequest( user: _fqtvTextEditingController.text,
          password: pw);
      fqtvNo = _fqtvTextEditingController.text;
      fqtvPass = _passwordEditingController.text;

      String data = json.encode(rq);
      try {
        String reply = await callSmartApi('FQTVLOGIN', data);
        Map<String, dynamic> map = json.decode(reply);
        FqtvLoginReply fqtvLoginReply = new FqtvLoginReply.fromJson(map);

        if( gblPassengerDetail == null ) {
          gblPassengerDetail = new PassengerDetail( email:  '', phonenumber: '');
        }
        gblFqtvLoggedIn = true;
        gblPassengerDetail!.fqtv = fqtvNo;
        gblPassengerDetail!.fqtvPassword = fqtvPass;
        widget.passengerDetail!.fqtv = fqtvNo;
        widget.passengerDetail!.fqtvPassword = fqtvPass;

        gblPassengerDetail!.title = fqtvLoginReply.title;
        gblPassengerDetail!.firstName = fqtvLoginReply.firstname;
        gblPassengerDetail!.lastName = fqtvLoginReply.surname;
        widget.passengerDetail!.firstName = fqtvLoginReply.firstname;
        widget.passengerDetail!.lastName = fqtvLoginReply.surname;

        gblPassengerDetail!.phonenumber = fqtvLoginReply.phoneMobile;
        if (gblPassengerDetail!.phonenumber == null ||
            gblPassengerDetail!.phonenumber.isEmpty) {
          gblPassengerDetail!.phonenumber =              fqtvLoginReply.phoneHome;
        }
        gblFqtvBalance = int.parse(fqtvLoginReply.balance);

        gblPassengerDetail!.email =fqtvLoginReply.email;
        widget.passengerDetail!.email = fqtvLoginReply.email;
        widget.joiningDate = fqtvLoginReply.joiningDate;
        //DateFormat('dd MMM yyyy').format(DateTime.parse(memberDetails.member.issueDate))
        gblError ='';
        _error = '';
        _isButtonDisabled = false;
        _loadingInProgress = false;
        _actionCompleted();

        setState(() {});

        endProgressMessage();
//      setState(() {});
      } catch (e) {
        fqtvNo = '';
        fqtvPass = '';

        setError( e.toString());
        _isButtonDisabled = false;
        _loadingInProgress = false;
        //_actionCompleted();
        endProgressMessage();
        criticalErrorPage(context, gblError, title: 'Login Error', wantButtons: true, doublePop: true);
        //Navigator.of(context).pop();
        print(gblError);
        _error = gblError;
        //_showDialog();
      }
    } catch(e){
      fqtvNo = '';
      fqtvPass = '';

      _error = e.toString();
      setError( _error);
      _isButtonDisabled = false;
      _loadingInProgress = false;
      //_actionCompleted();
      //_showDialog();
      endProgressMessage();
      criticalErrorPage(context, gblError, title: 'Login Error', wantButtons: true);
      //Navigator.of(context).pop();
      return;
    }

  }
}