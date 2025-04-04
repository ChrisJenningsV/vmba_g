import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:vmba/Services/PushNotificationService.dart';
import 'package:vmba/components/vidButtons.dart';
import 'package:vmba/data/repository.dart';
import 'package:vmba/passengerDetails/widgets/CountryCodePicker.dart';
import 'dart:convert';
import 'package:vmba/data/globals.dart';

import 'package:vmba/data/models/models.dart';
import 'package:vmba/data/models/user_profile.dart';
import 'package:vmba/components/trText.dart';
import 'package:vmba/utilities/helper.dart';

import '../Helpers/settingsHelper.dart';
import '../utilities/widgets/appBarWidget.dart';
import '../v3pages/fields/Pax.dart';

//ignore: must_be_immutable
class MyAccountPage extends StatefulWidget {
  MyAccountPage(
      {Key key= const Key("MyAcc_key"), this.passengerDetail, this.isAdsBooking=false, this.isLeadPassenger=true})
      : super(key: key);

  _MyAccountPageState createState() => _MyAccountPageState();

  PassengerDetail? passengerDetail;
   bool isAdsBooking = false;
   bool isLeadPassenger = true;
}

class _MyAccountPageState extends State<MyAccountPage> {
  bool _gotData = false;
  TextEditingController _titleTextEditingController = TextEditingController();
  TextEditingController _firstNameTextEditingController = TextEditingController();
  TextEditingController _middleNameTextEditingController = TextEditingController();
  TextEditingController _lastNameTextEditingController = TextEditingController();
  TextEditingController _emailTextEditingController = TextEditingController();
  TextEditingController _phoneNumberTextEditingController = TextEditingController();
  TextEditingController _phoneCodeTextEditingController = TextEditingController();
//  TextEditingController _dateOfBirthTextEditingController = TextEditingController();
  TextEditingController _dobController = TextEditingController();
  TextEditingController _adsNumberTextEditingController = TextEditingController();
  TextEditingController _adsPinTextEditingController = TextEditingController();
  TextEditingController _fqtvTextEditingController = TextEditingController();
  TextEditingController _fqtvPasswordEditingController = TextEditingController();
  TextEditingController _seniorIDTextEditingController = TextEditingController();
  TextEditingController _disabilityTextEditingController = TextEditingController();
  TextEditingController _redressNoTextEditingController = TextEditingController();
  TextEditingController _knownTravellerNoTextEditingController = TextEditingController();
  TextEditingController _weightTextEditingController = TextEditingController();
  String weightUnit = 'lb';

  int _curGenderIndex =0;
  List <String> genderList = ['', 'Male', 'Female', 'Undisclosed'];

  List<UserProfileRecord>? userProfileRecordList;
  final formKey = new GlobalKey<FormState>();
  String oldADSNumber='';
  String oldADSpin='';
  bool oldNotify=false;
  //String phoneNumber;
  //String phoneIsoCode;


//  bool _loadingInProgress = false;
  String _error='';

