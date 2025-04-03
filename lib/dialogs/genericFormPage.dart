


import 'package:flutter/material.dart';
import 'package:vmba/Managers/PaxManager.dart';

import '../Helpers/settingsHelper.dart';
import '../components/trText.dart';
import '../data/globals.dart';
import '../data/models/dialog.dart';
import 'smartDialog.dart';
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
      dialog = new DialogDef(formname: formName, caption: 'Reset Password', actionText: 'Continue', action: 'DoFqtvReset');
      dialog.fields.add(new DialogFieldDef(field_type: 'space'));
      dialog.fields.add(new DialogFieldDef(field_type: 'email', caption: 'Email'));
      dialog.fields.add(new DialogFieldDef(field_type: 'space'));
      break;
    case 'FQTVREGISTER':
      dialog = getFqtvRegister(formName);
      break;

    case 'MYACCOUNT':
      dialog = getMyAccount(formName);
      break;

    case 'NEWINSTALLSETTINGS':
    //gblValidationEmail = '';
      gblValidationPinTries = 0;
      dialog = new DialogDef(formname: formName, caption: 'Register App', actionText: 'Continue', action: 'DoRequestPin');
      dialog.fields.add(new DialogFieldDef(field_type: 'space'));
      dialog.fields.add(new DialogFieldDef(field_type: 'text', caption: 'Enter email to access details of bookings made on the website.A validation PIN will be sent to this email.'));
      // 'Sign in to access details of bookings made on the website.\n\n A validation PIN will be sent to this email.'
      dialog.fields.add(new DialogFieldDef(field_type: 'email', caption: 'Email'));
      dialog.fields.add(new DialogFieldDef(field_type: 'space'));
      break;
    case 'VALIDATEPIN':
      dialog = new DialogDef(formname: formName, caption: 'Validate PIN', actionText: 'Continue', action: 'DoValidatePin');
      dialog.fields.add(new DialogFieldDef(field_type: 'space'));
      dialog.fields.add(new DialogFieldDef(field_type: 'text', caption: 'Please check youe email inbox, and enter the validation PIN below. '));
      // 'Sign in to access details of bookings made on the website.\n\n A validation PIN will be sent to this email.'
      dialog.fields.add(new DialogFieldDef(field_type: 'pin', caption: 'PIN'));
      dialog.fields.add(new DialogFieldDef(field_type: 'space'));
      dialog.dialogFoot.add(new DialogFieldDef(field_type: 'action', actionText: 'Resend PIN email', action: 'DoResendPin', popOnAction: false ));
      break;
    case 'AGENTLOGIN':
      dialog = new DialogDef(formname: formName, caption: 'Agent Login',actionText: 'Continue',action: 'DoAgentLogin');
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
      String fNo = '';
      String pw = '';
      if( gblPassengerDetail != null ) {
        fNo = gblPassengerDetail!.fqtv;
        pw =  gblPassengerDetail!.fqtvPassword;
      }
      dialog = new DialogDef(formname: formName, caption: formTitle, actionText: 'Continue', action: 'DOFQTVLOGIN');
      dialog.fields.add(new DialogFieldDef(field_type: 'FQTVNUMBER', caption: '${gblSettings.fqtvName} ' + translate('number'),value: fNo ));
      dialog.fields.add(new DialogFieldDef(field_type: 'space', caption: ''));
      dialog.fields.add(new DialogFieldDef(field_type: 'password', caption: 'Password', value: pw));
      dialog.fields.add(new DialogFieldDef(field_type: 'action', caption: "Can't log in? ",
          actionText: translate('Reset Password'),
          action: 'FqtvReset'
      ));
      if( gblSettings.wantFqtvRegister ) {
        dialog.dialogFoot.add(new DialogFieldDef(field_type: 'action', caption: '',
            actionText: translate('Create a') + ' ${gblSettings.fqtvName} ' + translate('account >'),
            action: 'FqtvRegister'
        ));
      } else if (gblSettings.fqtvRegisterUrl != ''){
        dialog.dialogFoot.add(new DialogFieldDef(field_type: 'action', caption: '',
            actionText: translate('Create a') + ' ${gblSettings.fqtvName} ' + translate('account >'),
            action: 'OpenFqtvRegister'
        ));
      }
      if( gblBuildFlavor == 'LM'){
          dialog.pageFoot.add(new DialogFieldDef(field_type: 'action', caption: '',
          actionText: translate('For ADS login click here >'),
          action: 'ADSLogin', backgroundColor: Colors.white
          ));
      }
      break;
    default:
      gblCurDialog = dialog;
   }
  return dialog;
}

