import 'package:flutter/material.dart';
import 'package:vmba/data/repository.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:vmba/data/globals.dart';

import 'package:vmba/data/models/models.dart';
import 'package:vmba/data/models/user_profile.dart';
import 'package:vmba/components/trText.dart';
import 'package:vmba/utilities/helper.dart';
import 'package:vmba/components/showDialog.dart';

import '../Helpers/networkHelper.dart';
import '../components/vidButtons.dart';
import '../data/models/vrsRequest.dart';
import '../data/smartApi.dart';
import '../utilities/messagePages.dart';
import '../utilities/widgets/appBarWidget.dart';

//ignore: must_be_immutable
class MyFqtvPage extends StatefulWidget {
  MyFqtvPage(
      {Key key, this.passengerDetail, this.isAdsBooking, this.isLeadPassenger})
      : super(key: key);

  _MyFqtvPageState createState() => _MyFqtvPageState();

  PassengerDetail passengerDetail;
  String joiningDate;
  final bool isAdsBooking;
  final bool isLeadPassenger;


}


class _MyFqtvPageState extends State<MyFqtvPage> {
  TextEditingController _fqtvTextEditingController =   TextEditingController();
  TextEditingController _passwordEditingController =   TextEditingController();
  TextEditingController _emailEditingController =   TextEditingController();
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
  bool _isButtonDisabled;
  bool isPending = false;
  ApiFqtvMemberDetailsResponse memberDetails;
  List<ApiFQTVMemberTransaction> transactions;

  List<UserProfileRecord> userProfileRecordList;
  final formKey = new GlobalKey<FormState>();
//  bool _loadingInProgress = false;
  String _error;
  bool _isHidden = true;
  bool _loadingInProgress = false;
  String title;


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
        gblPassengerDetail.fqtv != null && gblPassengerDetail.fqtv.isNotEmpty &&
        gblPassengerDetail.fqtvPassword != null && gblPassengerDetail.fqtvPassword.isNotEmpty) {
      widget.passengerDetail = gblPassengerDetail;
      fqtvNo = gblPassengerDetail.fqtv;
      fqtvPass = gblPassengerDetail.fqtvPassword;
    } else {
      Repository.get()
          .getNamedUserProfile('PAX1').then((profile) {
        if (profile != null) {
          widget.passengerDetail.firstName = profile.name.toString();
          try {
            Map map = json.decode(
                profile.value.toString().replaceAll(
                    "'", '"')); // .replaceAll(',}', '}')
            widget.passengerDetail = PassengerDetail.fromJson(map);
            gblPassengerDetail =widget.passengerDetail;
          } catch (e) {
            print(e);
          }
          _titleTextEditingController.text = widget.passengerDetail.title;
          _firstNameTextEditingController.text =
              widget.passengerDetail.firstName;
          _lastNameTextEditingController.text = widget.passengerDetail.lastName;
          _emailTextEditingController.text = widget.passengerDetail.email;
          _phoneNumberTextEditingController.text =
              widget.passengerDetail.phonenumber;
          _dateOfBirthTextEditingController.text =
              widget.passengerDetail.dateOfBirth.toString();

          _adsNumberTextEditingController.text =
              widget.passengerDetail.adsNumber;
          _adsPinTextEditingController.text = widget.passengerDetail.adsPin;

          if (widget.passengerDetail.paxType == null) {
            widget.passengerDetail.paxType = PaxType.adult;
          }
        }
      });
    }
    // _displayProcessingIndicator = false;

    if( gblPassengerDetail != null && gblPassengerDetail.fqtv != null &&
        gblPassengerDetail.fqtv.isNotEmpty &&
        gblPassengerDetail.fqtvPassword != null &&
        gblPassengerDetail.fqtvPassword.isNotEmpty) {
      // set up for login
      _fqtvTextEditingController.text = gblPassengerDetail.fqtv;
      _passwordEditingController.text = gblPassengerDetail.fqtvPassword;

      //_fqtvLogin();

    }

  }

  @override
  Widget build(BuildContext context) {
   // gblActionBtnDisabled = false;
    if (_loadingInProgress) {
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
    } else if( gblFqtvLoggedIn == false || widget.passengerDetail == null || widget.passengerDetail.fqtv == null ||
        widget.passengerDetail.fqtv.isEmpty || widget.passengerDetail.fqtvPassword == null ||
        widget.passengerDetail.fqtvPassword.isEmpty  ) {
      Color titleBackClr = gblSystemColors.primaryHeaderColor;
      if( titleBackClr == Colors.white) {
        titleBackClr = gblSystemColors.primaryButtonColor;
      }
      try {
        endProgressMessage();
      } catch(e) {

      }
      Widget flexibleSpace = Padding(padding: EdgeInsets.all(30,));
      if( gblSettings.pageImageMap != null ) {
        Map pageMap = json.decode(gblSettings.pageImageMap.toUpperCase());
        String pageImage = pageMap['FQTV'];

        if( pageImage != null && pageImage.isNotEmpty){
          NetworkImage backgroundImage = NetworkImage('${gblSettings.gblServerFiles}/pageImages/$pageImage.png');
          flexibleSpace = Image(
            image:
            backgroundImage,
            fit: BoxFit.cover,);
          //backgroundColor = Colors.transparent;

        }
      }

      return  Scaffold(
       /*   appBar: AppBar(
            flexibleSpace: flexibleSpace,
            toolbarHeight: 400,
            backgroundColor: Colors.transparent,
            title: Text(''),
            automaticallyImplyLeading: false,
          ),*/
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
                  color: titleBackClr,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0),)),
              padding: EdgeInsets.only(left: 10, top: 10, bottom: 10),
              child: Text(translate('${gblSettings.fqtvName} ') + translate('LOGIN'),
                style: TextStyle(color: Colors.white),)
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
            padding: const EdgeInsets.only(top: 20.0),
            child: Column(
              children:  _getWidgets()
              ,
            ),
          ),
        ),
      ),
    );
    // });
  }

    contentBox(context){
    return
        Stack(
          children: <Widget>[ Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              new TextFormField(
                decoration: getDecoration( '${gblSettings.fqtvName} ' + translate('number')),
                controller: _fqtvTextEditingController,
                keyboardType: TextInputType.phone,
                onSaved: (value) {
                  if (value != null) {
                    //.contactInfomation.phonenumber = value.trim()
                  }
                },
              ),

              SizedBox(height: 15,),
              new TextFormField(
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
              ),
              new TextButton(
                child: new TrText(
                  'Reset Password',
                  style: TextStyle(color: Colors.black),
                ),
                style: TextButton.styleFrom(primary: Colors.white, side: BorderSide(color: Colors.grey.shade300, width: 2)),
                onPressed: () {
                  _resetPasswordDialog();
                },
              ),
              Row(
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
                    style: ElevatedButton.styleFrom(primary: gblSystemColors.primaryButtonColor),
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
                          _showDialog();
                        }
                      }
                      //});

                      //Navigator.of(context).pop();
                    },
                  ),
                ],
              )
            ],
          )],
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
    String joining = widget.joiningDate ;
    if( joining == null) joining = '';
    if( joining.length > 11) joining = joining.substring(0,11);

