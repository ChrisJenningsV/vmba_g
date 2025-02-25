import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vmba/data/models/dialog.dart';
import 'package:vmba/data/repository.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:vmba/data/globals.dart';

import 'package:vmba/data/models/models.dart';
import 'package:vmba/data/models/user_profile.dart';
import 'package:vmba/components/trText.dart';
import 'package:vmba/dialogs/smartDialog.dart';
import 'package:vmba/dialogs/genericFormPage.dart';
import 'package:vmba/utilities/helper.dart';
import 'package:vmba/components/showDialog.dart';
import 'package:vmba/utilities/navigation.dart';
import 'package:vmba/utilities/widgets/colourHelper.dart';

import '../Helpers/networkHelper.dart';
import '../Helpers/settingsHelper.dart';
import '../components/vidButtons.dart';
import '../controllers/vrsCommands.dart';
import '../data/models/vrsRequest.dart';
import '../data/CommsManager.dart';
import '../utilities/PaxManager.dart';
import '../utilities/messagePages.dart';
import '../utilities/widgets/appBarWidget.dart';
import '../v3pages/cards/v3FormFields.dart';
import '../v3pages/controls/v3Dialog.dart';

//ignore: must_be_immutable
class MyFqtvPage extends StatefulWidget {
  MyFqtvPage(
      {Key key= const Key("fqtv_key"), this.passengerDetail, this.isAdsBooking= false, this.isLeadPassenger= false})
      : super(key: key);

  _MyFqtvPageState createState() => _MyFqtvPageState();

  PassengerDetail? passengerDetail;
  //String joiningDate='';
  final bool isAdsBooking ;
  final bool isLeadPassenger;


}


class _MyFqtvPageState extends State<MyFqtvPage> {
  TextEditingController _fqtvTextEditingController =   TextEditingController();
  TextEditingController _passwordEditingController =   TextEditingController();
  // TextEditingController _emailEditingController =   TextEditingController();
  TextEditingController _oldPasswordEditingController =   TextEditingController();
  TextEditingController _newPasswordEditingController =   TextEditingController();

  TextEditingController _titleTextEditingController = TextEditingController();

  TextEditingController _firstNameTextEditingController =   TextEditingController();

  TextEditingController _lastNameTextEditingController =  TextEditingController();
  TextEditingController _emailTextEditingController =  TextEditingController();
  TextEditingController _phoneNumberTextEditingController =  TextEditingController();

  TextEditingController _dateOfBirthTextEditingController =  TextEditingController();

  TextEditingController _adsNumberTextEditingController =   TextEditingController();
  TextEditingController _adsPinTextEditingController = TextEditingController();
  //TextEditingController _fqtvTextEditingController = TextEditingController();
  //Session session;
  String fqtvEmail = '';
  String fqtvNo = '';
  String fqtvPass='';
  bool _isButtonDisabled= false;
  bool isPending = false;
  ApiFqtvMemberDetailsResponse? memberDetails;
  List<ApiFQTVMemberTransaction>? transactions;

  List<UserProfileRecord>? userProfileRecordList;
  final formKey = new GlobalKey<FormState>();
//  bool _loadingInProgress = false;
  String _error= '';
  bool _isHidden = true;
  bool _loadingInProgress = false;
  String title ='';


  @override
  initState() {
    super.initState();
    gblActionBtnDisabled = false;
    gblRedeemingAirmiles = false;
    _isButtonDisabled = false;
   // _loadingInProgress = true;
    _isHidden = true;
    title = 'transactions';
    widget.passengerDetail = new PassengerDetail( email:  '', phonenumber: '');
    if( gblPassengerDetail != null &&
        gblPassengerDetail!.fqtv != null && gblPassengerDetail!.fqtv.isNotEmpty &&
        gblPassengerDetail!.fqtvPassword != null && gblPassengerDetail!.fqtvPassword.isNotEmpty) {
      widget.passengerDetail = gblPassengerDetail;
      fqtvNo = gblPassengerDetail!.fqtv;
      fqtvPass = gblPassengerDetail!.fqtvPassword;
    } else {
      Repository.get()
          .getNamedUserProfile('PAX1').then((profile) {
        if (profile != null) {
          widget.passengerDetail!.firstName = profile.name.toString();
          try {
            Map<String, dynamic> map = json.decode(
                profile.value.toString().replaceAll(
                    "'", '"')); // .replaceAll(',}', '}')
            widget.passengerDetail = PassengerDetail.fromJson(map);
            gblPassengerDetail =widget.passengerDetail;
          } catch (e) {
            print(e);
          }
          _titleTextEditingController.text = widget.passengerDetail!.title;
          _firstNameTextEditingController.text =
              widget.passengerDetail!.firstName;
          _lastNameTextEditingController.text = widget.passengerDetail!.lastName;
          _emailTextEditingController.text = widget.passengerDetail!.email;
          _phoneNumberTextEditingController.text =
              widget.passengerDetail!.phonenumber;
          _dateOfBirthTextEditingController.text =
              widget.passengerDetail!.dateOfBirth.toString();

          _adsNumberTextEditingController.text =
              widget.passengerDetail!.adsNumber;
          _adsPinTextEditingController.text = widget.passengerDetail!.adsPin;

          if (widget.passengerDetail!.paxType == null) {
            widget.passengerDetail!.paxType = PaxType.adult;
          }
        }
      });
    }
    // _displayProcessingIndicator = false;

    if( gblPassengerDetail != null && gblPassengerDetail!.fqtv != null &&
        gblPassengerDetail!.fqtv.isNotEmpty &&
        gblPassengerDetail!.fqtvPassword != null &&
        gblPassengerDetail!.fqtvPassword.isNotEmpty) {
      // set up for login
      _fqtvTextEditingController.text = gblPassengerDetail!.fqtv;
      _passwordEditingController.text = gblPassengerDetail!.fqtvPassword;

      //_fqtvLogin();

    }

  }