DialogDef getMyAccount(String formName) {
  DialogDef dialog = new DialogDef(formname: formName,
      caption: 'My Account',
      actionText: 'Save',
      action: 'DoMyAccount',
      wantAppBar: false);

  dialog.fields.add(new DialogFieldDef(field_type: 'dropdown', caption: 'title', options: gblTitles));

  // first len 50
  dialog.fields.add(new DialogFieldDef(field_type: 'edittext', caption: 'First name (as Passport)', maxLen: 50, isRequired: true, formatRegex: '[a-zA-Z- ÆØøäöåÄÖÅæé]'));
  // middle len 50
  if( gblSettings.wantMiddleName ) {
    dialog.fields.add(new DialogFieldDef(field_type: 'edittext', caption: 'Middle name', maxLen: 50, isRequired: true, formatRegex: '[a-zA-Z- ÆØøäöåÄÖÅæé]'));
  }
    // last  len 50
  dialog.fields.add(new DialogFieldDef(field_type: 'edittext', caption: 'Last name (as Passport)', maxLen: 50, isRequired: true, formatRegex: '[a-zA-Z- ÆØøäöåÄÖÅæé]'));

  // phone len 30
  if( gblSettings.wantInternatDialCode) {

  } else {

  }
    // email len 100
  dialog.fields.add(new DialogFieldDef(field_type: 'email', caption: 'Email', maxLen: 100, isRequired: true));
  // dob

  // gender
  if( gblSettings.wantGender) {
    dialog.fields.add(new DialogFieldDef(
        field_type: 'dropdown', caption: 'title', options: gblTitles));
  }
  // weight
  if( gblSettings.wantWeight) {
  }
  // country
  if( gblSettings.wantCountry) {
  }
  // notifications
  // fqtv no  len 50
  // fqtv pass

  // LM ADS no and pass len 25
  // T6 senior citizen ID and Disability ID

  // redress no len 30
  // known traveller no len 30


  dialog.width = 'full';
  return dialog;
}


DialogDef getFqtvRegister(String formName) {
  DialogDef dialog = new DialogDef(formname: formName, caption: '${gblSettings.fqtvName} Registration', actionText: 'Continue', action: 'DoFqtvRegister', wantAppBar: false);
  dialog.fields.add(new DialogFieldDef(field_type: 'space'));
  dialog.fields.add(new DialogFieldDef(field_type: 'text', caption: 'On completion you will receive an email containing your joining information.'));
  dialog.fields.add(new DialogFieldDef(field_type: 'dropdown', caption: 'title', options: gblTitles));

  // first len 50
  dialog.fields.add(new DialogFieldDef(field_type: 'edittext', caption: 'First name (as Passport)', maxLen: 50, isRequired: true, formatRegex: '[a-zA-Z- ÆØøäöåÄÖÅæé]'));
  // middle len 50
  if( gblSettings.wantMiddleName ) {
    dialog.fields.add(new DialogFieldDef(field_type: 'edittext', caption: 'Middle name', maxLen: 50, isRequired: true, formatRegex: '[a-zA-Z- ÆØøäöåÄÖÅæé]'));
  }
  // last  len 50
  dialog.fields.add(new DialogFieldDef(field_type: 'edittext', caption: 'Last name (as Passport)', maxLen: 50, isRequired: true, formatRegex: '[a-zA-Z- ÆØøäöåÄÖÅæé]'));

  // dob
  dialog.fields.add(new DialogFieldDef(field_type: 'dob', caption: 'Email', maxLen: 100));
  // email
  dialog.fields.add(new DialogFieldDef(field_type: 'email', caption: 'Email', maxLen: 100));
  // mobile
  if( gblSettings.wantInternatDialCode) {

  } else {

  }

  // nationallity

  // password
  dialog.fields.add(new DialogFieldDef(field_type: 'password', caption: 'Password', maxLen: 50));
  // confirm
  dialog.fields.add(new DialogFieldDef(field_type: 'password', caption: 'Confirm password', maxLen: 50));

  // accept
  dialog.fields.add(new DialogFieldDef(field_type: 'switch', caption: 'I accept ${gblSettings.fqtvName} terms and conditions', maxLen: 50, maxLines: 2));


  dialog.fields.add(new DialogFieldDef(field_type: 'space'));
  dialog.width = 'full';
  return dialog;
}