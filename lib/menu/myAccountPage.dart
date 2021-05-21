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

class MyAccountPage extends StatefulWidget {
  MyAccountPage(
      {Key key, this.passengerDetail, this.isAdsBooking, this.isLeadPassenger})
      : super(key: key);

  _MyAccountPageState createState() => _MyAccountPageState();

  PassengerDetail passengerDetail;
  final bool isAdsBooking;
  final bool isLeadPassenger;


}


class _MyAccountPageState extends State<MyAccountPage> {
  TextEditingController _titleTextEditingController = TextEditingController();

  TextEditingController _firstNameTextEditingController =   TextEditingController();

  TextEditingController _lastNameTextEditingController =  TextEditingController();
  TextEditingController _emailTextEditingController =  TextEditingController();
  TextEditingController _phoneNumberTextEditingController =  TextEditingController();

  TextEditingController _dateOfBirthTextEditingController =  TextEditingController();

  TextEditingController _adsNumberTextEditingController =
  TextEditingController();
  TextEditingController _adsPinTextEditingController = TextEditingController();
  TextEditingController _fqtvTextEditingController = TextEditingController();

  List<UserProfileRecord> userProfileRecordList;
  final formKey = new GlobalKey<FormState>();
  bool _loadingInProgress = false;
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

        if( widget.passengerDetail.paxType == null) {
          widget.passengerDetail.paxType = PaxType.adult;
        }
      }
    });
    // _displayProcessingIndicator = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
            padding: EdgeInsets.only(left: 10.0),
            child: Image.asset(
                'lib/assets/${gblAppTitle}/images/appBarLeft.png',
                color: Color.fromRGBO(255, 255, 255, 0.1),
                colorBlendMode: BlendMode.modulate)),
        brightness: gbl_SystemColors.statusBar,
        backgroundColor:
        gbl_SystemColors.primaryHeaderColor,
        iconTheme: IconThemeData(
            color: gbl_SystemColors.headerTextColor),
        title: TrText('My Account',
            style: TextStyle(
                color:
                gbl_SystemColors.headerTextColor)),
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
        children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(0, 2, 0, 8),
              child: InkWell(
                onTap: () {
                  formSave();
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: new Text('Salutation'),
                        content: new Container(
                          width: double.maxFinite,
                          child: optionListView(),
                        ),
                      );
                    },
                  );
                },
                child: IgnorePointer(
                  child: TextFormField(
                    decoration: new InputDecoration(
                      contentPadding:
                      new EdgeInsets.symmetric(
                          vertical: 15.0, horizontal: 15.0),
                      labelText: 'Title',
                      fillColor: Colors.white,
                      border: new OutlineInputBorder(
                        borderRadius: new BorderRadius.circular(25.0),
                        borderSide: new BorderSide(),
                      ),
                    ),
                    controller: _titleTextEditingController, // TextEditingController(text: widget.passengerDetail.title ),
                    validator: (value) =>
                    value.isEmpty ? 'Title can\'t be empty' : null,
                    onSaved: (value) {
                      if (value != null) {
                        widget.passengerDetail.title = value.trim();
                      }
                    },
                  ),
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.fromLTRB(0, 8.0, 0, 8),
              child: new Theme(
                data: new ThemeData(
                  primaryColor: Colors.blueAccent,
                  primaryColorDark: Colors.blue,
                ),
                child: TextFormField(
                  decoration: InputDecoration(
                    contentPadding:
                    new EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
                    labelText: 'First name (as Passport)',
                    fillColor: Colors.white,
                    border: new OutlineInputBorder(
                      borderRadius: new BorderRadius.circular(25.0),
                      borderSide: new BorderSide(),
                    ),
                  ),
                  controller: _firstNameTextEditingController,
                  onFieldSubmitted: (value) {
                    widget.passengerDetail.firstName = value;
                  },
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.text,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp("[a-zA-Z-]"))
                  ],
                  validator: (value) =>
                  value.isEmpty ? 'First name can\'t be empty' : null,
                  onSaved: (value) {
                    if (value != null) {
                      widget.passengerDetail.firstName = value.trim();
                    }
                  },
                ),
              ),
            ),
          Padding(
            padding: EdgeInsets.fromLTRB(0, 8.0, 0, 8),
            child: new Theme(
              data: new ThemeData(
                primaryColor: Colors.blueAccent,
                primaryColorDark: Colors.blue,
              ),
              child: TextFormField(
                decoration: InputDecoration(
                  contentPadding:
                  new EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
                  labelText: 'Last name (as Passport)',
                  fillColor: Colors.white,
                  border: new OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(25.0),
                    borderSide: new BorderSide(),
                  ),
                ),
                keyboardType: TextInputType.text,
                controller: _lastNameTextEditingController,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp("[a-zA-Z-]"))
                ],
                onFieldSubmitted: (value) {
                  widget.passengerDetail.lastName = value;
                },
                validator: (value) =>
                value.isEmpty ? 'Last name can\'t be empty' : null,
                onSaved: (value) {
                  if (value != null) {
                    widget.passengerDetail.lastName = value.trim();
                  }
                },
              ),
            ),
          ),
           Padding(
            padding: const EdgeInsets.fromLTRB(0, 8.0, 0, 8),
            child: new Theme(
              data: new ThemeData(
                primaryColor: Colors.blueAccent,
                primaryColorDark: Colors.blue,
              ),
              child: new TextFormField(
                decoration: InputDecoration(
                  contentPadding:
                  new EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
                  labelText: 'Phone Number',
                  fillColor: Colors.white,
                  border: new OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(25.0),
                    borderSide: new BorderSide(),
                  ),
                ),
                controller:  _phoneNumberTextEditingController,  //' widget.passengerDetail.phonenumber,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
  // do not force phone no here
  /*              validator: (value) => value.isEmpty
                    ? 'Phone number can\'t be empty'
                    : null,

   */
                onSaved: (value) {
                  if (value != null) {
                    //.contactInfomation.phonenumber = value.trim()
                    widget.passengerDetail.phonenumber = value.trim();
                  }
                },
              )
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 8.0, 0, 8),
            child: new Theme(
              data: new ThemeData(
                primaryColor: Colors.blueAccent,
                primaryColorDark: Colors.blue,
              ),
              child: new TextFormField(
                controller: _emailTextEditingController,
                decoration: InputDecoration(
                  contentPadding:
                  new EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
                  labelText: 'Email',
                  fillColor: Colors.white,
                  border: new OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(25.0),
                    borderSide: new BorderSide(),
                  ),
                ),
                // controller: _emailTextEditingController,
                keyboardType: TextInputType.emailAddress,
//                validator: (value) => validateEmail(value.trim()),
                onSaved:(value) {
                  if( value.isNotEmpty) {
                    widget.passengerDetail.email = value.trim();
                  }
                },

              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(0, 8.0, 0, 8),
            child: (widget.passengerDetail.paxType != PaxType.adult &&
                widget.passengerDetail.paxType != null)
                ? InkWell(
              onTap: () {
                _showCalenderDialog(widget.passengerDetail.paxType);
              },
              child: IgnorePointer(
                child: TextFormField(
                  decoration: new InputDecoration(
                    contentPadding: new EdgeInsets.symmetric(
                        vertical: 15.0, horizontal: 15.0),
                    labelText: 'Date of Birth',
                    fillColor: Colors.white,
                    border: new OutlineInputBorder(
                      borderRadius: new BorderRadius.circular(25.0),
                      borderSide: new BorderSide(),
                    ),
                  ),
                  //initialValue: field.value,
                  controller: _dateOfBirthTextEditingController, //
                /*  validator: (value) =>
                  value.isEmpty ? 'Date of Birth is required' : null,

                 */
/*                  onSaved: (value) {
                    if (value != '') {
                      var date = value.split('-')[2] +
                          ' ' +
                          value.split('-')[1] +
                          ' ' +
                          value.split('-')[0];
                      DateFormat format = new DateFormat("yyyy MMM dd");
                      widget.passengerDetail.dateOfBirth = format.parse(date);
                    }
                  },
*/
                  // DateFormat format = new DateFormat("yyyy MMM dd"); DateTime.parse(value),  //value.trim(),
                ),
              ),
            )
                : Padding(padding: const EdgeInsets.all(0.0)),
          ),
          ElevatedButton(
            onPressed: () {
              validateAndSubmit();
            },
            style: ElevatedButton.styleFrom(
                primary: gbl_SystemColors
                    .primaryButtonColor, //Colors.black,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0))),
            child: Row(
              //mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.check,
                  color: Colors.white,
                ),
                Text(
                  'SAVE',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          )

        ],
    ),
    ),
        ),
      ),
    );
    // });
  }

  ListView optionListView() {
    List<Widget> widgets = [];
    //new List<Widget>();
    gbl_titles.forEach((title) =>
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
                _updateDateOfBirth(dateTime);
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
      if (widget.isAdsBooking && widget.isLeadPassenger) {
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
      _loadingInProgress = true;
    });

//ZADSVERIFY/ADS4000000153501/7978

    http.Response response = await http
        .get(Uri.parse(
        "${gbl_settings.xmlUrl}${gbl_settings.xmlToken}&command=ZADSVERIFY/${_adsNumberTextEditingController.text}/${_adsPinTextEditingController.text}'"))
        .catchError((resp) {});

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
        Navigator.pop(context, widget.passengerDetail);
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
      _loadingInProgress = false;
    });
  }

  void _showDialog() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("ADS Login"),
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