  @override
  Widget build(BuildContext context) {
   // gblActionBtnDisabled = false;
    if (_loadingInProgress) {
      return getProgressMessage('Checking details...', '');
      return Scaffold(
        body: new Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              new CircularProgressIndicator(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: new TrText("Checking details..."),
              ),
            ],
          ),
        ),
      );
    }
    else if( gblFqtvLoggedIn == false || widget.passengerDetail == null || widget.passengerDetail!.fqtv == null ||
        widget.passengerDetail!.fqtv.isEmpty || widget.passengerDetail!.fqtvPassword == null ||
        widget.passengerDetail!.fqtvPassword.isEmpty  ) {
      Color titleBackClr = gblSystemColors.primaryHeaderColor;
      if( titleBackClr == Colors.white) {
        titleBackClr = gblSystemColors.primaryButtonColor;
      }
      try {
        //endProgressMessage();
      } catch(e) {

      }
      Widget flexibleSpace = Padding(padding: EdgeInsets.all(30,));
      if( gblSettings.pageImageMap != null ) {
        Map pageMap = json.decode(gblSettings.pageImageMap.toUpperCase());
        if(pageMap['FQTV'] != null ) {
          String pageImage = pageMap['FQTV'];

          if (pageImage != null && pageImage.isNotEmpty) {
            NetworkImage backgroundImage = NetworkImage(
                '${gblSettings.gblServerFiles}/pageImages/$pageImage.png');
            flexibleSpace = Image(
              image:
              backgroundImage,
              fit: BoxFit.cover,);
            //backgroundColor = Colors.transparent;

          }
        }
      }
      String sTitle = translate('${gblSettings.fqtvName} ') + translate('LOGIN');
      if( sTitle.length > 20 ) sTitle = translate('LOGIN');

      DialogDef dialog = new DialogDef(caption: sTitle, actionText: 'Continue', action: 'DoFqtvLogin');

      if( gblSettings.wantNewDialogs ) {

        dialog.fields.add(new DialogFieldDef(field_type: 'FQTVNUMBER', caption: '${gblSettings.fqtvName} ' + translate('number')));
        dialog.fields.add(new DialogFieldDef(field_type: 'space', caption: ''));
        dialog.fields.add(new DialogFieldDef(field_type: 'password', caption: 'Password'));
        dialog.fields.add(new DialogFieldDef(field_type: 'action', caption: "Can't log in? ",
            actionText: translate('Reset Password'),
            action: 'FqtvReset'
          ));


        if( gblSettings.wantFqtvRegister ) {
          dialog.foot.add(new DialogFieldDef(field_type: 'action', caption: '',
              actionText: translate('Create a') + ' ${gblSettings.fqtvName} ' + translate('account >'),
              action: 'FqtvRegister'
            ));
        }
        gblCurDialog = dialog;

        return smartDialogPage();
      }


      return  Scaffold(
           body:
              Column (
              children: [
                flexibleSpace,
                        AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0))),
        titlePadding: EdgeInsets.only(top: 0),
        contentPadding: EdgeInsets.only(left: 0, right: 0, top: 5, bottom: 0),
        title: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: titleBackClr,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0),)),
              padding: EdgeInsets.only(left: 10, top: 0, bottom: 0),
              child:
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(padding: EdgeInsets.all(20)),
                    Text(sTitle ,
                      style: TextStyle(color: Colors.white),),
                    IconButton(onPressed: () => Navigator.pop(context),
                         icon: Stack(
                           children: [
                             Icon(Icons.circle_outlined, color: Colors.white, size: 34,),
                              Padding( padding: EdgeInsets.only(left: 5, top: 5), child: Icon(Icons.close, color: Colors.white,)),
                           ],
                         ))
            ] )
        ),
        content: contentBox(context),
        //actions: <Widget>[)    ]
      ),
                ])
              );
    }

    String fqtvName = 'My ${gblSettings.fqtvName}';
    if( gblSettings.fqtvName.startsWith('My')) {
      fqtvName = '${gblSettings.fqtvName}';
    }
    gblShowRedeemingAirmiles = true;

    return Scaffold(
        backgroundColor: v2PageBackgroundColor(),
      appBar: AppBar(
        leading: getAppBarLeft(),
        backgroundColor:
        gblSystemColors.primaryHeaderColor,
        iconTheme: IconThemeData(
            color: gblSystemColors.headerTextColor),
        title: TrText(fqtvName ,
            style: TextStyle(
                color:
                gblSystemColors.headerTextColor)),
        automaticallyImplyLeading: false,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
      body:
      new Form(
        key: formKey,
        child: new SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Padding(
    padding: v2FormPadding(),
    child: Card(
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(10.0),
    ),

    clipBehavior: Clip.antiAlias,
      child: Padding(
          padding: EdgeInsets.fromLTRB(15.0, 10, 15, 15),

    child: Column(

              children:  _getWidgets()
              ,
            ),
          )),
        ),
      ),
    )
    );
    // });
  }

