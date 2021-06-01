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

  TextEditingController _titleTextEditingController = TextEditingController();

  TextEditingController _firstNameTextEditingController =   TextEditingController();

  TextEditingController _lastNameTextEditingController =  TextEditingController();
  TextEditingController _emailTextEditingController =  TextEditingController();
  TextEditingController _phoneNumberTextEditingController =  TextEditingController();

  TextEditingController _dateOfBirthTextEditingController =  TextEditingController();

  TextEditingController _adsNumberTextEditingController =   TextEditingController();
  TextEditingController _adsPinTextEditingController = TextEditingController();
  //TextEditingController _fqtvTextEditingController = TextEditingController();
  Session session;
  int balance = 0;
  String fqtvEmail = '';
  String fqtvNo = '';
  String fqtvPass='';
  List<ApiFQTVMemberTransaction> transactions;

  List<UserProfileRecord> userProfileRecordList;
  final formKey = new GlobalKey<FormState>();
//  bool _loadingInProgress = false;
  String _error;

  @override
  initState() {
    super.initState();
    widget.passengerDetail = new PassengerDetail( email:  '', phonenumber: '');

    Repository.get()
        .getNamedUserProfile('PAX1').then((profile) {
      if (profile != null) {
        widget.passengerDetail.firstName = profile.name.toString();
        try {
          Map map = json.decode(
              profile.value.toString().replaceAll("'", '"')); // .replaceAll(',}', '}')
          widget.passengerDetail = PassengerDetail.fromJson(map);
        } catch(e) {
          print(e);
        }
        _titleTextEditingController.text = widget.passengerDetail.title;
        _firstNameTextEditingController.text = widget.passengerDetail.firstName;
        _lastNameTextEditingController.text = widget.passengerDetail.lastName;
        _emailTextEditingController.text = widget.passengerDetail.email;
        _phoneNumberTextEditingController.text = widget.passengerDetail.phonenumber;
        _dateOfBirthTextEditingController.text = widget.passengerDetail.dateOfBirth.toString();

        _adsNumberTextEditingController.text = widget.passengerDetail.adsNumber;
        _adsPinTextEditingController.text = widget.passengerDetail.adsPin;

        if( widget.passengerDetail.paxType == null) {
          widget.passengerDetail.paxType = PaxType.adult;
        }
      }
    });
    // _displayProcessingIndicator = false;
  }

  @override
  Widget build(BuildContext context) {
    if( widget.passengerDetail == null || widget.passengerDetail.fqtv == null ||
        widget.passengerDetail.fqtv.isEmpty) {

      return AlertDialog(
        title: Row(
            children:[
              Image.network('https://customertest.videcom.com/videcomair/vars/public/test/images/lock_user_man.png',
                width: 50, height: 50, fit: BoxFit.contain,),
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
            child: TrText("CONTINUE"),
            onPressed: () {
               _fqtvLogin();

              //});

             //Navigator.of(context).pop();
            },
          ),
        ],
      );


    }

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
            padding: EdgeInsets.only(left: 10.0),
            child: Image.asset(
                'lib/assets/$gblAppTitle/images/appBarLeft.png',
                color: Color.fromRGBO(255, 255, 255, 0.1),
                colorBlendMode: BlendMode.modulate)),
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

                // do not force phone no here
                /*              validator: (value) => value.isEmpty
                    ? 'Phone number can\'t be empty'
                    : null,

   */
                onSaved: (value) {
                  if (value != null) {
                    //.contactInfomation.phonenumber = value.trim()
                  }
                },
              ),
              /*
              SizedBox(height: 15,),
              new TextFormField(
                decoration: InputDecoration(
                  contentPadding:
                  new EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
                  labelText: 'Email',
                  fillColor: Colors.white,
                  border: new OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(15.0),
                    borderSide: new BorderSide(),
                  ),
                ),
                controller: _emailEditingController,
                keyboardType: TextInputType.phone,

                // do not force phone no here
                /*              validator: (value) => value.isEmpty
                    ? 'Phone number can\'t be empty'
                    : null,

   */
                onSaved: (value) {
                  if (value != null) {
                    //.contactInfomation.phonenumber = value.trim()
                  }
                },
              ),
              */
              SizedBox(height: 15,),
              new TextFormField(
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
                ),
                keyboardType: TextInputType.visiblePassword,

                // do not force phone no here
                /*              validator: (value) => value.isEmpty
                    ? 'Phone number can\'t be empty'
                    : null,

   */
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
    );
  }

  List<Widget> _getWidgets() {
    List<Widget> widgets = [];
    String name = '';
    String email = '';
    String fqtv = '';

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
                new Text(balance.toString(),
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
              new Text(DateTime.now().toString(),
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
      child: Row(
        //mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
      /*    Icon(
            Icons.check,
            color: Colors.white,
          ),

       */
          Text(
            'Show Transactions',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    ));

    if( transactions != null ) {

      widgets.add(new SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
              columnSpacing: 20.0,
            columns: <DataColumn>[
              DataColumn(
                label: Text('Pnr'),
              ),
              DataColumn(
                label: Text('Flt No'),
              ),
              DataColumn(
                label: Text('Dep'),
              ),
              DataColumn(label: Text('Dest'),),
              DataColumn(label: Text('Date'),),
            ],
            rows:   _getDataCells()
              ),
        ),
          ));
   }
    return widgets;
  }

  List <DataRow> _getDataCells() {
    List <DataRow> rows = [];

    for(var tran in  transactions) {
      DataRow row = new  DataRow(
          cells: <DataCell>[
          DataCell(Text( tran.pnr)),
          DataCell(Text( tran.flightNumber)),
        DataCell(Text( tran.departureCityCode)),
        DataCell(Text( tran.arrivalCityCode)),
        DataCell(Text( DateFormat('ddMMMyy').format(DateTime.parse(tran.flightDate)))),
          ]
    );
      rows.add(row);
  }
    return rows;

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
    // flutter defined function
    showDialog(
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
  }

  void _fqtvLogin() async {
    await login().then((result) {
      session =
          Session(result.sessionId, result.varsSessionId, result.vrsServerNo);
    });
    FqtvMemberloginDetail fqtvMsg = FqtvMemberloginDetail(_emailEditingController.text,
        _fqtvTextEditingController.text,
        _passwordEditingController.text);
    String msg = json.encode(FqTvCommand(session, fqtvMsg ).toJson());
    String method = 'GetAirMilesBalance';

   //print(msg);
   _sendVRSCommand(msg, method).then((result){
      Map map = json.decode(result);
      ApiFqtvMemberAirMilesResp resp = new ApiFqtvMemberAirMilesResp.fromJson(map);
      if( resp.statusCode != 'OK') {
        _error = resp.message;
        _actionCompleted();
        _showDialog();

      } else {
        widget.passengerDetail.fqtv = _fqtvTextEditingController.text;
        fqtvNo =  _fqtvTextEditingController.text;
        fqtvEmail = _emailEditingController.text;
        fqtvPass = _passwordEditingController.text;
        balance = resp.balance;
        setState(() {
        });
        }
      });
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
}