  @override
  initState() {
    super.initState();
    _gotData = false;
    widget.passengerDetail = new PassengerDetail(email: '', phonenumber: '');
    if (widget.passengerDetail!.paxType == null) {
      widget.passengerDetail!.paxType = PaxType.adult;
    }

    Repository.get().getNamedUserProfile('PAX1').then((profile) {
      if (profile != null && profile.name != 'Error') {
        widget.passengerDetail!.firstName = profile.name.toString();
        try {
          Map<String, dynamic> map = json.decode(profile.value
              .toString()
              .replaceAll("'", '"')); // .replaceAll(',}', '}')
          widget.passengerDetail = PassengerDetail.fromJson(map);
        } catch (e) {
          print(e);
        }
        _initFields();

       /* _titleTextEditingController.text = translate(widget.passengerDetail.title);
        //_titleTextEditingController.text = widget.passengerDetail.title;
        _firstNameTextEditingController.text = widget.passengerDetail.firstName;
        _middleNameTextEditingController.text = widget.passengerDetail.middleName;
        _lastNameTextEditingController.text = widget.passengerDetail.lastName;
        _emailTextEditingController.text = widget.passengerDetail.email;
        _phoneNumberTextEditingController.text = widget.passengerDetail.phonenumber;
        oldNotify =  widget.passengerDetail.wantNotifications;

        //_dateOfBirthTextEditingController.text = widget.passengerDetail.dateOfBirth.toString();
        if( widget.passengerDetail.dateOfBirth != null ) {
          _dobController.text = DateFormat('dd-MMM-yyyy')
              .format( widget.passengerDetail.dateOfBirth);
        }
        _fqtvTextEditingController.text = widget.passengerDetail.fqtv;
        _fqtvPasswordEditingController.text = widget.passengerDetail.fqtvPassword;

        _adsNumberTextEditingController.text = widget.passengerDetail.adsNumber;
        _adsPinTextEditingController.text = widget.passengerDetail.adsPin;
        oldADSNumber = widget.passengerDetail.adsNumber;
        oldADSpin = widget.passengerDetail.adsPin;

        _seniorIDTextEditingController.text = widget.passengerDetail.seniorID;
        _knownTravellerNoTextEditingController.text = widget.passengerDetail.knowTravellerNo;
        _redressNoTextEditingController.text = widget.passengerDetail.redressNo;
*/
        if( widget.passengerDetail!.gender != null && widget.passengerDetail!.gender.isNotEmpty ){
          _curGenderIndex = genderList.indexOf(widget.passengerDetail!.gender) ;
          logit('genderPicker index:$_curGenderIndex');
          setState(() {

          });
        }

      }
      if (widget.passengerDetail!.paxType == null) {
        widget.passengerDetail!.paxType = PaxType.adult;
      }
      _populateFromGlobalProfile();
      setState(() {
        _gotData = true;
      });
    });
    // _displayProcessingIndicator = false;
  }

  void _initFields() {
    _titleTextEditingController.text = translate(widget.passengerDetail!.title);
    //_titleTextEditingController.text = widget.passengerDetail.title;
    _firstNameTextEditingController.text = widget.passengerDetail!.firstName;
    _middleNameTextEditingController.text = widget.passengerDetail!.middleName;
    _lastNameTextEditingController.text = widget.passengerDetail!.lastName;
    _emailTextEditingController.text = widget.passengerDetail!.email;
    _phoneNumberTextEditingController.text = widget.passengerDetail!.phonenumber;
    oldNotify =  widget.passengerDetail!.wantNotifications;
    _weightTextEditingController.text = 'lb';

    //_dateOfBirthTextEditingController.text = widget.passengerDetail.dateOfBirth.toString();
    if( widget.passengerDetail!.dateOfBirth != null ) {
      _dobController.text = DateFormat('dd-MMM-yyyy')
          .format( widget.passengerDetail!.dateOfBirth as DateTime) ;
    }
    _fqtvTextEditingController.text = widget.passengerDetail!.fqtv;
    _fqtvPasswordEditingController.text = widget.passengerDetail!.fqtvPassword;

    _adsNumberTextEditingController.text = widget.passengerDetail!.adsNumber;
    _adsPinTextEditingController.text = widget.passengerDetail!.adsPin;
    oldADSNumber = widget.passengerDetail!.adsNumber;
    oldADSpin = widget.passengerDetail!.adsPin;

    _seniorIDTextEditingController.text = widget.passengerDetail!.seniorID;
    _knownTravellerNoTextEditingController.text = widget.passengerDetail!.knowTravellerNo;
    _redressNoTextEditingController.text = widget.passengerDetail!.redressNo;
    _weightTextEditingController.text = widget.passengerDetail!.weight.replaceAll('lb', '').replaceAll('kg', '');

  }

  void _clearFields() {
    _titleTextEditingController.clear();
    //_titleTextEditingController.text = widget.passengerDetail.title;
    _firstNameTextEditingController.clear();
    _middleNameTextEditingController.clear();
    _lastNameTextEditingController.clear();
    _emailTextEditingController.clear();
    _phoneNumberTextEditingController.clear();
    _disabilityTextEditingController.clear();
/*
    if( widget.passengerDetail.dateOfBirth != null ) {
      _dobController.text = DateFormat('dd-MMM-yyyy')
          .format( widget.passengerDetail.dateOfBirth);
    }
*/
    _fqtvTextEditingController.clear();
    _fqtvPasswordEditingController.clear();

    _adsNumberTextEditingController.clear();
    _adsPinTextEditingController.clear();
    _seniorIDTextEditingController.clear();
    _knownTravellerNoTextEditingController.clear();
    _redressNoTextEditingController.clear();
    _weightTextEditingController.clear();

  }

