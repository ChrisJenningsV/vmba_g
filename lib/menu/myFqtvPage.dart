import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:vmba/data/repository.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:vmba/data/globals.dart';

import 'package:vmba/data/models/models.dart';
import 'package:vmba/data/models/user_profile.dart';
import 'package:vmba/components/trText.dart';

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
  TextEditingController _passwordController =   TextEditingController();

  TextEditingController _titleTextEditingController = TextEditingController();

  TextEditingController _firstNameTextEditingController =   TextEditingController();

  TextEditingController _lastNameTextEditingController =  TextEditingController();
  TextEditingController _emailTextEditingController =  TextEditingController();
  TextEditingController _phoneNumberTextEditingController =  TextEditingController();

  TextEditingController _dateOfBirthTextEditingController =  TextEditingController();

  TextEditingController _adsNumberTextEditingController =   TextEditingController();
  TextEditingController _adsPinTextEditingController = TextEditingController();
  //TextEditingController _fqtvTextEditingController = TextEditingController();

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

              widget.passengerDetail.fqtv = _fqtvTextEditingController.text;
              //_sineIn(sine,pas).then( (result) {
                setState(() {

                });
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
              SizedBox(height: 15,),
              new TextFormField(
                controller: _passwordController ,
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
                new Text('0',
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


    return widgets;
  }

  ListView optionListView() {
    List<Widget> widgets = [];
    //new List<Widget>();
    gblTitles.forEach((title) =>
        widgets.add(ListTile(
            title: Text(title),
            onTap: () {
              Navigator.pop(context, title);
              _updateTitle(title);
            })));
    return new ListView(
      children: widgets,
    );
  }
  void _updateTitle(String value) {
    setState(() {
      _titleTextEditingController.text = value;
      FocusScope.of(context).requestFocus(new FocusNode());
    });
  }
  void formSave() {
    final form = formKey.currentState;
    form.save();
  }

  _showCalenderDialog(PaxType paxType) {
    DateTime dateTime;
    DateTime _maximumDate;
    DateTime _minimumDate;
    DateTime _initialDateTime;
    int _minimumYear;
    int _maximumYear;
    formSave();

    switch (paxType) {
      case PaxType.infant:
        {
          _initialDateTime = DateTime.now();
          _minimumDate = DateTime.now().subtract(new Duration(days: (365 * 2)));
        }
        break;
      case PaxType.child:
        {
          _initialDateTime = DateTime.now().subtract(Duration(days: 731));
          _minimumDate = DateTime.now().subtract(new Duration(days: (4015)));
        }
        break;
      case PaxType.youth:
        {
          _initialDateTime =
              DateTime.now().subtract(new Duration(days: (4015)));
          _minimumDate = DateTime.now().subtract(new Duration(days: (5840)));
        }
        break;
      case PaxType.adult:
        {
          _initialDateTime = DateTime.now();
        }
        break;
    }
    _maximumDate = _initialDateTime;
    _minimumYear = _minimumDate.year;
    _maximumYear = _initialDateTime.year;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          contentPadding: EdgeInsets.all(0),
          title: new Text('Date of Birth'),
          content: SizedBox(
            //padding: EdgeInsets.all(1),
              height: MediaQuery.of(context).copyWith().size.height / 3,
              child: CupertinoTheme(
                data: CupertinoThemeData(
                  textTheme: CupertinoTextThemeData(
                    dateTimePickerTextStyle: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
                child: CupertinoDatePicker(
                  initialDateTime: _initialDateTime,
                  onDateTimeChanged: (DateTime newValue) {
                    setState(() {
                      print(newValue);
                      dateTime = newValue;
                    });
                  },
                  use24hFormat: true,
                  maximumDate: _maximumDate,
                  minimumYear: _minimumYear,
                  maximumYear: _maximumYear,
                  minimumDate: _minimumDate,
                  mode: CupertinoDatePickerMode.date,
                ),
              )),
          actions: <Widget>[
            new TextButton(
              child: new Text("Ok"),
              onPressed: () {
                Navigator.pop(context, dateTime);
               // _updateDateOfBirth(dateTime);
              },
            ),
          ],
        );
      },
    );
  }
  void _updateDateOfBirth(DateTime dateOfBirth) {
    setState(() {
      _dateOfBirthTextEditingController.text =
          DateFormat('dd-MMM-yyyy').format(dateOfBirth);
      FocusScope.of(context).requestFocus(new FocusNode());
    });
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
  void validateAndSubmit() async {
    if (validateAndSave()) {
      if (gblBuildFlavor == 'LM' && widget.isLeadPassenger &&
          _adsPinTextEditingController.text.isNotEmpty && _adsPinTextEditingController.text.isNotEmpty) {
        adsValidate();
      } else {
        try {
          List<UserProfileRecord> _userProfileRecordList = [];
          UserProfileRecord _profileRecord = new UserProfileRecord(
              name: 'PAX1',
              value: json.encode(widget.passengerDetail.toJson()).replaceAll('"', "'")
          );

          _userProfileRecordList.add(_profileRecord);
          Repository.get().updateUserProfile(_userProfileRecordList);
          Navigator.pop(context, widget.passengerDetail);
        } catch (e) {
          print('Error: $e');
        }
      }
    }
  }
  bool validateAndSave() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    } else {
      return false;
    }
  }

  Future<void> adsValidate() async {
    setState(() {
//      _loadingInProgress = true;
    });

//ZADSVERIFY/ADS4000000153501/7978

    http.Response response = await http
        .get(Uri.parse(
        "${gblSettings.xmlUrl}${gblSettings.xmlToken}&command=ZADSVERIFY/${_adsNumberTextEditingController.text}/${_adsPinTextEditingController.text}'"))
        .catchError((resp) {
      print( resp);
    });

    if (response == null) {
      //return new ParsedResponse(NO_INTERNET, []);
    }

    //If there was an error return an empty list
    if (response.statusCode < 200 || response.statusCode >= 300) {
      //return new ParsedResponse(response.statusCode, []);
    }

    try {
      String adsJson;
      adsJson = response.body
          .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
          .replaceAll('<string xmlns="http://videcom.com/">', '')
          .replaceAll('</string>', '');

      Map map = json.decode(adsJson);

      if (map['VrsServerResponse']['data']['ads']['users']['user']['isvalid'] ==
          'true') {
        print('Login success');
        List<UserProfileRecord> _userProfileRecordList = [];
        UserProfileRecord _profileRecord = new UserProfileRecord(
            name: 'PAX1',
            value: json.encode(widget.passengerDetail.toJson()).replaceAll('"', "'")
        );

        _userProfileRecordList.add(_profileRecord);
        Repository.get().updateUserProfile(_userProfileRecordList);
        Navigator.pop(context, widget.passengerDetail);
        //     Navigator.pop(context, widget.passengerDetail);
      } else {
        _error = 'Please check your details';
        _actionCompleted();
        _showDialog();
      }
    } catch (e) {
      _actionCompleted();
      _showDialog();
    }
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

}