Widget? contentBox(context){
    return
      SizedBox(
          width: MediaQuery.of(context).size.width,
        child:
        Stack(
          children: <Widget>[
            Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(padding: EdgeInsets.only(left: 10, right: 10), child: TextFormField(
                decoration: getDecoration( '${gblSettings.fqtvName} ' + translate('number')),
                controller: _fqtvTextEditingController,
                keyboardType: TextInputType.number,
                onSaved: (value) {
                  if (value != null) {
                    //.contactInfomation.phonenumber = value.trim()
                  }
                },
              ),),

              SizedBox(height: 15,),
              Padding(padding: EdgeInsets.only(left: 10, right: 10), child:  TextFormField(
                obscureText: _isHidden,
                obscuringCharacter: "*",
                controller: _passwordEditingController ,
                decoration:getDecoration(translate('Password')),
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
              )),
              Padding(padding: EdgeInsets.only(left: 10, right: 10), child: Row( children:
              [
                TrText('Can\'t log in ?'),
                TextButton(
                child: new TrText(
                  'Reset Password',
                  style: TextStyle(color: gblSystemColors.plainTextButtonTextColor),
                ),
               // style: TextButton.styleFrom(foregroundColor: Colors.white, side: BorderSide(color: Colors.grey.shade300, width: 2)),
                onPressed: () {
                  resetPasswordDialog();
                },
              )]
              )),
              gblSettings.wantRememberMe ?
              CheckboxListTile(
                title: TrText("Remember me"),
                value: gblRememberMe,
                onChanged: (newValue) {
                  setState(() {
                    gblRememberMe = newValue!;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,  //  <-- leading Checkbox
              ) : Container(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                 /*   vidCancelButton( context, "CANCEL", (context) {
                      //
                      Navigator.of(context).pop();
                    },
                  ),
                  SizedBox(width: 20,),*/
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: gblSystemColors.primaryButtonColor,),
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
                          setState(() {});
                          _fqtvLogin('Login');
                        } else {
                          _error = "Please complete both fields";
                          _loadingInProgress = false;
                          _isButtonDisabled = false;
                          // _actionCompleted();
                          _showDialog();
                        }
                      }
                      //});

                      //Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
              gblSettings.wantFqtvRegister ?
                Container(
                    decoration: BoxDecoration(
                        color: Colors.black12 ,
                        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10.0), bottomRight: Radius.circular(10.0),)),
                  margin: EdgeInsets.all(0),
                  height: 35,
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  width: MediaQuery.of(context).size.width,
                  child: TextButton(child: new TrText(
                    'Create a ${gblSettings.fqtvName} account >',
                    style: TextStyle(color: gblSystemColors.plainTextButtonTextColor),
                  ),
                      // style: TextButton.styleFrom(foregroundColor: Colors.white, side: BorderSide(color: Colors.grey.shade300, width: 2)),
                      onPressed: () {
                        Navigator.of(context).pop();
                        navToSmartDialogHostPage(context, new FormParams(formName: 'FQTVREGISTER',
                            formTitle: '${gblSettings.fqtvName} Registration'));
                      }

                  )
                ) :
              Container()
            ],
          )
          ],
        )
      );
  }
  /*
  void _togglePasswordView() {
    setState(() {
      _isHidden = !_isHidden;
    });
  }
*/
  List<Widget> _getWidgets() {
    List<Widget> widgets = [];
    String name = '';
    String email = '';
    String fqtv = '';
    String joining = widget.passengerDetail!.joiningDate ;
    if( joining == null) joining = '';
    if( joining.length > 11) joining = joining.substring(0,11);

if (widget.passengerDetail != null) {
  if( widget.passengerDetail!.firstName != null &&
    widget.passengerDetail!.firstName.isNotEmpty && widget.passengerDetail!.lastName != null &&
    widget.passengerDetail!.lastName.isNotEmpty) {

    name = widget.passengerDetail!.firstName + ' ' +widget.passengerDetail!.lastName;
  }
  if ( widget.passengerDetail!.email != null ) {
    email = widget.passengerDetail!.email;
  }
  if ( widget.passengerDetail!.fqtv != null ) {
    fqtv = widget.passengerDetail!.fqtv;
  }
}
if ( memberDetails != null ) {
  name = memberDetails!.member!.title + ' ' + memberDetails!.member!.firstname + ' ' + memberDetails!.member!.surname ;
  email = memberDetails!.member!.email;

}
if( widget.passengerDetail!.joiningDate != null && widget.passengerDetail!.joiningDate.isNotEmpty) {
  try {
  joining = DateFormat('dd MMM yyyy').format(DateTime.parse(widget.passengerDetail!.joiningDate));
  } catch(e) {

  }

}


    widgets.add(Padding(
      padding: EdgeInsets.fromLTRB(0, 3.0, 0, 3),
      child: new Theme(
        data: new ThemeData(
          primaryColor: Colors.blueAccent,
          primaryColorDark: Colors.blue,
        ),
        child: new Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                new TrText("${gblSettings.fqtvName} Points",
                    style: new TextStyle(
                        fontSize: 16.0, fontWeight: FontWeight.w700)),
                new Text(gblFqtvBalance.toString(),
                    style: new TextStyle(
                        fontSize: 16.0, fontWeight: FontWeight.w500)),
              ],
            ),
          ],
        ),
      ),
    ),);
    widgets.add(Padding(
      padding: EdgeInsets.fromLTRB(0, 3.0, 0, 3),
        child: new Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                new TrText("Name",
                    style: new TextStyle(
                        fontSize: 16.0, fontWeight: FontWeight.w700)),
                new Text(name,
                //    style: new TextStyle(fontSize: 14.0, fontWeight: FontWeight.w300)
                ),
              ],
            ),
          ],
        ),
    ),);
    widgets.add(Padding(
      padding: EdgeInsets.fromLTRB(0, 3.0, 0, 3),
      child: new Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              new TrText("Membership No",
                  style: new TextStyle(
                      fontSize: 16.0, fontWeight: FontWeight.w700)),
              new Text(fqtv,
                  //style: new TextStyle(                      fontSize: 14.0, fontWeight: FontWeight.w300)
              ),
            ],
          ),
        ],
      ),
    ),);
    widgets.add(Padding(
      padding: EdgeInsets.fromLTRB(0, 3.0, 0, 3),
      child: new Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              new TrText("Email",
                  style: new TextStyle(
                      fontSize: 16.0, fontWeight: FontWeight.w700)),
              new Text(email,
              //    style: new TextStyle(fontSize: 14.0, fontWeight: FontWeight.w300)
              ),
            ],
          ),
        ],
      ),
    ),);
    widgets.add(Padding(
      padding: EdgeInsets.fromLTRB(0, 3.0, 0, 3),
      child: new Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              new TrText("Joining date",
                  style: new TextStyle(
                      fontSize: 16.0, fontWeight: FontWeight.w700)),
              new Text(joining,),
            ],
          ),
        ],
      ),
    ),);


    widgets.add(Padding(padding: EdgeInsets.all(3), child: vidWideActionButton(context, 'Show Transactions', _showTransactions, wantIcon: false)));
    widgets.add(Padding(padding: EdgeInsets.all(3), child: vidWideActionButton(context, 'Refresh Points', _reloadPoints, wantIcon: false)));

    widgets.add(Padding(padding: EdgeInsets.all(3), child: vidWideActionButton(context, 'Show Pending Transactions', _showPendingTransactions, wantIcon: false)));
    widgets.add(Padding(padding: EdgeInsets.all(3), child: vidWideActionButton(context, 'Change Password', _changePasswordDialog, wantIcon: false)));
    widgets.add(Padding(padding: EdgeInsets.all(3), child: vidWideActionButton(context, 'Book a flight', _bookAFlight, wantIcon: false)));
    widgets.add(Padding(padding: EdgeInsets.all(3), child: vidWideActionButton(context, 'Logout', _logout, wantIcon: false)));

    if(_error != null && _error.isNotEmpty){
      widgets.add(Text(_error));
    }

    if( transactions != null ) {
          widgets.add(_getTrans());
   }
    return widgets;
  }

  void _reloadPoints(BuildContext context, dynamic p) {
    _fqtvLogin('Refreshing');
  }

  void _logout(BuildContext context, dynamic p) {
    gblFqtvNumber = "";
    gblFqtvLoggedIn = false;
    gblRedeemingAirmiles = false;
    widget.passengerDetail!.fqtv = '';
    fqtvNo = '';
    fqtvEmail = '';
    fqtvPass = '';
    gblPassengerDetail!.fqtv = '';
    gblPassengerDetail!.fqtvPassword = '';
    gblFqtvBalance = 0;
    Navigator.of(context).pushNamedAndRemoveUntil(
        '/HomePage', (Route<dynamic> route) => false);
  }

  void _bookAFlight(BuildContext context, dynamic p) {
    List<String> args = [];
    args.add('wantRedeemMiles');
    Navigator.of(context).pushNamedAndRemoveUntil(
        '/FlightSearchPage', (Route<dynamic> route) => false, arguments: args);
  }