  void _populateFromGlobalProfile() {
    if (gblPassengerDetail == null) {
      return;
    }

    if (_titleTextEditingController.text == null ||
        _titleTextEditingController.text.isEmpty) {
      _titleTextEditingController.text = gblPassengerDetail!.title;
    }
    if (_firstNameTextEditingController.text == null ||
        _firstNameTextEditingController.text.isEmpty) {
      _firstNameTextEditingController.text = gblPassengerDetail!.firstName;
    }
    if (_middleNameTextEditingController.text == null ||
        _middleNameTextEditingController.text.isEmpty) {
      _middleNameTextEditingController.text = gblPassengerDetail!.middleName;
    }

    if (_lastNameTextEditingController.text == null ||
        _lastNameTextEditingController.text.isEmpty) {
      _lastNameTextEditingController.text = gblPassengerDetail!.lastName;
    }

    if ((_dobController.text == null ||  _dobController.text.isEmpty) &&
        gblPassengerDetail!.dateOfBirth != null ) {
      _dobController.text =DateFormat('dd-MMM-yyyy')
          .format( gblPassengerDetail!.dateOfBirth as DateTime);
    }

    if (_phoneNumberTextEditingController.text == null ||
        _phoneNumberTextEditingController.text.isEmpty) {
      _phoneNumberTextEditingController.text = gblPassengerDetail!.phonenumber;
    }
    if (_emailTextEditingController.text == null ||
        _emailTextEditingController.text.isEmpty) {
      _emailTextEditingController.text = gblPassengerDetail!.email;
    }

    if (_fqtvTextEditingController.text == null ||
        _fqtvTextEditingController.text.isEmpty) {
      _fqtvTextEditingController.text = gblPassengerDetail!.fqtv;
    }
    if (_fqtvPasswordEditingController.text == null ||
        _fqtvPasswordEditingController.text.isEmpty) {
      _fqtvPasswordEditingController.text = gblPassengerDetail!.fqtvPassword;
    }

    if (_seniorIDTextEditingController.text == null ||
        _seniorIDTextEditingController.text.isEmpty) {
      _seniorIDTextEditingController.text = gblPassengerDetail!.seniorID;
    }
    if (_disabilityTextEditingController.text == null ||
        _disabilityTextEditingController.text.isEmpty) {
      _disabilityTextEditingController.text = gblPassengerDetail!.disabilityID;
    }

    if (_redressNoTextEditingController.text == null ||
        _redressNoTextEditingController.text.isEmpty) {
      _redressNoTextEditingController.text = gblPassengerDetail!.redressNo;
    }
    if (_knownTravellerNoTextEditingController.text == null ||
        _knownTravellerNoTextEditingController.text.isEmpty) {
      _knownTravellerNoTextEditingController.text = gblPassengerDetail!.knowTravellerNo;
    }

    if (_weightTextEditingController .text == null ||
        _weightTextEditingController.text.isEmpty) {
      _weightTextEditingController.text = gblPassengerDetail!.weight;
    }


  }

