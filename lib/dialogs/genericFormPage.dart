


import 'package:flutter/material.dart';

import '../Helpers/settingsHelper.dart';
import '../components/trText.dart';
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
  SmartDialogHostPage({ this.formParams = null});
  // : super(key: key);
  final FormParams? formParams;

  SmartDialogHostPageState createState() =>
      SmartDialogHostPageState();
}

class SmartDialogHostPageState extends State<SmartDialogHostPage> {
  final formKey = new GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {

/*
    DialogDef dialog = new DialogDef(caption: widget.formParams!.formTitle);

    switch (widget.formParams!.formName) {
      case 'FQTVRESET':
        DialogDef dialog = new DialogDef(caption: 'Reset Password', actionText: 'Continue', action: 'DoFqtvReset');
        dialog.fields.add(new DialogFieldDef(field_type: 'space'));
        dialog.fields.add(new DialogFieldDef(field_type: 'email', caption: 'Email'));
        dialog.fields.add(new DialogFieldDef(field_type: 'space'));
        gblCurDialog = dialog;

        return smartDialogPage();

      case 'FQTVREGISTER':
        dialog.width = 'full';
        gblCurDialog = dialog;
        return smartDialogPage( content:  _body());

      case 'NEWINSTALLSETTINGS':
        //gblValidationEmail = '';
        gblValidationPinTries = 0;
        DialogDef dialog = new DialogDef(caption: 'Register App', actionText: 'Continue', action: 'DoRequestPin');
        dialog.fields.add(new DialogFieldDef(field_type: 'space'));
        dialog.fields.add(new DialogFieldDef(field_type: 'text', caption: 'Enter email to access details of bookings made on the website.A validation PIN will be sent to this email.'));
        // 'Sign in to access details of bookings made on the website.\n\n A validation PIN will be sent to this email.'
        dialog.fields.add(new DialogFieldDef(field_type: 'email', caption: 'Email'));
        dialog.fields.add(new DialogFieldDef(field_type: 'space'));
        gblCurDialog = dialog;
        return smartDialogPage();

      case 'VALIDATEPIN':
        DialogDef dialog = new DialogDef(caption: 'Validate PIN', actionText: 'Continue', action: 'DoValidatePin');
        dialog.fields.add(new DialogFieldDef(field_type: 'space'));
        dialog.fields.add(new DialogFieldDef(field_type: 'text', caption: 'Please check youe email inbox, and enter the validation PIN below. '));
        // 'Sign in to access details of bookings made on the website.\n\n A validation PIN will be sent to this email.'
        dialog.fields.add(new DialogFieldDef(field_type: 'pin', caption: 'PIN'));
        dialog.fields.add(new DialogFieldDef(field_type: 'space'));
        dialog.foot.add(new DialogFieldDef(field_type: 'action', actionText: 'Resend PIN email', action: 'DoResendPin'));
        gblCurDialog = dialog;

        return smartDialogPage();
      default:
        gblCurDialog = dialog;
        return smartDialogPage(content:  _body());

    }
*/
    gblCurDialog = getDialogDefinition(widget.formParams!.formName, widget.formParams!.formTitle);
    return smartDialogPage(); // content:  _body()

  }

  Widget _body() {
    return SafeArea(
        child: Form(
            key: formKey,
            child: SingleChildScrollView(
                child: Padding(
                  padding: v2FormPadding(),
                  child: Column(
                          children: [
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
    switch (widget.formParams!.formName.toUpperCase()) {
      case 'FQTVREGISTER':
        return renderFqtvRegFields(context);

      default:
        List <Widget> list = [];
        list.add(Text('no render for ${widget.formParams!.formName}'));
        return list;
    }
  }
  }

DialogDef getDialogDefinition(String formName, String formTitle){
  DialogDef dialog = new DialogDef(caption: formTitle);

  switch (formName) {
    case 'FQTVRESET':
      dialog = new DialogDef(caption: 'Reset Password', actionText: 'Continue', action: 'DoFqtvReset');
      dialog.fields.add(new DialogFieldDef(field_type: 'space'));
      dialog.fields.add(new DialogFieldDef(field_type: 'email', caption: 'Email'));
      dialog.fields.add(new DialogFieldDef(field_type: 'space'));
      break;
    case 'FQTVREGISTER':
      dialog.width = 'full';
      break;

    case 'NEWINSTALLSETTINGS':
    //gblValidationEmail = '';
      gblValidationPinTries = 0;
      dialog = new DialogDef(caption: 'Register App', actionText: 'Continue', action: 'DoRequestPin');
      dialog.fields.add(new DialogFieldDef(field_type: 'space'));
      dialog.fields.add(new DialogFieldDef(field_type: 'text', caption: 'Enter email to access details of bookings made on the website.A validation PIN will be sent to this email.'));
      // 'Sign in to access details of bookings made on the website.\n\n A validation PIN will be sent to this email.'
      dialog.fields.add(new DialogFieldDef(field_type: 'email', caption: 'Email'));
      dialog.fields.add(new DialogFieldDef(field_type: 'space'));
      break;
    case 'VALIDATEPIN':
      dialog = new DialogDef(caption: 'Validate PIN', actionText: 'Continue', action: 'DoValidatePin');
      dialog.fields.add(new DialogFieldDef(field_type: 'space'));
      dialog.fields.add(new DialogFieldDef(field_type: 'text', caption: 'Please check youe email inbox, and enter the validation PIN below. '));
      // 'Sign in to access details of bookings made on the website.\n\n A validation PIN will be sent to this email.'
      dialog.fields.add(new DialogFieldDef(field_type: 'pin', caption: 'PIN'));
      dialog.fields.add(new DialogFieldDef(field_type: 'space'));
      dialog.dialogFoot.add(new DialogFieldDef(field_type: 'action', actionText: 'Resend PIN email', action: 'DoResendPin'));
      break;
    case 'AGENTLOGIN':
      dialog = new DialogDef(caption: 'Agent Login',
          actionText: 'Continue',
          action: 'DoAgentLogin');
      dialog.fields.add(
          new DialogFieldDef(
              field_type: 'number', caption: 'sine (4ch)'));
      dialog.fields.add(
          new DialogFieldDef(
              field_type: 'password', caption: 'Password'));
      dialog.fields.add(new DialogFieldDef(field_type: 'space'));
      gblCurDialog = dialog;
      break;

    case 'FQTVLOGIN':
      dialog = new DialogDef(caption: formTitle, actionText: 'Continue', action: 'DOFQTVLOGIN');
      dialog.fields.add(new DialogFieldDef(field_type: 'FQTVNUMBER', caption: '${gblSettings.fqtvName} ' + translate('number')));
      dialog.fields.add(new DialogFieldDef(field_type: 'space', caption: ''));
      dialog.fields.add(new DialogFieldDef(field_type: 'password', caption: 'Password'));
      dialog.fields.add(new DialogFieldDef(field_type: 'action', caption: "Can't log in? ",
          actionText: translate('Reset Password'),
          action: 'FqtvReset'
      ));
      if( gblSettings.wantFqtvRegister ) {
        dialog.dialogFoot.add(new DialogFieldDef(field_type: 'action', caption: '',
            actionText: translate('Create a') + ' ${gblSettings.fqtvName} ' + translate('account >'),
            action: 'FqtvRegister'
        ));
      }
      if( gblBuildFlavor == 'LM'){
          dialog.pageFoot.add(new DialogFieldDef(field_type: 'action', caption: '',
          actionText: translate('For ADS login click here >'),
          action: 'ADSLogin'
          ));
      }
      break;
    default:
      gblCurDialog = dialog;
   }
  return dialog;
}