Widget _getTrans() {
  List<Widget> tranWidgets = [];

  tranWidgets.add( TrText(title, textScaleFactor: 1.5, style: TextStyle(fontWeight: FontWeight.bold),) );

  for(var tran in  transactions!) {
    if(( tran.airMiles != '0' && tran.airMiles != '0.0' ) || isPending) {

      List<Widget> list = [];

      if( isPending ){
        list.add(Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            (tran.flightDate  == null || tran.flightDate  == '' || tran.flightDate.startsWith('0001')) ? Text('no date') : Text(DateFormat(
                'dd MMM yyyy').format(DateTime.parse(tran.flightDate)), textScaleFactor: 1.2,
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text(' '),
            Text( tran.pnr, textScaleFactor: 1.2, style: TextStyle(fontWeight: FontWeight.bold),),
          ],  ));

      } else {
        list.add(Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 2023-01-18T00:00:00
            (tran.transactionDateTime == null || tran.transactionDateTime == '' || tran.transactionDateTime.startsWith('000')) ? Text('') : Text(DateFormat(
                'dd MMM yyyy').format(DateTime.parse(tran.transactionDateTime)), textScaleFactor: 1.2,
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text(' '),
            Text( tran.pnr, textScaleFactor: 1.2, style: TextStyle(fontWeight: FontWeight.bold),),
          ],  ));
      }

      if( tran.flightNumber.isNotEmpty ) {
        String fltDate = '';
        if(tran.flightDate.isNotEmpty &&
            (!tran.flightDate.startsWith(('0001'))) ) {
            fltDate = DateFormat('ddMMMyy').format(DateTime.parse(tran.flightDate));
        }
          list.add(Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              //Padding(padding: EdgeInsets.only(right: 8.0),child: Icon(Icons.favorite,color: Colors.green,),),
              Text('${tran.flightNumber} ${tran.departureCityCode} ${tran.arrivalCityCode} $fltDate' ),

              (getAirMilesDisplayValue(tran.airMiles) != '') ?Text(getAirMilesDisplayValue(tran.airMiles), textScaleFactor: 1.2,
                style: TextStyle(fontWeight: FontWeight.bold),): Text(''),
            ],));
      }

  list.add(Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
  Expanded(
  child: Container(
  child: Text( tran.description ,
  maxLines: 5, overflow: TextOverflow.ellipsis,))),
    tran.flightNumber.isNotEmpty? Text('') : Text(getAirMilesDisplayValue(tran.airMiles), textScaleFactor: 1.2,
      style: TextStyle(fontWeight: FontWeight.bold),)
  ]));


  list.add(Divider(color: Colors.grey, height: 6.0,),);


      tranWidgets.add(Container(
        width: MediaQuery.of(context).size.width * 0.95 ,
        //margin: EdgeInsets.all(1.0),
        padding: EdgeInsets.all(5),
        child: Column(

          // this makes the column height hug its content
          mainAxisSize: MainAxisSize.min,
          children: list
     )
      )

      );

    }
  }

      return new Column(children: tranWidgets.toList());
}

  String getAirMilesDisplayValue(String airMiles){
    if(airMiles == '0.0' ) {
      return "";
    }
    return cleanInt(airMiles);
  }


  void formSave() {
    final form = formKey.currentState;
    form!.save();
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

  void _showDialog() {
    showVidDialog(context, gblSettings.fqtvName, _error, type: DialogType.Error);
    return;
    // flutter defined function
  }

  void _fqtvResetPassword(String email, {void Function()? refresh }) async {
    String msg = json.encode(ApiFqtvResetPasswordRequest(
        email).toJson());
    String method = 'ResetPassword';
    _oldPasswordEditingController.text = '';

    //print(msg);
    _sendVRSCommand(msg, method).then((result){
      gblActionBtnDisabled = false;
      if( refresh != null ) refresh();
      Map<String, dynamic> map = json.decode(result);
      ApiResponseStatus resp = new ApiResponseStatus.fromJson(map);
      _isButtonDisabled = false;
      if( resp.statusCode != 'OK') {
        _error = resp.message;
        _actionCompleted();
        _showDialog();

      } else {
        _error = resp.message;
        _actionCompleted();
        _error = 'Reset email sent';
        Navigator.of(context).pop();
        //_showDialog();
        showVidDialog(context, 'Information', _error);
      }
    });

  }

  void _fqtvChangePassword({void Function()? refresh }) async {
    String msg = json.encode(ApiFqtvChangePasswordRequest(fqtvNo,
          _oldPasswordEditingController.text,
          _newPasswordEditingController.text).toJson());
    String method = 'ChangePassword2';  // use new version

    //print(msg);
    _sendVRSCommand(msg, method).then((result){
      gblActionBtnDisabled = false;
      if( refresh != null ) refresh();
      _error = '';
      Map<String, dynamic> map = json.decode(result);
      ApiResponseStatus resp = new ApiResponseStatus.fromJson(map);
      _isButtonDisabled = false;
      if( resp.statusCode != 'OK') {
        _error = resp.message;
        //_actionCompleted();

        _showDialog();

      } else {
        _error = resp.message;

        try {
        _actionCompleted();
        gblPassengerDetail!.fqtvPassword = _newPasswordEditingController.text;
        fqtvPass = _newPasswordEditingController.text;
        // save new password in profile
        Repository.get().getNamedUserProfile('PAX1').then((profile) {
          if (profile != null && profile.value != '') {
            Map<String, dynamic> map = json.decode(
                profile.value.toString().replaceAll("'", '"')); // .replaceAll(',}', '}')
            var passengerDetail = PassengerDetail.fromJson(map);
            passengerDetail.fqtvPassword = _newPasswordEditingController.text;
            // now save it
            List<UserProfileRecord> _userProfileRecordList = [];
            UserProfileRecord _profileRecord = new UserProfileRecord(
                name: 'PAX1',
                value: json.encode(passengerDetail.toJson()).replaceAll('"', "'")
            );
            _userProfileRecordList.add(_profileRecord);
            Repository.get().updateUserProfile(_userProfileRecordList);

          }

      });
      } catch(e) {
      }
        Navigator.of(context).pop();
      }
    });
  }

  void _fqtvLogin(String msgText) async {
    //progressMessagePage(context, translate(msgText), title:  '${gblSettings.fqtvName}');
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
        _loadingInProgress = false;
        Map<String, dynamic> map = json.decode(reply);
        FqtvLoginReply fqtvLoginReply = new FqtvLoginReply.fromJson(map);

        PaxManager.populateFromFqtvMember(fqtvLoginReply, fqtvNo, fqtvPass);
/*        if( gblPassengerDetail == null ) {
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
        if( fqtvLoginReply.dOB != null &&  fqtvLoginReply.dOB != ''){
          widget.passengerDetail!.dateOfBirth = DateTime.parse(fqtvLoginReply.dOB);
        }
        if(fqtvLoginReply.member != null && fqtvLoginReply.member!.country != '') {
          widget.passengerDetail!.country = fqtvLoginReply.member!.country;
        }

        gblPassengerDetail!.phonenumber = fqtvLoginReply.phoneMobile;
        if (gblPassengerDetail!.phonenumber == null ||
            gblPassengerDetail!.phonenumber.isEmpty) {
          gblPassengerDetail!.phonenumber =              fqtvLoginReply.phoneHome;
        }
        gblFqtvBalance = int.parse(fqtvLoginReply.balance);

        gblPassengerDetail!.email =fqtvLoginReply.email;
        widget.passengerDetail!.email = fqtvLoginReply.email;
        widget.joiningDate = fqtvLoginReply.joiningDate;*/
        //DateFormat('dd MMM yyyy').format(DateTime.parse(memberDetails.member.issueDate))
        widget.passengerDetail = gblPassengerDetail;
        gblError ='';
        _error = '';
        _isButtonDisabled = false;
        _loadingInProgress = false;
        _actionCompleted();

        setState(() {});

        //endProgressMessage();
//      setState(() {});
      } catch (e) {
        fqtvNo = '';
        fqtvPass = '';

        setError( e.toString());
        _isButtonDisabled = false;
        _loadingInProgress = false;

        print(gblError);
        _error = gblError;
        _loadingInProgress = false;
//        Navigator.of(context).pop();
        showVidDialog(context, 'Information', _error, onComplete: () {
          gblError = '';
          //Navigator.of(context).pop();
          setState(() {
            setError( '');
          });
        }
        );
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
      //endProgressMessage();
      criticalErrorPage(context, gblError, title: 'Login Error', wantButtons: true);

      _loadingInProgress = false;
      _actionCompleted();

      //Navigator.of(context).pop();
      return;
    }

  }


  Future _sendVRSCommand(msg, method) async {
    final http.Response response = await http.post(
        Uri.parse(gblSettings.apiUrl + "/FqTvMember/$method"),
        headers: getApiHeaders(),
        body: msg);

    if (response.statusCode == 200) {
      logit('message send successfully: $msg' );
      return response.body.trim();
    } else {
      logit('failed5: $msg');
      _error = translate('message failed');
      try{
        logit(response.body);
        _error = response.body;
      } catch(e){}

      _actionCompleted();
      _showDialog();
    }
  }

 void  _showTransactions(BuildContext context, dynamic p) async {
   isPending = false;
   _error = '';
   ApiFqtvGetDetailsRequest fqtvMsg = ApiFqtvGetDetailsRequest(fqtvEmail,
       fqtvNo,
       fqtvPass);
   String msg = json.encode(fqtvMsg.toJson());
   String method = 'GetTransactions';

   print(msg);
   _sendVRSCommand(msg, method).then((result){
     Map<String, dynamic> map = json.decode(result);
     ApiFqtvMemberTransactionsResp resp = new ApiFqtvMemberTransactionsResp.fromJson(map);
     if( resp.statusCode != 'OK') {
       _error = resp.message;
       _actionCompleted();
       _showDialog();

     } else {
       title = 'Awarded Transactions';
       transactions = resp.transactions;
       if( transactions != null && transactions!.length > 0) {
         transactions?.sort((a, b) {
           return b.transactionDateTime.compareTo(a.transactionDateTime);
         } );
       }
       setState(() {
       });
     }
   });
  }

  void  _showPendingTransactions(BuildContext context, dynamic p) async {
    isPending = true;
    ApiFqtvPendingRequest fqtvMsg = ApiFqtvPendingRequest(
        fqtvNo,
        fqtvPass);
    String msg = json.encode(fqtvMsg.toJson());
    String method = 'GetPendingTransactions';

    print(msg);
    _sendVRSCommand(msg, method).then((result){
      if( result == null ) {
        _error = 'No transactions found';
        _actionCompleted();
        _showDialog();
        transactions = null;
        return;
      }
      Map<String, dynamic> map = json.decode(result);
      ApiFqtvMemberTransactionsResp resp = new ApiFqtvMemberTransactionsResp.fromJson(map);
      if( resp.statusCode != 'OK') {
        _error = resp.message;
        _actionCompleted();
        _showDialog();
        transactions = null;

      } else {
        if( resp.transactions == null || resp.transactions!.length == 0 ){
          _error = 'No transactions found';
          _actionCompleted();
          _showDialog();
          transactions = null;

        } else {
          title = 'Pending Transactions';
          transactions = resp.transactions;
          if( transactions != null && transactions!.length > 0) {
            // sort into ascending flight date order
            transactions?.sort((a, b) {
              return a.flightDate.compareTo(b.flightDate);
            } );

            // remove duplicates
            final ids = Set();
            transactions!.retainWhere((x) => ids.add(x.pnr));
          }
          setState(() {});
        }
      }
    });
  }


  void _changePasswordDialog(BuildContext context, dynamic p ) {
    _oldPasswordEditingController.text = '';
    _newPasswordEditingController.text = '';

 /*   v3ShowDialog(context,translate('Change Password'),
    icon: Icons.person_pin,
      wantCancel: true,
      actionButtonText: 'Continue',
      onComplete: (c, refreshFunction){
        _fqtvChangePassword(refresh: refreshFunction);
      },*/
    List<Widget> actions = [];
      actions.add(vidCancelButton(context, "CANCEL", (context) {
        Navigator.of(context).pop();
      },),);
    actions.add(
        ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: gblSystemColors.primaryButtonColor,),
            child:
            (gblActionBtnDisabled) ? new Transform.scale(scale: 0.5,
                child: CircularProgressIndicator(color: Colors.white)) :
            TrText('Continue'),
            onPressed: () {
              if (gblActionBtnDisabled == false) {
                if (formKey!.currentState!.validate()) {
                  gblActionBtnDisabled = true;
                  _fqtvChangePassword();
                }
                //});
              }
            }
        )
    );


    showDialog(
      context: context,
      builder: (context) => new AlertDialog(
          actions: actions,
        shape: alertShape(),
        titlePadding: alertTitlePadding(),
        title: alertTitle(translate('Change Password'), gblSystemColors.headerTextColor!, gblSystemColors.primaryHeaderColor),
    content: Stack(
    children: <Widget>[
    Container(
    child: Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      v3FqtvPasswordFormField('Old password', _oldPasswordEditingController, validate: false ),
/*
    new TextFormField(
    decoration: getDecoration('Old password'),
    controller: _oldPasswordEditingController,
    obscureText: _isHidden,
    obscuringCharacter: "*",
    keyboardType: TextInputType.visiblePassword,
    ),
*/
    SizedBox(height: 15,),
      v3FqtvPasswordFormField('New Password', _newPasswordEditingController),
/*
    new TextFormField(
    controller: _newPasswordEditingController ,
    decoration: getDecoration('new Password'),
    obscureText: _isHidden,
    obscuringCharacter: "*",
    inputFormatters: [
    FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9!@%\$&*]"))
    ],
    keyboardType: TextInputType.visiblePassword,
    autovalidateMode: AutovalidateMode.onUserInteraction,
    validator: (value)  {
      return validateFqtvPassword(value);
        },

    onSaved: (value) {
    if (value != null) {
      }
    },
    ),
*/
    Padding(padding: EdgeInsets.all(5)),
    TrText('Password must contain the following:', textScaleFactor: 0.9,),
    TrText('- A lowercase letter', textScaleFactor: 0.75,),
    TrText('- A capital (uppercase) letter', textScaleFactor: 0.75,),
    TrText('- A number', textScaleFactor: 0.75,),
    TrText('- one of the following ! @ % & *', textScaleFactor: 0.75,),
    TrText('- Between 8 and 16 characters in length', textScaleFactor: 0.75,),
    ],
    ),
    ),
    ],
    )
    ));



 /*  showDialog(
       context: context,
       builder: (BuildContext context) {
   return AlertDialog(
     titlePadding: EdgeInsets.only(top: 0),
     title: Column(
         children: [
           ListTile(
             leading: Icon(Icons.person_pin, color: gblSystemColors.primaryButtonColor, size: 40,),
             title: Text(translate('Change Password')),
           ),
           Divider(
             color: Colors.grey,
             height: 4.0,
           ),
         ]),
     content:    Stack(
   children: <Widget>[
   Container(
     child: Column(
     mainAxisSize: MainAxisSize.min,
     crossAxisAlignment: CrossAxisAlignment.start,
     children: <Widget>[
       new TextFormField(
         decoration: getDecoration('Old password'),
         controller: _oldPasswordEditingController,
         obscureText: _isHidden,
         obscuringCharacter: "*",
         keyboardType: TextInputType.visiblePassword,
       ),
        SizedBox(height: 15,),
       new TextFormField(
         controller: _newPasswordEditingController ,
         decoration: getDecoration('new Password'),
         obscureText: _isHidden,
         obscuringCharacter: "*",
         inputFormatters: [
           FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9!@%\$&*]"))
         ],
         keyboardType: TextInputType.visiblePassword,
         autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (value)  {
              if(value != null && value.length >= 8 && value.length <= 16 ){
                String  pattern = r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@%\$&*]).{8,}$';
                RegExp regExp = new RegExp(pattern);
                logit('A-Z ${regExp.hasMatch(value)}');
                if(regExp.hasMatch(value)) {
                  return null;
                }
              }
              return 'invalid password';
          },
         onSaved: (value) {
           if (value != null) {
             //.contactInfomation.phonenumber = value.trim()
           }
         },
       ),
       Padding(padding: EdgeInsets.all(5)),
       TrText('Password must contain the following:', textScaleFactor: 0.9,),
       TrText('   A lowercase letter', textScaleFactor: 0.75,),
       TrText('   A capital (uppercase) letter', textScaleFactor: 0.75,),
       TrText('   A number', textScaleFactor: 0.75,),
       TrText('   one of the following ! @ % & *', textScaleFactor: 0.75,),
       TrText('Between 8 and 16 characters in length', textScaleFactor: 0.75,),
     ],
   ),
         ),
         ],
         ),
     actions: <Widget>[
       ElevatedButton(
         style: ElevatedButton.styleFrom(backgroundColor: cancelButtonColor()) ,
         child: TrText("CANCEL", style: TextStyle( color: Colors.black),),
         onPressed: () {
           //Put your code here which you want to execute on Cancel button click.
           Navigator.of(context).pop();
         },
       ),
       ElevatedButton(
         style: ElevatedButton.styleFrom(backgroundColor: gblSystemColors.primaryButtonColor),
           child:
         _isButtonDisabled ? Row( children: [
             _isButtonDisabled ? new CircularProgressIndicator() : Container(),
         Padding(
         padding: _isButtonDisabled ? EdgeInsets.all(8.0) :EdgeInsets.all(0) ,
         child: TrText("CONTINUE"),
         )
         ]) : TrText("CONTINUE"),
         onPressed: () {
           if( _isButtonDisabled == false ) {
             _isButtonDisabled = true;
             setState(() {
               /// force disable
             });
             _fqtvChangePassword();
           }

           //});

           //Navigator.of(context).pop();
         },
       ),


     ],
   );
   });*/
 }


 /*void _resetPasswordDialog() {


   v3ShowDialog(context,translate('Reset Password'),
      icon: Icons.password,
      content: Stack(
        children: <Widget>[
          Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
               // v3EmailFormField(translate('Email'), _oldPasswordEditingController),
                new TextFormField(
                  decoration: InputDecoration(
                    contentPadding:
                    new EdgeInsets.symmetric(
                        vertical: 15.0, horizontal: 15.0),
                    labelText: translate('Email'),
                    fillColor: Colors.white,
                    border: new OutlineInputBorder(
                      borderRadius: new BorderRadius.circular(15.0),
                      borderSide: new BorderSide(),
                    ),),
                  controller: _oldPasswordEditingController,
                  keyboardType: TextInputType.emailAddress,
                  //validator: (value) => validateEmail(value.trim()),
                  // keyboardType: TextInputType.text,
                ),
                SizedBox(height: 15,),
              ],
            ),
          ),
        ],
      ),
      wantCancel: true,
     actionButtonText: 'Continue',
     onComplete: (c,  void Function()? refresh ){
       _fqtvResetPassword(refresh: refresh );
     }
   );

*//*
   showDialog(
       context: context,
       builder: (BuildContext context)
   {
     return StatefulBuilder(
         builder: (context, setState) {
           return AlertDialog(
             titlePadding: EdgeInsets.only(top: 0),
             title: Column(
                 children: [
                   ListTile(
                     leading: Icon(
                       Icons.person_pin, color: gblSystemColors.primaryHeaderColor, size: 40,),
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
                       new TextFormField(
                         decoration: InputDecoration(
                           contentPadding:
                           new EdgeInsets.symmetric(
                               vertical: 15.0, horizontal: 15.0),
                           labelText: translate('Email'),
                           fillColor: Colors.white,
                           border: new OutlineInputBorder(
                             borderRadius: new BorderRadius.circular(15.0),
                             borderSide: new BorderSide(),
                           ),),
                         controller: _oldPasswordEditingController,
                         keyboardType: TextInputType.emailAddress,
                         //validator: (value) => validateEmail(value.trim()),
                         // keyboardType: TextInputType.text,
                       ),
                       SizedBox(height: 15,),
                     ],
                   ),
                 ),
               ],
             ),
             actions: <Widget>[
               vidCancelButton(context, "CANCEL", (context) {
                 Navigator.of(context).pop();
               },
               ),
               ElevatedButton(
                 style: ElevatedButton.styleFrom(backgroundColor: gblSystemColors.primaryButtonColor,),
                 child:
                 (_isButtonDisabled) ? new Transform.scale(scale: 0.5,
                     child: CircularProgressIndicator(color: Colors.white)) :
                 TrText("CONTINUE"),
                 onPressed: () {
                   if (_isButtonDisabled == false) {
                     var str = validateEmail(
                         _oldPasswordEditingController.text);
                     if (str == null || str == '') {
                       _isButtonDisabled = true;
                       setState(() {

                       });
                       _fqtvResetPassword();
                     } else {
                       _error = str;
                       _actionCompleted();
                       _showDialog();
                     }
                     //});
                   }
                 },
               ),
             ],
           );
         });
   }
    );
*//*
 }*/
  void resetPasswordDialog() {

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            titlePadding: EdgeInsets.only(top: 0),
            title: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.person_pin, color: Colors.red, size: 40,),
                    title: TrText('Reset Password'),
                  ),
                  Divider(
                    color: Colors.grey,
                    height: 4.0,
                  ),
                ]),

            content:    Stack(
              children: <Widget>[
                Container(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      new TextFormField(
                        decoration: InputDecoration(
                          contentPadding:
                          new EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
                          labelText: translate('Email'),
                          fillColor: Colors.white,
                          border: new OutlineInputBorder(
                            borderRadius: new BorderRadius.circular(15.0),
                            borderSide: new BorderSide(),
                          ),),
                        controller: _oldPasswordEditingController,
                        keyboardType: TextInputType.emailAddress,
                        //validator: (value) => validateEmail(value.trim()),
                        // keyboardType: TextInputType.text,
                      ),
                      SizedBox(height: 15,),
                    ],
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              ElevatedButton(
                style: ElevatedButton.styleFrom(foregroundColor: Colors.black,backgroundColor: Colors.grey.shade200) ,
                child: TrText("CANCEL", style: TextStyle(backgroundColor: Colors.grey.shade200, color: Colors.black),),
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
                    _fqtvResetPassword(_oldPasswordEditingController.text);
                  } else {
                    _error = str;
                    _actionCompleted();
                    _showDialog();
                  }
                  //});
                }
                  //Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }
}