  @override
  Widget build(BuildContext context) {
    if( _gotData == false) {
      return Scaffold(
          appBar: AppBar(
          leading: getAppBarLeft('MYACCOUNT'),
    backgroundColor: gblSystemColors.primaryHeaderColor,
    iconTheme: IconThemeData(color: gblSystemColors.headerTextColor),
    title: TrText('My Account',
    style: TextStyle(color: gblSystemColors.headerTextColor)),
    automaticallyImplyLeading: false,),
        body: new Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              new CircularProgressIndicator(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: new TrText('Loading'),
              ),
            ],
          ),
        ),
      );
    } else {
      return Scaffold(
        backgroundColor: v2PageBackgroundColor(),
        appBar: AppBar(
          leading: getAppBarLeft('MYACCOUNT'),
          backgroundColor: gblSystemColors.primaryHeaderColor,
          iconTheme: IconThemeData(color: gblSystemColors.headerTextColor),
          title: TrText('My Account',
              style: TextStyle(color: gblSystemColors.headerTextColor)),
          automaticallyImplyLeading: false,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            )
          ],
        ),
        body:
        Container(
          margin: v2FormPadding(),
          decoration: v2FormDecoration(),
        child: new Form(
          key: formKey,
          child: new SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Padding(
              padding: const EdgeInsets.only(top: 5.0),
              child: Column(
                children: _getWidgets(),
              ),
            ),
          ),
        ),
        )
      );
    }
  }

  List<Widget> _getWidgets() {
    EdgeInsetsGeometry _padding = EdgeInsets.fromLTRB(0, 4, 0, 10);
    List<Widget> widgets = [];
    ThemeData _theme =    new ThemeData(
      primaryColor: Colors.blueAccent,
      primaryColorDark: Colors.blue,
    );

    //logit('title a = ${widget.passengerDetail!.title}');
    // title
    widgets.add(Padding(
      padding: _padding,
      child:
        paxGetTitle(context, _titleTextEditingController,_updateTitle)

    ));

    // first name
    widgets.add(Padding( padding: _padding,
        child: paxGetFirstName(
    _firstNameTextEditingController,
    onFieldSubmitted: (value){
      widget.passengerDetail!.firstName  = value;      },
    onSaved: (value){
      widget.passengerDetail!.firstName  = value;
    },)
    ));


    // middle name
    if( gblSettings.wantMiddleName ) {

      widgets.add( paxGetMiddleName(_middleNameTextEditingController,
      onFieldSubmitted: (value){
        widget.passengerDetail!.middleName = value;      },
        onSaved: (value){
        widget.passengerDetail!.middleName = value;}
      ));
    }


    // last name
    widgets.add(paxGetLastName(_lastNameTextEditingController,
        onFieldSubmitted: (value){
          widget.passengerDetail!.lastName = value;      },
        onSaved: (value){
          widget.passengerDetail!.lastName = value;}
    ));

    // phone
    if( gblSettings.wantInternatDialCode) {
        widgets.add(InternationalPhoneInput(
          padding:_padding,
          popupTitle: translate('Select phone country'),
          controller: _phoneNumberTextEditingController,
          codeController: _phoneCodeTextEditingController,
          //initialPhoneNumber: _phoneNumberTextEditingController.text,
          decoration: InputDecoration.collapsed(hintText: '(123) 123-1234'),
          onSaved: ( String newNumber) {
            setState(() {
              _phoneCodeTextEditingController.text = newNumber;
              widget.passengerDetail!.phonenumber = newNumber + _phoneNumberTextEditingController.text;
 /*             _phoneNumberTextEditingController.text = newNumber;
              widget.passengerDetail.phonenumber = newNumber;*/
            });
          },
          onPhoneNumberChange: (String number, String intNumber,
              String isoCode) {
            print(number);
            setState(() {
              //phoneNumber = number;
              //phoneIsoCode = isoCode;
            });
          },
          initialPhoneNumber: _phoneNumberTextEditingController.text,
        ));
     } else {
        widgets.add(
          Padding( padding: _padding,
            child: paxGetPhoneNumber(_phoneNumberTextEditingController,
            onFieldSubmitted: (value){
              widget.passengerDetail!.phonenumber = value;      },
            onSaved: (value){
              widget.passengerDetail!.phonenumber = value;}
            )
        ));

    }

    // email
    widgets.add(paxGetEmail(_emailTextEditingController,
      onFieldSubmitted: (value) {
        widget.passengerDetail!.email = value;
      },
      onSaved: (value) {
        if (value != null) {
          widget.passengerDetail!.email = value.trim();
        }
      },
    ));

     // DOB
    if( (widget.passengerDetail!.paxType == PaxType.adult && gblSettings.passengerTypes.wantAdultDOB ) ||
      widget.passengerDetail!.paxType != PaxType.adult &&
        widget.passengerDetail!.paxType != null ) {
      widgets.add(Padding(
        padding: _padding,
        child:  InkWell(
          onTap: () {
            _showCalenderDialog(widget.passengerDetail!.paxType);
          },
          child: IgnorePointer(
            child: TextFormField(
              decoration: _getDecoration('Date of Birth'),
              //initialValue: field.value,
              controller: _dobController, //
              validator: (value) =>
              value!.isEmpty ? translate('Date of Birth is required') : null,
              onSaved: (value) {
                if (value != null && value.isNotEmpty) {

                  DateFormat format = new DateFormat("dd-MMM-yyyy"); //""yyyy MMM dd");
                  widget.passengerDetail!.dateOfBirth = format.parse(value);
                }
              },

              // DateFormat format = new DateFormat("yyyy MMM dd"); DateTime.parse(value),  //value.trim(),
            ),
          ),
        )
            ,
      ));
    }

    // gender
    if( gblSettings.wantGender) {
      widgets.add(Padding(
        padding: _padding,
        child: new Theme(
          data: _theme,
          child: genderPicker(_padding, _theme),
        ),
      ));
    }

    if( gblSettings.wantWeight) {
      widgets.add(Padding(
          padding: _padding,
          child: paxGetWeight(context, _weightTextEditingController, weightUnit, (newUnit) {
            setState(() {
              weightUnit = newUnit;
            });
          }, (newVal){
            widget.passengerDetail!.weight = newVal;
          })
      ));
    }

    // Country
    if( gblSettings.wantCountry) {
      widgets.add(Padding(
        padding: _padding,
        child: new Theme(
          data: _theme,
          child: countryPicker(EdgeInsets.all(0), _theme, widget.passengerDetail!.country, _onCountryChanged) as Widget,
        ),
      ));
    }

    // notifications
    if( gblSettings.wantNotificationEdit) {
      widgets.add( CheckboxListTile(
          title: TrText("I want promotional messages"),
          value:  widget.passengerDetail!.wantNotifications,
          onChanged: (newValue) {
            setState(() {
              widget.passengerDetail!.wantNotifications = newValue as bool;
            });
          },
          controlAffinity: ListTileControlAffinity.leading,
      ));//  <-- leading Checkbox
    }

    // fqtv
    if (gblSettings.wantFQTV == true || gblSettings.wantFQTVNumber == true) {
      widgets.add(Padding(
        padding: _padding,
        child: new Theme(
            data: _theme,
            child: new TextFormField(
              maxLength: 50,
              decoration: _getDecoration(
                  '${gblSettings.fqtvName} ' + translate('number')),
              controller: _fqtvTextEditingController,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              onSaved: (value) {
                if (value != null) {
                  //.contactInfomation.phonenumber = value.trim()
                  widget.passengerDetail!.fqtv = value.trim();
                }
              },
            )),
      ));
    }

    if (gblSettings.wantFQTV == true) {
      widgets.add(Padding(
        padding: _padding,
        child: new Theme(
            data: _theme,
            child: new TextFormField(
              maxLength: 50,
              obscureText: true,
              obscuringCharacter: "*",
              decoration: _getDecoration(
                  '${gblSettings.fqtvName} ' + translate('Password')),
              controller: _fqtvPasswordEditingController,
              keyboardType: TextInputType.visiblePassword,
              onSaved: (value) {
                if (value != null) {
                  widget.passengerDetail!.fqtvPassword = value.trim();
                }
              },
            )),
      ));
    }

    // ADS for LM
    if (gblSettings.aircode == 'LM') {
      widgets.add(Padding(
        padding: _padding,
        child: new Theme(
          data: _theme,
          child: new TextFormField(
            maxLength: 20,
            controller: _adsNumberTextEditingController,
            decoration: _getDecoration('ADS / Island Resident Number'),
            validator: (value) {
              if (! value!.isEmpty && _adsPinTextEditingController.text == '' ) {
                return 'ADS / Island Resident Pin is Required';
              } else if (value!= '' && (!(value.toUpperCase().startsWith('ADS') || value.toUpperCase().startsWith('RES') ) ||
                  value.length != 16 ||
                  !isNumeric(value.substring(3)))) {
                return 'ADS / Island Resident not valid';
              } else {
                return null;
              }
            },
            // controller: _emailTextEditingController,
            keyboardType: TextInputType.streetAddress,
//                validator: (value) => validateEmail(value.trim()),
            onSaved: (value) {
              if (value!.isNotEmpty) {
                widget.passengerDetail!.adsNumber = value.trim();
              }
            },
          ),
        ),
      ));
      widgets.add(Padding(
        padding: _padding,
        child: new Theme(
          data: _theme,
          child: new TextFormField(
            maxLength: 4,
            controller: _adsPinTextEditingController,
            decoration: _getDecoration('ADS / Island Resident Pin'),
            // controller: _emailTextEditingController,
            keyboardType: TextInputType.number,
//                validator: (value) => validateEmail(value.trim()),
            onSaved: (value) {
              widget.passengerDetail!.adsPin = value!.trim();
            },
          ),
        ),
      ));
    } // end LM
    if (gblSettings.aircode == 'T6') {
      widgets.add(Padding(
        padding: _padding,
        child: new Theme(
          data: _theme,
          child: new TextFormField(
            maxLength: 20,
            controller: _seniorIDTextEditingController,
            decoration: _getDecoration('Senior Citizen ID'),
            keyboardType: TextInputType.streetAddress,
//                validator: (value) => validateEmail(value.trim()),
            onSaved: (value) {
              if (value!.isNotEmpty) {
                widget.passengerDetail!.seniorID = value.trim();
              }
            },
          ),
        ),
      ));
      widgets.add(Padding(
        padding: _padding,
        child: new Theme(
          data: _theme,
          child: new TextFormField(
            maxLength: 20,
            controller: _disabilityTextEditingController,
            decoration: _getDecoration('Disability ID'),
            keyboardType: TextInputType.streetAddress,
//                validator: (value) => validateEmail(value.trim()),
            onSaved: (value) {
              if (value!.isNotEmpty) {
                widget.passengerDetail!.disabilityID = value.trim();
              }
            },
          ),
        ),
      ));
    }

    if (gblSettings.wantRedressNo) {
      widgets.add(Padding(
        padding: _padding,
        child: new Theme(
          data: _theme,
          child: new TextFormField(
            maxLength: 20,
            controller: _redressNoTextEditingController,
            decoration: _getDecoration('Redress No'),
            keyboardType: TextInputType.streetAddress,
            onSaved: (value) {
              if (value!.isNotEmpty) {
                widget.passengerDetail!.redressNo = value.trim();
              }
            },
          ),
        ),
      ));
    }

    if (gblSettings.wantKnownTravNo) {
      widgets.add(Padding(
        padding: _padding,
        child: new Theme(
          data: _theme,
          child: new TextFormField(
            maxLength: 20,
            controller: _knownTravellerNoTextEditingController,
            decoration: _getDecoration('Known Traveller No'),
            keyboardType: TextInputType.streetAddress,
            onSaved: (value) {
              if (value!.isNotEmpty) {
                widget.passengerDetail!.knowTravellerNo = value.trim();
              }
            },
          ),
        ),
      ));
    }


    if( widget.passengerDetail!.firstName != null && widget.passengerDetail!.firstName.isNotEmpty )
    {
    widgets.add(
    Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    mainAxisSize: MainAxisSize.max,
    children: [
    vid3DActionButton(context, 'Delete', _deleteAccount, icon: Icons.close) ,
        vid3DActionButton(context, 'SAVE', validateAndSubmit),
 /*   ElevatedButton(
    onPressed: () {
    validateAndSubmit();
    },
    style: ElevatedButton.styleFrom(
    primary: gblSystemColors.primaryButtonColor, //Colors.black,
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
    TrText(
    'SAVE',
    style: TextStyle(color: Colors.white),
    ),
    ],
    ),
    )*/
    ])
    );
    } else {
      widgets.add( vid3DActionButton(context, 'SAVE', validateAndSubmit),);
    }
    return widgets;
  }

  void _onCountryChanged(String value){
    setState(() {
      logit('Value = ' + value.toString());
      widget.passengerDetail!.country = value;
    });

  }


  void _deleteAccount(dynamic context) {
    showDialog(
      context: context,
        builder: (BuildContext context)
    {
      return AlertDialog(
        title: new TrText('Delete Account'),
        content: new TrText('All Account data will be removed'),
        actions: <Widget>[
          new ElevatedButton(
            onPressed: () => Navigator.pop(context), // Closes the dialog
            child: new TrText('No'),
          ),
          new ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Closes the dialog
              _doDeleteAccount(context);
            },
            child: new TrText('Yes'),
          ),
        ],
      );
    });
  }
    void _doDeleteAccount(dynamic context){
    widget.passengerDetail = new PassengerDetail();
    gblPassengerDetail = widget.passengerDetail;

    List<UserProfileRecord> _userProfileRecordList = [];
    UserProfileRecord _profileRecord = new UserProfileRecord(
        name: 'PAX1',
        value: json
            .encode(widget.passengerDetail!.toJson())
            .replaceAll('"', "'"));

    _userProfileRecordList.add(_profileRecord);
    Repository.get().updateUserProfile(_userProfileRecordList);

    _clearFields();

    setState(() {

    });
  }

 /* ListView optionListView() {
    List<Widget> widgets = [];
    //new List<Widget>();
    gblTitles.forEach((title) => widgets.add(ListTile(
        title: TrText(title),
        onTap: () {
          Navigator.pop(context, title);
          _updateTitle(title);
        })));
    return new ListView(
      children: widgets,
    );
  }
*/

  Widget genderPicker (EdgeInsetsGeometry padding, ThemeData theme) {
    var index = 0;
    logit('genderPicker :${widget.passengerDetail!.gender}');
/*    if( widget.passengerDetail.gender != null && widget.passengerDetail.gender.isNotEmpty ){
      _curGenderIndex = genderList.indexOf(widget.passengerDetail.gender);
      logit('genderPicker index:${_curGenderIndex}');
    }
*/
    return  Padding(
        padding: padding,
        child: new Theme(
            data: theme,
            child: DropdownButtonFormField<int>(
              decoration: getDecoration('Gender'),
              value: _curGenderIndex,
              items: genderList.map((gender )
              => DropdownMenuItem(
                child: Row(children: <Widget>[
                  SizedBox(width: 10,),
                  new TrText(gender)]),
                value: index++,
              )
              ).toList(),
              validator: (value) =>
              (value == null ) ? translate('Gender is required') : null,

              // hint: Text('Country'),
              onChanged: (value) {
                setState(() {
                 // logit('Value = ' + value.toString());
                  widget.passengerDetail!.gender = genderList[ value!];

                });
              },
            ) )
    );

  }


  void _updateTitle(String value) {
    setState(() {
      widget.passengerDetail!.title = value;
      _titleTextEditingController.text = translate(value);
      FocusScope.of(context).requestFocus(new FocusNode());
    });
  }

  void formSave() {
    final form = formKey.currentState;
    form!.save();
  }

  _showCalenderDialog(PaxType paxType) {
    DateTime dateTime = DateTime.now();
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
          _minimumDate = DateTime.now().subtract(new Duration(days: 365 * 110));
        }
        break;
      default:
        {
          _initialDateTime = DateTime.now();
          _minimumDate = DateTime( 110, 0, 0 );

        }
        break;
    }
    _maximumDate = _initialDateTime;
    _minimumYear = _minimumDate.year;
    _maximumYear = _initialDateTime.year;

    if ( widget.passengerDetail != null &&  widget.passengerDetail?.dateOfBirth != null  ){
      _initialDateTime = widget.passengerDetail?.dateOfBirth as DateTime;
    }

    final Brightness brightnessValue = MediaQuery.of(context).platformBrightness;
    bool isDark = brightnessValue == Brightness.dark;
    Color bgColour = Colors.white;
    Color txtColor = Colors.black;
    if (isDark) {
      bgColour = Colors.black;
      txtColor = Colors.white;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          contentPadding: EdgeInsets.all(0),
          backgroundColor: bgColour,
          title: new TrText('Date of Birth', style: TextStyle(color: txtColor),),
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
                  backgroundColor: bgColour,

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
              style: TextButton.styleFrom(
                  backgroundColor:bgColour ,
                  side: BorderSide(color:  txtColor, width: 1),
                  foregroundColor:txtColor),
              child: new TrText("Ok"),
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
      _dobController.text =
          DateFormat('dd-MMM-yyyy').format(dateOfBirth);
      widget.passengerDetail?.dateOfBirth = dateOfBirth;
      FocusScope.of(context).requestFocus(new FocusNode());
    });
  }

  String validateEmail(String value) {
    /*String pattern =
        r'^(([^<>()[\]#$!%&^*+-=?\\.,;:\s@\"]+(\.[^<>()[\]#$!%&^*+-=?\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';*/
    RegExp regex = new RegExp(gblEmailValidationPattern);
    if (!regex.hasMatch(value))
      return translate('Enter Valid Email');
    else
      return '';
  }

  void validateAndSubmit(dynamic context) async {
    if (validateAndSave()) {
      if (gblBuildFlavor == 'LM' &&
          widget.isLeadPassenger &&
          _adsNumberTextEditingController.text.isNotEmpty &&
          _adsPinTextEditingController.text.isNotEmpty &&
          (oldADSNumber != _adsNumberTextEditingController.text ||
           oldADSpin != _adsPinTextEditingController.text)) {

          adsValidate();
      } else {
        try {
          List<UserProfileRecord> _userProfileRecordList = [];
          UserProfileRecord _profileRecord = new UserProfileRecord(
              name: 'PAX1',
              value: json
                  .encode(widget.passengerDetail!.toJson())
                  .replaceAll('"', "'"));

          _userProfileRecordList.add(_profileRecord);
          Repository.get().updateUserProfile(_userProfileRecordList);
          Navigator.pop(context, widget.passengerDetail);
          gblPassengerDetail = widget.passengerDetail;
          if( gblSettings.wantPushNoticications && oldNotify != widget.passengerDetail!.wantNotifications) {
            if( widget.passengerDetail!.wantNotifications) {
              subscribeForNotifications();
            } else {
              unsubscribeForNotifications();
            }
          }
        } catch (e) {
          print('Error: $e');
        }
      }
    }
  }

  bool validateAndSave() {
    final form = formKey.currentState;
    if (form!.validate()) {
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

  /*  http.Response response = await http
        .get(Uri.parse(
            "${gblSettings.xmlUrl}${gblSettings.xmlToken}&command=ZADSVERIFY/${_adsNumberTextEditingController.text}/${_adsPinTextEditingController.text}'"))
        .catchError((resp) {
      print(resp);
    });

    if (response == null) {
      //return new ParsedResponse(NO_INTERNET, []);
    }

    //If there was an error return an empty list
    if (response.statusCode < 200 || response.statusCode >= 300) {
      //return new ParsedResponse(response.statusCode, []);
    }*/

    logit('adsValidate A');
    String data = await runVrsCommand('ZADSVERIFY/${_adsNumberTextEditingController.text}/${_adsPinTextEditingController.text}');
    try {
      String adsJson;
      adsJson = data
          .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
          .replaceAll('<string xmlns="http://videcom.com/">', '')
          .replaceAll('</string>', '');

      Map map = json.decode(adsJson);

      if (map['VrsServerResponse']['data']['ads']['users']['user']['isvalid'] ==
          'true') {
        print('ADS Login success');

        List<UserProfileRecord> _userProfileRecordList = [];
        UserProfileRecord _profileRecord = new UserProfileRecord(
            name: 'PAX1',
            value: json
                .encode(widget.passengerDetail!.toJson())
                .replaceAll('"', "'"));

        _userProfileRecordList.add(_profileRecord);
        Repository.get().updateUserProfile(_userProfileRecordList);
        gblPassengerDetail = widget.passengerDetail;
        Navigator.pop(context, widget.passengerDetail);
        //     Navigator.pop(context, widget.passengerDetail);
      } else {
        _error = translate('Please check your details');
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
          title: new Text("ADS Login"),
          content: _error != null && _error != ''
              ? new Text(_error)
              : new TrText("Please try again"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new TextButton(
              child: new TrText("Close"),
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
  InputDecoration _getDecoration(String label) {
   // var borderRadius = 10.0;

   // if ( gblSettings.wantMaterialControls == true ) {
      return InputDecoration(
        fillColor: Colors.grey.shade100,
        filled: true,
        //counter: Container(),
        counterText: '',
        labelStyle: TextStyle(color: Colors.grey),
        //    contentPadding:
        //      new EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
        labelText: translate(label),

//        fillColor: Colors.white,
      );

   // }


  }
}
