
import 'package:flutter/material.dart';
import 'package:vmba/v3pages/cards/v3FormFields.dart';

import '../../components/trText.dart';
import '../../data/globals.dart';


class FqtvLoginBox extends StatefulWidget {
  FqtvLoginBox();

  @override
  State<StatefulWidget> createState() => new FqtvLoginBoxState();
}

class FqtvLoginBoxState extends State<FqtvLoginBox> {
  TextEditingController _fqtvTextEditingController = TextEditingController();
  TextEditingController _passwordEditingController = TextEditingController();
  bool _isHidden = true;
  bool _isButtonDisabled = false;

  @override void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> list = [];

    list.add(Padding( padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
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


    list.add( Padding( padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
        child: TextFormField(
      //focusNode: focusNode,
      obscureText: _isHidden,
      obscuringCharacter: "*",
      controller: _passwordEditingController,
      decoration: getV3Decoration(translate('Password')),
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
    list.add(
        TextButton(
      child: new TrText(
        'Reset Password',
        style: TextStyle(color: Colors.black),
      ),
      style: TextButton.styleFrom(primary: Colors.white,
          side: BorderSide(color: Colors.grey.shade300, width: 2)),
      onPressed: () {
        /* resetPasswordDialog();*/
      },
    )
    );
    list.add(Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        ElevatedButton(
          style: ElevatedButton.styleFrom(primary: Colors.grey.shade100),
          child: TrText(
            "CANCEL",
            style: TextStyle(color: Colors.black),
          ),
          onPressed: () {
            //Put your code here which you want to execute on Cancel button click.
            Navigator.of(context).pop();
          },
        ),
        SizedBox(width: 20,),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              primary: gblSystemColors.primaryButtonColor),
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
/*
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
                          _showDialog();
                        }
                      }
*/
          },
        ),
      ],
    )
    );

    return Column(
      children: list,
    );
  }
}