class FqtvSummaryBox extends StatefulWidget {
  String joiningDate='';

  FqtvSummaryBox();

  @override
  State<StatefulWidget> createState() => new FqtvSummaryBoxState();
}

class FqtvSummaryBoxState extends State<FqtvSummaryBox> {
  @override void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> list = [];
    return Text('Fqtv Summary');
  }

  }

void fqtvResetPassword(BuildContext context, String email, {void Function()? refresh }) async {
  String msg = json.encode(ApiFqtvResetPasswordRequest(
      email).toJson());
  String method = 'ResetPassword';

  //print(msg);
  sendVRSCommand(msg, ApiMethod:  "/FqTvMember/ResetPassword").then((resultin){
    String result = resultin;
    gblActionBtnDisabled = false;
    //if( refresh != null ) refresh();
    if( result.startsWith('{')) {
      Map<String, dynamic> map = json.decode(result);
      ApiResponseStatus resp = new ApiResponseStatus.fromJson(map);
      //_isButtonDisabled = false;
      if (resp.statusCode != 'OK') {
/*
      _error = resp.message;
      _actionCompleted();
      _showDialog();
*/
        showVidDialog(context, 'Error', resp.message);
      } else {
/*
      _error = resp.message;
      _actionCompleted();
      _error = 'Reset email sent';
*/
        Navigator.of(context).pop();
        //_showDialog();
        showVidDialog(context, 'Information', 'Reset email sent');
      }
    } else {
      showVidDialog(context, 'Error', result, type: DialogType.Error);
    }
  });

}
