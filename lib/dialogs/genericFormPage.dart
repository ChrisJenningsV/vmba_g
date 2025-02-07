


import 'package:flutter/material.dart';

import '../Helpers/settingsHelper.dart';
import '../data/globals.dart';
import '../data/models/dialog.dart';
import 'smartDialog.dart';
import '../utilities/widgets/appBarWidget.dart';
import '../v3pages/controls/V3Constants.dart';
import '../forms/fqtvRegisterFields.dart';

class FormParams {
  String formName='';
  String formTitle='';

  FormParams({required this.formName, required this.formTitle});
}


class SmartDialogHostPage extends StatefulWidget {
  SmartDialogHostPage({ required this.formParams});
  // : super(key: key);
  final FormParams formParams;

  SmartDialogHostPageState createState() =>
      SmartDialogHostPageState();
}

class SmartDialogHostPageState extends State<SmartDialogHostPage> {
  final formKey = new GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {

    DialogDef dialog = new DialogDef(caption: widget.formParams.formTitle);

    switch (widget.formParams.formName) {
      case 'FQTVRESET':
        DialogDef dialog = new DialogDef(caption: 'Reset Password', actionText: 'Continue', action: 'DoFqtvReset');
        dialog.fields.add(new DialogFieldDef(field_type: 'space'));
        dialog.fields.add(new DialogFieldDef(field_type: 'email', caption: 'Email'));
        dialog.fields.add(new DialogFieldDef(field_type: 'space'));

        return smartDialogPage(context, dialog,null, (){ setState(() {}); });

      case 'FQTVREGISTER':
        dialog.width = 'full';
        return smartDialogPage(context, dialog, _body(),  (){ setState(() {}); });

      case 'NEWINSTALLSETTINGS':
        //gblValidationEmail = '';
        gblValidationPinTries = 0;
        DialogDef dialog = new DialogDef(caption: 'Register App', actionText: 'Continue', action: 'DoRequestPin');
        dialog.fields.add(new DialogFieldDef(field_type: 'space'));
        dialog.fields.add(new DialogFieldDef(field_type: 'text', caption: 'Enter email to access details of bookings made on the website.A validation PIN will be sent to this email.'));
        // 'Sign in to access details of bookings made on the website.\n\n A validation PIN will be sent to this email.'
        dialog.fields.add(new DialogFieldDef(field_type: 'email', caption: 'Email'));
        dialog.fields.add(new DialogFieldDef(field_type: 'space'));

        return smartDialogPage(context, dialog,null, (){ setState(() {}); });

      case 'VALIDATEPIN':
        DialogDef dialog = new DialogDef(caption: 'Validate PIN', actionText: 'Continue', action: 'DoValidatePin');
        dialog.fields.add(new DialogFieldDef(field_type: 'space'));
        dialog.fields.add(new DialogFieldDef(field_type: 'text', caption: 'Please check youe email inbox, and enter the validation PIN below. '));
        // 'Sign in to access details of bookings made on the website.\n\n A validation PIN will be sent to this email.'
        dialog.fields.add(new DialogFieldDef(field_type: 'pin', caption: 'PIN'));
        dialog.fields.add(new DialogFieldDef(field_type: 'space'));
        dialog.foot.add(new DialogFieldDef(field_type: 'action', actionText: 'Resend PIN email', action: 'DoResendPin'));

        return smartDialogPage(context, dialog,null, (){ setState(() {}); });


      default:

        return smartDialogPage(context, dialog, _body(), (){ setState(() {}); });

    }


    return

      new Scaffold(
        backgroundColor: v2PageBackgroundColor(),
        appBar: appBar(context, widget.formParams.formTitle, PageEnum.editPax,
          imageName: gblSettings.wantPageImages ? widget.formParams.formName : '',
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            )
          ],
        ),
        extendBodyBehindAppBar: gblSettings.wantPageImages,
        //endDrawer: DrawerMenu(),
        body: _body(),
      );
  }

  Widget _body() {
    return SafeArea(
        child: Form(
            key: formKey,
            child: SingleChildScrollView(
                child: Padding(
                  padding: v2FormPadding(),
                  child:/* Card(
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: v2BorderColor()),
                        borderRadius: BorderRadius.circular(10.0),
                      ),

                      clipBehavior: Clip.antiAlias,
                      child:*/ Column(
                          children: [
/*
                            ListTile(
                              tileColor: gblSystemColors.primaryHeaderColor ,
                              leading: Icon(Icons.person, size: 50.0, color: gblSystemColors.headerTextColor   ,),
                              title: Text(translate('Passenger') + ' ' + widget.passengerDetail.paxNumber + ' (' + translate(paxTypeName) + ')'  ,
                                style: TextStyle(color: gblSystemColors.headerTextColor, fontWeight: FontWeight.bold),),
                            ),
*/
                            Padding(
                                padding: EdgeInsets.fromLTRB(15.0, 0, 15, 15),
                                child: Column(
                                  children:  renderFields(context),

                                )),
                          ])
                  ),
                )
            //)
        ));
  }

  List <Widget> renderFields(BuildContext context ) {
    switch (widget.formParams.formName.toUpperCase()) {
      case 'FQTVREGISTER':
        return renderFqtvRegFields(context);

      default:
        List <Widget> list = [];
        list.add(Text('no render for ${widget.formParams.formName}'));
        return list;
    }
/*

    List <Widget> list = [];
    ThemeData theme = new ThemeData(
      primaryColor: Colors.blueAccent,
      primaryColorDark: Colors.blue,
    );


    return list;
*/
  }



  }