if (widget.passengerDetail != null) {
  if( widget.passengerDetail.firstName != null &&
    widget.passengerDetail.firstName.isNotEmpty && widget.passengerDetail.lastName != null &&
    widget.passengerDetail.lastName.isNotEmpty) {

    name = widget.passengerDetail.firstName + ' ' +widget.passengerDetail.lastName;
  }
  if ( widget.passengerDetail.email != null ) {
    email = widget.passengerDetail.email;
  }
  if ( widget.passengerDetail.fqtv != null ) {
    fqtv = widget.passengerDetail.fqtv;
  }
}
if ( memberDetails != null ) {
  name = memberDetails.member.title + ' ' + memberDetails.member.firstname + ' ' + memberDetails.member.surname ;
  email = memberDetails.member.email;

}
if( widget.joiningDate != null && widget.joiningDate.isNotEmpty) {
  try {
  joining = DateFormat('dd MMM yyyy').format(DateTime.parse(widget.joiningDate));
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


    widgets.add(vidWideActionButton(context, 'Show Transactions', _showTransactions, wantIcon: false));
    widgets.add(vidWideActionButton(context, 'Refresh Points', _reloadPoints, wantIcon: false));
 /*   widgets.add(ElevatedButton(
      onPressed: () {
        isPending = false;
        _showTransactions();
      },
      style: ElevatedButton.styleFrom(
          primary: gblSystemColors
              .primaryButtonColor, //Colors.black,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0))),
      child:
          TrText(
            'Show Transactions',
            style: TextStyle(color: Colors.white),)
    ));*/
    widgets.add(vidWideActionButton(context, 'Show Pending Transactions', _showPendingTransactions, wantIcon: false));
/*
    widgets.add(ElevatedButton(
        onPressed: () {
          isPending = true;
          _showPendingTransactions();
        },
        style: ElevatedButton.styleFrom(
            primary: gblSystemColors
                .primaryButtonColor, //Colors.black,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0))),
        child:
        TrText(
          'Show Pending Transactions',
          style: TextStyle(color: Colors.white),)
    ));
*/
    widgets.add(vidWideActionButton(context, 'Change Password', _changePasswordDialog, wantIcon: false));

 /*   widgets.add(ElevatedButton(
        style: ElevatedButton.styleFrom(
            primary: gblSystemColors
                .primaryButtonColor, //Colors.black,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0))),
        child: TrText("Change Password"),
        onPressed: () {
          _changePasswordDialog();
          //Navigator.of(context).pop();
        }));
*/
    widgets.add(vidWideActionButton(context, 'Book a flight', _bookAFlight, wantIcon: false));
 /*   widgets.add(ElevatedButton(
      style: ElevatedButton.styleFrom(
          primary: gblSystemColors
              .primaryButtonColor, //Colors.black,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0))),
      child: TrText("Book a flight"),
      onPressed: () {
        List<String> args = [];
        args.add('wantRedeemMiles');
        Navigator.of(context).pushNamedAndRemoveUntil(
            '/FlightSearchPage', (Route<dynamic> route) => false, arguments: args);
      },
    ));
*/
    widgets.add(vidWideActionButton(context, 'Logout', _logout, wantIcon: false));

 /*   widgets.add(ElevatedButton(
      style: ElevatedButton.styleFrom(
          primary: gblSystemColors
              .primaryButtonColor, //Colors.black,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0))),
      child: TrText("Logout"),
      onPressed: () {
        gblFqtvNumber = "";
        widget.passengerDetail.fqtv = '';
        fqtvNo = '';
        fqtvEmail = '';
        fqtvPass = '';
        gblFqtvBalance = 0;
        Navigator.of(context).pushNamedAndRemoveUntil(
            '/HomePage', (Route<dynamic> route) => false);
      },
    ));*/

    if(_error != null && _error.isNotEmpty){
      widgets.add(Text(_error));
    }

    if( transactions != null ) {
          widgets.add(_getTrans());
 /*     widgets.add(new SingleChildScrollView(
        padding: EdgeInsets.only(left: 1.0, right: 1.0),
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
            child: _getTrans()
        ),
      ));*/
   }
    return widgets;
  }

  void _reloadPoints(BuildContext context, dynamic p) {
    _fqtvLogin();
  }

  void _logout(BuildContext context, dynamic p) {
    gblFqtvNumber = "";
    gblFqtvLoggedIn = false;
    gblRedeemingAirmiles = false;
    widget.passengerDetail.fqtv = '';
    fqtvNo = '';
    fqtvEmail = '';
    fqtvPass = '';
    gblPassengerDetail.fqtv = '';
    gblPassengerDetail.fqtvPassword = '';
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

  for(var tran in  transactions) {
    if(( tran.airMiles != '0' && tran.airMiles != '0.0' ) || isPending) {

      List<Widget> list = [];

      if( isPending ){
        list.add(Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            tran.flightDate  == null ? Text('') : Text(DateFormat(
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
            tran.transactionDateTime == null ? Text('') : Text(DateFormat(
                'dd MMM yyyy').format(DateTime.parse(tran.transactionDateTime)), textScaleFactor: 1.2,
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text(' '),
            Text( tran.pnr, textScaleFactor: 1.2, style: TextStyle(fontWeight: FontWeight.bold),),
          ],  ));
      }

      if( tran.flightNumber.isNotEmpty ) {
        list.add(Row(
          children: [
            //Padding(padding: EdgeInsets.only(right: 8.0),child: Icon(Icons.favorite,color: Colors.green,),),
            Text(tran.flightNumber),
            Text(' '),
            Text(tran.departureCityCode,),
            Text(' '),
            Text(tran.arrivalCityCode),
            Text(' '),
            if(tran.flightDate.isNotEmpty &&
                (!tran.flightDate.startsWith(('0001'))) )Text(
                DateFormat('ddMMMyy').format(DateTime.parse(tran.flightDate))),
          ],));
      }

  list.add(Row(
  children: [
  Expanded(
  child: Container(
  child: Text(tran.description ,
  maxLines: 5, overflow: TextOverflow.ellipsis,)))]));

  // third row
  if( getAirMilesDisplayValue(tran.airMiles) != '') {
    list.add(Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(getAirMilesDisplayValue(tran.airMiles), textScaleFactor: 1.2,
          style: TextStyle(fontWeight: FontWeight.bold),),
      ],
    ));
  }

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
    form.save();
  }

  String validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value))
      return 'Enter Valid Email';
    else
      return null;
  }
  void _actionCompleted() {
    setState(() {
//      _loadingInProgress = false;
    });
  }

  void _showDialog() {
    showAlertDialog(context, 'Error', _error);
    return;
    // flutter defined function
  }

  void _fqtvResetPassword() async {
    String msg = json.encode(ApiFqtvResetPasswordRequest(
        _oldPasswordEditingController.text).toJson());
    String method = 'ResetPassword';

    //print(msg);
    _sendVRSCommand(msg, method).then((result){
      Map map = json.decode(result);
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
        showAlertDialog(context, 'Information', _error);
      }
    });

  }

  void _fqtvChangePassword() async {
    String msg = json.encode(ApiFqtvChangePasswordRequest(fqtvNo,
          _oldPasswordEditingController.text,
          _newPasswordEditingController.text).toJson());
    String method = 'ChangePassword';

    //print(msg);
    _sendVRSCommand(msg, method).then((result){
      Map map = json.decode(result);
      ApiResponseStatus resp = new ApiResponseStatus.fromJson(map);
      if( resp.statusCode != 'OK') {
        _error = resp.message;
        _actionCompleted();
        _showDialog();

      } else {
        _error = resp.message;
        _actionCompleted();
        gblPassengerDetail.fqtvPassword = _newPasswordEditingController.text;
        fqtvPass = _newPasswordEditingController.text;
        // save new password in profile
        Repository.get().getNamedUserProfile('PAX1').then((profile) {
          if (profile != null) {
            Map map = json.decode(
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

        Navigator.of(context).pop();
      });
      }
    });
  }

  void _fqtvLogin() async {
    progressMessagePage(context, translate('Login'), title:  '${gblSettings.fqtvName}');
    gblRedeemingAirmiles = false;
    try {
      FqtvLoginRequest rq = new FqtvLoginRequest( user: _fqtvTextEditingController.text, password: _passwordEditingController.text);
      fqtvNo = _fqtvTextEditingController.text;
      fqtvPass = _passwordEditingController.text;

      String data = json.encode(rq);
      try {
        String reply = await callSmartApi('FQTVLOGIN', data);
        Map map = json.decode(reply);
        FqtvLoginReply fqtvLoginReply = new FqtvLoginReply.fromJson(map);

        if( gblPassengerDetail == null ) {
          gblPassengerDetail = new PassengerDetail( email:  '', phonenumber: '');
        }
        gblFqtvLoggedIn = true;
        gblPassengerDetail.fqtv = fqtvNo;
        gblPassengerDetail.fqtvPassword = fqtvPass;
        widget.passengerDetail.fqtv = fqtvNo;
        widget.passengerDetail.fqtvPassword = fqtvPass;

        gblPassengerDetail.title = fqtvLoginReply.title;
        gblPassengerDetail.firstName = fqtvLoginReply.firstname;
        gblPassengerDetail.lastName = fqtvLoginReply.surname;
        widget.passengerDetail.firstName = fqtvLoginReply.firstname;
        widget.passengerDetail.lastName = fqtvLoginReply.surname;

        gblPassengerDetail.phonenumber = fqtvLoginReply.phoneMobile;
        if (gblPassengerDetail.phonenumber == null ||
            gblPassengerDetail.phonenumber.isEmpty) {
          gblPassengerDetail.phonenumber =              fqtvLoginReply.phoneHome;
        }
        gblFqtvBalance = int.parse(fqtvLoginReply.balance);

        gblPassengerDetail.email =fqtvLoginReply.email;
        widget.passengerDetail.email = fqtvLoginReply.email;
        widget.joiningDate = fqtvLoginReply.joiningDate;
        //DateFormat('dd MMM yyyy').format(DateTime.parse(memberDetails.member.issueDate))
        gblError ='';
        _isButtonDisabled = false;
        _loadingInProgress = false;
        _actionCompleted();

        setState(() {});

        endProgressMessage();
//      setState(() {});
      } catch (e) {
        fqtvNo = '';
        fqtvPass = '';

        gblError = e.toString();
        _isButtonDisabled = false;
        _loadingInProgress = false;
        //_actionCompleted();
        endProgressMessage();
        criticalErrorPage(context, gblError, title: 'Login Error');
        print(gblError);
        _error = gblError;
        //_showDialog();
      }
    } catch(e){
      fqtvNo = '';
      fqtvPass = '';

      _error = e.toString();
      _isButtonDisabled = false;
      _loadingInProgress = false;
      //_actionCompleted();
      //_showDialog();
      endProgressMessage();
      criticalErrorPage(context, gblError, title: 'Login Error');
      return;
    }

  }


  Future _sendVRSCommand(msg, method) async {
    final http.Response response = await http.post(
        Uri.parse(gblSettings.apiUrl + "/FqTvMember/$method"),
        headers: getApiHeaders(),
        body: msg);

    if (response.statusCode == 200) {
      print('message send successfully: $msg' );
      return response.body.trim();
    } else {
      print('failed5: $msg');
      _error = translate('message failed');
      try{
        print (response.body);
        _error = response.body;
      } catch(e){}

      _actionCompleted();
      _showDialog();
    }
  }

 void  _showTransactions(BuildContext context, dynamic p) async {
   isPending = false;
   ApiFqtvGetDetailsRequest fqtvMsg = ApiFqtvGetDetailsRequest(fqtvEmail,
       fqtvNo,
       fqtvPass);
   String msg = json.encode(fqtvMsg.toJson());
   String method = 'GetTransactions';

   print(msg);
   _sendVRSCommand(msg, method).then((result){
     Map map = json.decode(result);
     ApiFqtvMemberTransactionsResp resp = new ApiFqtvMemberTransactionsResp.fromJson(map);
     if( resp.statusCode != 'OK') {
       _error = resp.message;
       _actionCompleted();
       _showDialog();

     } else {
       title = 'Awarded Transactions';
       transactions = resp.transactions;
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

        return;
      }
      Map map = json.decode(result);
      ApiFqtvMemberTransactionsResp resp = new ApiFqtvMemberTransactionsResp.fromJson(map);
      if( resp.statusCode != 'OK') {
        _error = resp.message;
        _actionCompleted();
        _showDialog();

      } else {
        title = 'Pending Transactions';
        transactions = resp.transactions;
        setState(() {
        });
      }
    });
  }


  void _changePasswordDialog(BuildContext context, dynamic p ) {
   showDialog(
       context: context,
       builder: (BuildContext context) {
   return AlertDialog(
     titlePadding: EdgeInsets.only(top: 0),
     title: Column(
         children: [
           ListTile(
             leading: Icon(Icons.person_pin, color: Colors.red, size: 40,),
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
         keyboardType: TextInputType.visiblePassword,

         onSaved: (value) {
           if (value != null) {
             //.contactInfomation.phonenumber = value.trim()
           }
         },
       ),
     ],
   ),
         ),
         ],
         ),
     actions: <Widget>[
       ElevatedButton(
         style: ElevatedButton.styleFrom(primary: Colors.black12) ,
         child: TrText("CANCEL", style: TextStyle(backgroundColor: Colors.black12, color: Colors.black),),
         onPressed: () {
           //Put your code here which you want to execute on Cancel button click.
           Navigator.of(context).pop();
         },
       ),
       ElevatedButton(
         child: TrText("CONTINUE"),
         onPressed: () {
           _fqtvChangePassword();

           //});

           //Navigator.of(context).pop();
         },
       ),


     ],
   );
   });
 }

 void _resetPasswordDialog() {

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
               style: ElevatedButton.styleFrom(primary: Colors.black12) ,
               child: TrText("CANCEL", style: TextStyle(backgroundColor: Colors.black12, color: Colors.black),),
               onPressed: () {
                 //Put your code here which you want to execute on Cancel button click.
                 Navigator.of(context).pop();
               },
             ),
             ElevatedButton(
               child: TrText("CONTINUE"),
               onPressed: () {
                 var str = validateEmail(_oldPasswordEditingController.text);
                 if( str == null ) {
                   _fqtvResetPassword();
                 } else {
                   _error = str;
                   _actionCompleted();
                   _showDialog();
                 }
                 //});

                 //Navigator.of(context).pop();
               },
             ),
           ],
         );
       });
 }
}