import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
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

class MyFqtvPage extends StatefulWidget {
  MyFqtvPage(
      {Key key, this.passengerDetail, this.isAdsBooking, this.isLeadPassenger})
      : super(key: key);

  _MyFqtvPageState createState() => _MyFqtvPageState();

  PassengerDetail passengerDetail;
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
  ApiFqtvMemberDetailsResponse memberDetails;
  List<ApiFQTVMemberTransaction> transactions;

  List<UserProfileRecord> userProfileRecordList;
  final formKey = new GlobalKey<FormState>();
//  bool _loadingInProgress = false;
  String _error;
  bool _isHidden = true;
  bool _loadingInProgress = false;


  @override
  initState() {
    super.initState();
    _isButtonDisabled = false;
   // _loadingInProgress = true;
    _isHidden = true;
    widget.passengerDetail = new PassengerDetail( email:  '', phonenumber: '');
    if( gblPassengerDetail != null &&
        gblPassengerDetail.fqtv != null && gblPassengerDetail.fqtv.isNotEmpty &&
        gblPassengerDetail.fqtvPassword != null && gblPassengerDetail.fqtvPassword.isNotEmpty) {
      widget.passengerDetail = gblPassengerDetail;
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

      _fqtvLogin();

    }

  }

  @override
  Widget build(BuildContext context) {
    if (_loadingInProgress) {
      return Scaffold(
        body: new Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              new CircularProgressIndicator(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: new Text("Checking details..."),
              ),
            ],
          ),
        ),
      );
    } else if( widget.passengerDetail == null || widget.passengerDetail.fqtv == null ||
        widget.passengerDetail.fqtv.isEmpty || widget.passengerDetail.fqtvPassword.isEmpty  ) {

      return AlertDialog(
        title: Row(
            children:[
              Image.network('$gblServerFiles/images/lock_user_man.png',
                width: 25, height: 25, fit: BoxFit.contain,),
              TrText('${gblSettings.fqtvName} LOGIN')
            ]
        ),
        content: contentBox(context),
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
            child: Row(
                children: <Widget>[
              (_isButtonDisabled) ?
                new Transform.scale(
                  scale: 0.5,
                  child: CircularProgressIndicator(),
                )   :
                Icon(Icons.check,
              color: Colors.white,
            ),_isButtonDisabled ?  new TrText("Logging in...", style: TextStyle(color: Colors.white)) : TrText('CONTINUE',
              style: TextStyle(color: Colors.white))]),
            onPressed: () {
              if ( _isButtonDisabled == false ) {
                if( _fqtvTextEditingController.text.isNotEmpty && _passwordEditingController.text.isNotEmpty) {
                  _isButtonDisabled = true;
                  _loadingInProgress = true;
                  setState(() {

                  });
                  _fqtvLogin();

                } else {
                  _error = "Please complete both fields";
                  _loadingInProgress = false;
                  _isButtonDisabled = false ;
                 // _actionCompleted();
                  _showDialog();


                }
              }
              //});

             //Navigator.of(context).pop();
            },
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: gblSettings.wantLeftLogo ? Padding(
            padding: EdgeInsets.only(left: 10.0),
            child: Image.asset(
                'lib/assets/$gblAppTitle/images/appBarLeft.png',
                color: Color.fromRGBO(255, 255, 255, 0.1),
                colorBlendMode: BlendMode.modulate)) : Text(''),
        brightness: gblSystemColors.statusBar,
        backgroundColor:
        gblSystemColors.primaryHeaderColor,
        iconTheme: IconThemeData(
            color: gblSystemColors.headerTextColor),
        title: TrText('My ${gblSettings.fqtvName}',
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
    return Stack(
      children: <Widget>[
        Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              new TextFormField(
                decoration: InputDecoration(
                  contentPadding:
                  new EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
                  labelText: '${gblSettings.fqtvName} Number',
                  fillColor: Colors.white,
                  border: new OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(15.0),
                    borderSide: new BorderSide(),
                  ),
                ),
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
                decoration: InputDecoration(
                  contentPadding:
                  new EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
                  labelText: 'Password',
                  fillColor: Colors.white,
                  border: new OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(15.0),
                    borderSide: new BorderSide(),
                  ),
                  suffix: InkWell(
                    onTap: _togglePasswordView,
                    child: Icon( Icons.visibility),
                  ),
                ),
                keyboardType: TextInputType.visiblePassword,



                onSaved: (value) {
                  if (value != null) {
                    //.contactInfomation.phonenumber = value.trim()
                  }
                },
              ),
              new TextButton(
                child: new Text(
                  'Reset password',
                  style: TextStyle(color: Colors.black),
                ),
                style: TextButton.styleFrom(primary: Colors.white),
                onPressed: () {
                  _resetPasswordDialog();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
  void _togglePasswordView() {
    setState(() {
      _isHidden = !_isHidden;
    });
  }

  List<Widget> _getWidgets() {
    List<Widget> widgets = [];
    String name = '';
    String email = '';
    String fqtv = '';
    String joining = '' ;

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
  joining = DateFormat('dd MMM yyyy').format(DateTime.parse(memberDetails.member.issueDate));
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
                    style: new TextStyle(
                        fontSize: 14.0, fontWeight: FontWeight.w300)),
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
                  style: new TextStyle(
                      fontSize: 14.0, fontWeight: FontWeight.w300)),
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
                  style: new TextStyle(
                      fontSize: 14.0, fontWeight: FontWeight.w300)),
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
              new Text(joining,
                  style: new TextStyle(
                      fontSize: 14.0, fontWeight: FontWeight.w300)),
            ],
          ),
        ],
      ),
    ),);

    widgets.add(ElevatedButton(
      onPressed: () {
        _showTransactions();
      },
      style: ElevatedButton.styleFrom(
          primary: gblSystemColors
              .primaryButtonColor, //Colors.black,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0))),
      child:
          Text(
            'Show Transactions',
            style: TextStyle(color: Colors.white),)
    ));

    widgets.add(ElevatedButton(
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

    widgets.add(ElevatedButton(
      style: ElevatedButton.styleFrom(
          primary: gblSystemColors
              .primaryButtonColor, //Colors.black,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0))),
      child: TrText("Book a flight"),
      onPressed: () {
        Navigator.of(context).pushNamedAndRemoveUntil(
            '/FlightSearchPage', (Route<dynamic> route) => false);
      },
    ));

    if(_error != null && _error.isNotEmpty){
      widgets.add(Text(_error));
    }

    if( transactions != null ) {
      widgets.add(new SingleChildScrollView(
        padding: EdgeInsets.only(left: 1.0, right: 1.0),
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
            child: _getTrans()
        ),
      ));
      /*
      widgets.add(new SingleChildScrollView(
        padding: EdgeInsets.only(left: 1.0, right: 1.0),
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
              columnSpacing: 1.0,
              columns: <DataColumn>[
              DataColumn(
                label: Text('Pnr',  style: TextStyle(fontSize: 10.0)),
              ),
              DataColumn(
                label: Text('Flt No', style: TextStyle(fontSize: 10.0)),
              ),
              DataColumn(label: Text('Dep', style: TextStyle(fontSize: 10.0)),
              ),
              DataColumn(label: Text('Dest', style: TextStyle(fontSize: 10.0)),),
              DataColumn(label: Text('Date', style: TextStyle(fontSize: 10.0)),),
              DataColumn(label: Text('Miles', style: TextStyle(fontSize: 10.0)),),
              DataColumn(label: Text('Desc', style: TextStyle(fontSize: 10.0)),),
            ],
            rows:   _getDataCells()
              ),
        ),
          ));

       */
   }
    return widgets;
  }
Widget _getTrans() {
  List<Widget> tranWidgets = [];

  for(var tran in  transactions) {
    if( tran.airMiles != '0' && tran.airMiles != '0.0') {

      tranWidgets.add(Container(
        width: MediaQuery.of(context).size.width * 0.95 ,
        margin: EdgeInsets.all(1.0),
        padding: EdgeInsets.all(2.0),
        decoration: BoxDecoration(
          color: Colors.grey,
          border: Border.all(),
          borderRadius: BorderRadius.all(Radius.circular(3.0))
        ),
        child: Column(

          // this makes the column height hug its content
          mainAxisSize: MainAxisSize.min,
          children: [

      // first row
      Row(
      children: [
      //Padding(padding: EdgeInsets.only(right: 8.0),child: Icon(Icons.favorite,color: Colors.green,),),
        Text( tran.flightNumber), Text(' '),
        Text(tran.departureCityCode ,style: TextStyle(color: Colors.white,  )), Text(' '),
        Text(tran.arrivalCityCode), Text(' '),
        if(tran.flightDate.isNotEmpty && (!tran.flightDate.startsWith(('0001')))  )Text(DateFormat('ddMMMyy').format(DateTime.parse(tran.flightDate)), style: TextStyle(color: Colors.white,  )),

        ],  ),

  // second row (single item)
          Row(
              children: [
        Expanded(
          child: Container(
            child: Text(tran.description ,
            maxLines: 5,
            style: TextStyle( color: Colors.white, ), overflow: TextOverflow.ellipsis,)))]),
            // third row
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
            Text(tran.airMiles,style: TextStyle(color: Colors.white, ) ,
    ),

            Text(tran.pnr + '      ',style: TextStyle(color: Colors.black,  ),  ),
        ],
          )]
      )
      )

      );

    }
  }

      return new Column(children: tranWidgets.toList());
}
/*
  List <DataRow> _getDataCells() {
    List <DataRow> rows = [];

    for(var tran in  transactions) {
      if( tran.airMiles != '0' && tran.airMiles != '0.0') {
        DataRow row = new DataRow(

            cells: <DataCell>[
              DataCell(Text(tran.pnr, style: TextStyle(fontSize: 10.0),)),
              DataCell(
                  Text(tran.flightNumber, style: TextStyle(fontSize: 10.0))),
              DataCell(Text(
                  tran.departureCityCode, style: TextStyle(fontSize: 10.0))),
              DataCell(
                  Text(tran.arrivalCityCode, style: TextStyle(fontSize: 10.0))),
              DataCell(Text(
                  DateFormat('ddMMMyy').format(DateTime.parse(tran.flightDate)),
                  style: TextStyle(fontSize: 10.0))),
              DataCell(Text(tran.airMiles, style: TextStyle(fontSize: 10.0))),
              DataCell(Text(tran.description, style: TextStyle(fontSize: 8.0))),
            ]
        );
        rows.add(row);
      }
  }
    return rows;

  }
*/
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
/*    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("${gblSettings.fqtvName} Login"),
          content: _error != null && _error != ''
              ? new Text(_error)
              : new Text("Please try again"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new TextButton(
              child: new Text("Close"),
              onPressed: () {
                _error = '';

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );

 */
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
    if ( gblSession == null || gblSession.isTimedOut()) {
      await login().then((result) {
        gblSession =
            Session(result.sessionId, result.varsSessionId, result.vrsServerNo);
        print('new session');
      });
    }
    FqtvMemberloginDetail fqtvMsg = FqtvMemberloginDetail(_emailEditingController.text,
        _fqtvTextEditingController.text,
        _passwordEditingController.text);
    String msg = json.encode(FqTvCommand(gblSession, fqtvMsg ).toJson());
    String method = 'GetAirMilesBalance';

   print(msg);
   _sendVRSCommand(msg, method).then((result) {
     if( result == null || result == ''){
       _error = 'Bad server response logging on';
       _isButtonDisabled = false;
       _loadingInProgress = false;
       _actionCompleted();
       _showDialog();
       return;
     }
     Map map = json.decode(result);
     ApiFqtvMemberAirMilesResp resp = new ApiFqtvMemberAirMilesResp.fromJson(
         map);
     _loadingInProgress = false;
     if (resp.statusCode != 'OK') {
       _error = resp.message;
       _isButtonDisabled = false;
       _actionCompleted();
       _showDialog();
     } else {
       _error ='';
       widget.passengerDetail.fqtv = _fqtvTextEditingController.text;
       fqtvNo = _fqtvTextEditingController.text;
       gblFqtvNumber = fqtvNo;
       fqtvEmail = _emailEditingController.text;
       fqtvPass = _passwordEditingController.text;
       gblFqtvBalance = resp.balance;

       method = 'GetDetailsByUsername';
       msg = json.encode(
           ApiFqtvGetDetailsRequest(fqtvEmail, fqtvNo, fqtvPass).toJson());

       _sendVRSCommand(msg, method).then((result) {
         Map map = json.decode(result);

         try {
           ApiFqtvMemberDetailsResponse resp = new ApiFqtvMemberDetailsResponse
               .fromJson(map);
           if (resp.statusCode != 'OK') {
             _error = resp.message;
             _actionCompleted();
             _isButtonDisabled = false;
             _showDialog();
           } else {
             memberDetails = resp;
             widget.passengerDetail.fqtvPassword = fqtvPass;
             widget.passengerDetail.fqtv = fqtvNo;
             if( gblPassengerDetail == null ){
               gblPassengerDetail =widget.passengerDetail;
             }
             gblPassengerDetail.fqtv = fqtvNo;
             gblPassengerDetail.fqtvPassword = fqtvPass;
             gblPassengerDetail.title = memberDetails.member.title;
             gblPassengerDetail.firstName = memberDetails.member.firstname;
             gblPassengerDetail.lastName = memberDetails.member.surname;
             gblPassengerDetail.phonenumber = memberDetails.member.phoneMobile;
             if( gblPassengerDetail.phonenumber == null || gblPassengerDetail.phonenumber.isEmpty  ) {
               gblPassengerDetail.phonenumber = memberDetails.member.phoneHome;
             }

             gblPassengerDetail.email = memberDetails.member.email;
             setState(() {});
           }
         } catch(e) {
           _loadingInProgress = false;
           print(e);
         }
       });
     }});
   }

  Future _sendVRSCommand(msg, method) async {
    final http.Response response = await http.post(
        Uri.parse(gblSettings.apiUrl + "/FqTvMember/$method"),
        headers: {'Content-Type': 'application/json',
          'Videcom_ApiKey': gblSettings.apiKey
        },
        body: msg);

    if (response.statusCode == 200) {
      print('message send successfully: $msg' );
      return response.body.trim();
    } else {
      print('failed: $msg');
      _error = 'message failed';
      try{
        print (response.body);
        _error = response.body;
      } catch(e){}

      _actionCompleted();
      _showDialog();
    }
  }

 void  _showTransactions() async {

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
       transactions = resp.transactions;
       setState(() {
       });
     }
   });
  }
 void _changePasswordDialog() {
   showDialog(
       context: context,
       builder: (BuildContext context) {
   return AlertDialog(
     title: Row(
         children:[
           Image.network('$gblServerFiles/images/lock_user_man.png',
             width: 50, height: 50, fit: BoxFit.contain,),
           TrText('Change Password')
         ]
     ),
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
           labelText: 'Old password',
           fillColor: Colors.white,
           border: new OutlineInputBorder(
             borderRadius: new BorderRadius.circular(15.0),
             borderSide: new BorderSide(),
           ),
         ),
         controller: _oldPasswordEditingController,
         obscureText: _isHidden,
         obscuringCharacter: "*",
         keyboardType: TextInputType.visiblePassword,
       ),
        SizedBox(height: 15,),
       new TextFormField(
         controller: _newPasswordEditingController ,
         decoration: InputDecoration(
           contentPadding:
           new EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
           labelText: 'new Password',
           fillColor: Colors.white,
           border: new OutlineInputBorder(
             borderRadius: new BorderRadius.circular(15.0),
             borderSide: new BorderSide(),
           ),
         ),
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
           title: Row(
               children:[
                 Image.network('$gblServerFiles/reset_password.png',
                   width: 50, height: 50, fit: BoxFit.contain,),
                 TrText('Reset Password')
               ]
           ),
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
                         labelText: 'Email',
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