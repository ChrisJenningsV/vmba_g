import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:vmba/data/models/models.dart';
import 'package:vmba/data/models/user_profile.dart';
import 'package:vmba/data/globals.dart';
import 'package:vmba/components/trText.dart';
import 'package:vmba/data/repository.dart';
import 'package:vmba/utilities/helper.dart';
import 'package:vmba/utilities/widgets/appBarWidget.dart';
import 'package:vmba/passengerDetails/widgets/CountryCodePicker.dart';
import 'package:vmba/utilities/widgets/colourHelper.dart';

import '../../Helpers/settingsHelper.dart';
import '../../components/pageStyleV2.dart';

class EditPaxWidget extends StatefulWidget {
  EditPaxWidget(
      {Key key= const Key("editpaxxp_key"), required this.passengerDetail, required this.isAdsBooking, required this.isLeadPassenger, required this.destination, required this.newBooking})
      : super(key: key);
  final PassengerDetail passengerDetail;
  final bool isAdsBooking;
  final bool isLeadPassenger;
  final NewBooking newBooking;
  final String destination;

  _EditPaxWidgetState createState() =>
      _EditPaxWidgetState();
}

class _EditPaxWidgetState extends State<EditPaxWidget> {

  var borderRadius = 10.0;
 // bool _loadingInProgress = false;
  final formKey = new GlobalKey<FormState>();
  String _error='';
  Image? bgImage;
  //var _title = new TextEditingController();
  TextEditingController _titleTextEditingController = TextEditingController();

  TextEditingController _firstNameTextEditingController =  TextEditingController();
  TextEditingController _middleNameTextEditingController =  TextEditingController();
  TextEditingController _lastNameTextEditingController =  TextEditingController();
  TextEditingController _dateOfBirthTextEditingController =  TextEditingController();
  TextEditingController _adsNumberTextEditingController =  TextEditingController();
  TextEditingController _adsPinTextEditingController = TextEditingController();
  TextEditingController _fqtvTextEditingController = TextEditingController();
  TextEditingController _emailTextEditingController = TextEditingController();
  TextEditingController _phoneTextEditingController = TextEditingController();
//  TextEditingController _phoneCodeEditingController = TextEditingController();
  TextEditingController _disabilityIDTextEditingController = TextEditingController();
  TextEditingController _seniorIDTextEditingController = TextEditingController();
  TextEditingController _redressNoTextEditingController = TextEditingController();
  TextEditingController _knownTravellerNoTextEditingController = TextEditingController();

  String phoneNumber ='';
  String phoneIsoCode ='';


  //List<UserProfileRecord> userProfileRecordList;
  int _curGenderIndex =0;
  List <String> genderList = ['Male', 'Female', 'Undisclosed'];
  //Countrylist _countryList;

  @override
  initState() {
    super.initState();
    gblActionBtnDisabled = false;
    if( gblSettings.wantPageImages) {
   //   _loadBgCityImage();
    }
    gblPhoneCodeEditingController = TextEditingController();

    if( widget.passengerDetail.country == null ) {
      widget.passengerDetail.country = '';
    }
    String ttl =  translate(widget.passengerDetail.title);
    _titleTextEditingController.text = ttl;
    _firstNameTextEditingController.text = widget.passengerDetail.firstName;
    _middleNameTextEditingController.text = widget.passengerDetail.middleName;
    _lastNameTextEditingController.text = widget.passengerDetail.lastName;
    _dateOfBirthTextEditingController.text =
    widget.passengerDetail.dateOfBirth != null
        ? DateFormat('dd-MMM-yyyy')
        .format(widget.passengerDetail.dateOfBirth as DateTime)
        : '';
    if( widget.passengerDetail.gender != null && widget.passengerDetail.gender.isNotEmpty ){
      _curGenderIndex = genderList.indexOf(widget.passengerDetail.gender) ;
      logit('genderPicker index:$_curGenderIndex');
    }

    _adsNumberTextEditingController.text = widget.passengerDetail.adsNumber;

    _phoneTextEditingController.text = widget.passengerDetail.phonenumber;
    _emailTextEditingController.text = widget.passengerDetail.email;
    phoneNumber = widget.passengerDetail.phonenumber;
    if( phoneNumber == null || phoneNumber.isEmpty) {
      phoneIsoCode = gblSettings.defaultCountryCode;
    } else {

    }

    _adsPinTextEditingController.text = widget.passengerDetail.adsPin;
    _fqtvTextEditingController.text = widget.passengerDetail.fqtv;
    _seniorIDTextEditingController.text = widget.passengerDetail.seniorID;
    _disabilityIDTextEditingController.text = widget.passengerDetail.disabilityID;
    _redressNoTextEditingController.text = widget.passengerDetail.redressNo;
    _knownTravellerNoTextEditingController.text = widget.passengerDetail.knowTravellerNo;

//    _countryList = getCountrylist() as Countrylist;
    gblRememberMe = false;
  }

  @override
  Widget build(BuildContext context) {
    return

      new Scaffold(
      appBar: appBar(context, 'Passenger Detail',
        newBooking: widget.newBooking,
        curStep: 4,
        imageName: gblSettings.wantPageImages ? 'editPax' : '',
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

  String capitalize(String str) {
    return "${str[0].toUpperCase()}${str.substring(1)}";
  }


  /*

  passport info styles
  1
"Passport number", "Country of issue"
  2
"Passport number", "Country of issue", "Expiry date"
  3
 "Passport number", "Country of issue", "Expiry date", "Nationality"

   */


  Widget _body() {

    var paxTypeName =  widget.passengerDetail.paxType.toString().replaceAll('PaxType.','');
    paxTypeName = capitalize(paxTypeName);
return SafeArea(
    child: Form(
        key: formKey,
    child: SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(5.0),
      child: Card(

      clipBehavior: Clip.antiAlias,
    child: Column(
      children: [
    ListTile(
      tileColor: gblSystemColors.primaryHeaderColor ,
    leading: Icon(Icons.person, size: 50.0, color: gblSystemColors.headerTextColor   ,),
    title: Text(translate('Passenger') + ' ' + widget.passengerDetail.paxNumber + ' (' + translate(paxTypeName) + ')'  , style: TextStyle(color: gblSystemColors.headerTextColor),),
/*    subtitle: Text(
    'Secondary Text',
    style: TextStyle(color: Colors.black.withOpacity(0.6)),
    ),
 */
    ),
        Padding(
      padding: EdgeInsets.fromLTRB(15.0, 0, 15, 15),
      child: Column(
        children:  renderFields(),

       )),
        ])
    ),
)
    )
));


  }

Widget _getTitle(){
    if( wantPageV2()) {
      return v2BorderBox(context,  ' ' + translate('Title'),
        TextFormField(
    decoration: v2Decoration(),

  controller: _titleTextEditingController,
  validator: (value) =>
  value!.isEmpty ? translate('Title cannot be empty') : null,
  onSaved: (value) {
  if (value != null) {
  }
  },
  ),
        padding: EdgeInsets.only(left: 10, right: 10),
      );
        } else {
  return TextFormField(
  decoration: getDecoration('Title'),
  // initialValue: translate(widget.passengerDetail.title),

  controller: _titleTextEditingController,
  validator: (value) =>
  value!.isEmpty ? translate('Title cannot be empty') : null,
  onSaved: (value) {
  if (value != null) {
  //widget.passengerDetail.title = value.trim();
  //_titleTextEditingController.text =translate(widget.passengerDetail.title);
  }
  },
  );
  }
}

Widget getFirstname() {
 /* if( wantPageV2()) {
    return V2TextWidget(
      title: 'First name (as Passport)',
      validator: (value) => value.isEmpty ? translate('First name cannot be empty') : null,
      textInputAction:  TextInputAction.done,
        controller: _firstNameTextEditingController,
        onFieldSubmitted: (value) {
          widget.passengerDetail.firstName = value;
        },
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp("[a-zA-Z- ÆØøäöåÄÖÅæé]"))
      ],
        onSaved: (value) {
          if (value != null) {
            widget.passengerDetail.firstName = value.trim();
          }
        }
    );




  return v2BorderBox(context,  ' ' + translate('First name (as Passport)'),
      TextFormField(
          decoration: v2Decoration(),
        controller: _firstNameTextEditingController,
        onFieldSubmitted: (value) {
          widget.passengerDetail.firstName = value;
        },
        textInputAction: TextInputAction.done,
        // keyboardType: TextInputType.text,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp("[a-zA-Z- ÆØøäöåÄÖÅæé]"))
        ],
        validator: (value) =>
        value.isEmpty ? translate('First name cannot be empty') : null,
        onSaved: (value) {
          if (value != null) {
            widget.passengerDetail.firstName = value.trim();
          }
        },
      ),
      padding: EdgeInsets.only(left: 10, right: 10),
    );
          } else {*/
    return V2TextWidget(
      maxLength: 50,
      decoration: getDecoration('First name (as Passport)'),
      controller: _firstNameTextEditingController,
      onFieldSubmitted: (value) {
        widget.passengerDetail.firstName = value;
      },
      textInputAction: TextInputAction.done,
      // keyboardType: TextInputType.text,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp("[a-zA-Z- ÆØøäöåÄÖÅæé]"))
      ],
      validator: (value) =>
      value!.isEmpty ? translate('First name cannot be empty') : null,
      onSaved: (value) {
        if (value != null) {
          widget.passengerDetail.firstName = value.trim();
        }
      },
    );
  //}
}

  Widget getLastname() {
 /* if( wantPageV2()){
    return V2TextWidget(
        title: 'Last name (as Passport)',
      maxLength: 50,
      controller: _lastNameTextEditingController,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp("[a-zA-Z- ÆØøäöåÄÖÅæé]"))
      ],
      onFieldSubmitted: (value) {
        widget.passengerDetail.lastName = value;
      },
      validator: (value) =>
      value.isEmpty ? translate('Last name cannot be empty') : null,
      onSaved: (value) {
        if (value != null) {
          widget.passengerDetail.lastName = value.trim();
        }
      },
    );
  } else {*/
    return   V2TextWidget(
      maxLength: 50,
      decoration: getDecoration('Last name (as Passport)'),
      controller: _lastNameTextEditingController,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp("[a-zA-Z- ÆØøäöåÄÖÅæé]"))
      ],
      onFieldSubmitted: (value) {
        widget.passengerDetail.lastName = value;
      },
      validator: (value) =>
      value!.isEmpty ? translate('Last name cannot be empty') : null,
      onSaved: (value) {
        if (value != null) {
          widget.passengerDetail.lastName = value.trim();
        }
      },
    );
 //}
  }

  Widget getMiddlename() {
   /* if( wantPageV2()){
      return V2TextWidget(
          title: 'Middle name (or NONE)',
        controller: _middleNameTextEditingController,
        onFieldSubmitted: (value) {
          widget.passengerDetail.middleName = value;
        },
        textInputAction: TextInputAction.done,
        // keyboardType: TextInputType.text,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp("[a-zA-Z- ÆØøäöåÄÖÅæé]"))
        ],
        validator: (value) =>
        value.isEmpty ? translate(
            'Middle name cannot be empty - type NONE if none') : null,
        onSaved: (value) {
          if (value != null) {
            widget.passengerDetail.middleName = value.trim();
          }
        },
      );
    } else {*/
      return V2TextWidget(
        maxLength: 50,
        decoration: getDecoration('Middle name (or NONE)'),
        controller: _middleNameTextEditingController,
        onFieldSubmitted: (value) {
          widget.passengerDetail.middleName = value;
        },
        textInputAction: TextInputAction.done,
        // keyboardType: TextInputType.text,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp("[a-zA-Z- ÆØøäöåÄÖÅæé]"))
        ],
        validator: (value) =>
        value!.isEmpty ? translate(
            'Middle name cannot be empty - type NONE if none') : null,
        onSaved: (value) {
          if (value != null) {
            widget.passengerDetail.middleName = value.trim();
          }
        },
      );
    //}
  }

  Widget getFqtv() {
  /*  if( wantPageV2()){
      return V2TextWidget(
          title: gblSettings.fqtvName == null
              ? 'FQTV number'
              : '${gblSettings.fqtvName} ' + translate('number'),
        maxLength: 20,
        keyboardType: TextInputType.text,
        controller: _fqtvTextEditingController,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp("[0-9]"))
        ],
        onFieldSubmitted: (value) {
          widget.passengerDetail.fqtv = value;
        },
        validator: (value) => null, // value.isEmpty ? null, val,
        onSaved: (value) {
          if (value != null) {
            widget.passengerDetail.fqtv = value.trim();
          }
        },
      );
          } else {*/
    return V2TextWidget(
          maxLength: 20,
          decoration: getDecoration( gblSettings.fqtvName == null
          ? 'FQTV number'
              : '${gblSettings.fqtvName} ' + translate('number')),
          keyboardType: TextInputType.text,
          controller: _fqtvTextEditingController,
          inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp("[0-9]"))
          ],
          onFieldSubmitted: (value) {
          widget.passengerDetail.fqtv = value;
          },
          validator: (value) => null, // value.isEmpty ? null, val,
          onSaved: (value) {
          if (value != null) {
          widget.passengerDetail.fqtv = value.trim();
          }
          },
          );
        //  }
  }
  Widget getPhoneNumber() {
   /* if( wantPageV2()) {
      return V2TextWidget(
        title:'Phone Number',
        maxLength: 50,
        controller: _phoneTextEditingController,
        keyboardType: TextInputType.number,
        validator: (value) =>
        value.isEmpty ? translate('Phone Number cannot be empty') : null,
        onFieldSubmitted: (value) {
          widget.passengerDetail.phonenumber = value;
        },
        onSaved: (value) {
          if (value != null) {
            widget.passengerDetail.phonenumber = value.trim();
          }
        },
      );
    } else {*/
      return V2TextWidget(
        maxLength: 50,
        decoration: getDecoration('Phone Number'),
        controller: _phoneTextEditingController,
        keyboardType: TextInputType.number,
        validator: (value) =>
        value!.isEmpty ? translate('Phone Number cannot be empty') : null,
        onFieldSubmitted: (value) {
          widget.passengerDetail.phonenumber = value;
        },
        onSaved: (value) {
          if (value != null) {
            widget.passengerDetail.phonenumber = value.trim();
          }
        },
      );
    //}
  }

 List <Widget> renderFields() {
    List <Widget> list = [];
    ThemeData theme =    new ThemeData(
      primaryColor: Colors.blueAccent,
      primaryColorDark: Colors.blue,
    );
    EdgeInsetsGeometry _padding = EdgeInsets.fromLTRB(0, 2, 0, 2);

    //return Column(children: <Widget>[
    //logit('title = ${widget.passengerDetail.title}');
    list.add(Padding(padding: EdgeInsets.all(5)));
    list.add(Padding(
      padding: _padding,
      child: InkWell(
        onTap: () {
          //formSave();
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: new TrText('Salutation'),
                content: new Container(
                  width: double.maxFinite,
                  child: optionListView(),
                ),
              );
            },
          );
        },
        child: IgnorePointer(
          child: _getTitle(),
        ),
      ),
    ));

    // first name
    list.add(Padding(
      padding: _padding,
      child: new Theme(
        data: theme ,
        child: getFirstname(),

      ),
    ));

    // middle name
    if( gblSettings.wantMiddleName) {
      list.add(Padding(
        padding: _padding,
        child: new Theme(
          data: theme ,
          child: getMiddlename(),
        ),
      ));

    }


    // last name
    list.add(Padding(
      padding: _padding,
      child: new Theme(
        data: theme,
        child: getLastname(),

      ),
    ));

    bool wantDOB = false;
    //logit('Pax type: ${widget.passengerDetail.paxType.toString()}');
    switch (widget.passengerDetail.paxType) {
      case PaxType.adult:
        if( gblSettings.passengerTypes.wantAdultDOB) {
          wantDOB = true;
        }
        break;
      case PaxType.senior:
        if( gblSettings.passengerTypes.wantSeniorDOB) {
          wantDOB = true;
        }
        break;
      case PaxType.student:
        if( gblSettings.passengerTypes.wantStudentDOB) {
          wantDOB = true;
        }
        break;
      case PaxType.youth:
        if( gblSettings.passengerTypes.wantYouthDOB) {
          wantDOB = true;
        }
        break;

      default:
        wantDOB = true;
        break;
    }


    // DOB
    if( wantDOB) {
      list.add(Padding(
        padding: _padding,
        child: InkWell(
          onTap: () {
            _showCalenderDialog(widget.passengerDetail.paxType);
          },
          child: IgnorePointer(
            child: TextFormField(
              decoration: getDecoration('Date of Birth'),
              //initialValue: field.value,
              controller: _dateOfBirthTextEditingController,
              validator: (value) =>
              value!.isEmpty ? translate('Date of Birth is required') : null,
              onSaved: (value) {
                if (value != '') {
                  var date = value!.split('-')[2] +
                      ' ' +
                      value.split('-')[1] +
                      ' ' +
                      value.split('-')[0];
                  DateFormat format = new DateFormat("yyyy MMM dd");
                  widget.passengerDetail.dateOfBirth = format.parse(date);
                }
              },

              // DateFormat format = new DateFormat("yyyy MMM dd"); DateTime.parse(value),  //value.trim(),
            ),
          ),
        ),
      ));
    }
    if( widget.passengerDetail.paxType == PaxType.adult &&
        gblSettings.wantFQTV ) {
      list.add(Padding(
        padding: _padding,
        child: new Theme(
          data: theme,
          child: getFqtv(),
        ),
      ));

    }
    if(widget.isAdsBooking) {
      list.add(Padding(
        padding: _padding,
        child: TextFormField(
          maxLength: 20,
          textCapitalization: TextCapitalization.characters,
          decoration: getDecoration('ADS / Island Resident number'),

          keyboardType: TextInputType.text,
          controller: _adsNumberTextEditingController,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp("[0-9adsADSRESres]"))
          ],
          onFieldSubmitted: (value) {
            widget.passengerDetail.adsNumber = value;
          },
          validator: (value) {
            if (value!.isEmpty) {
              return 'An ADS / Island Resident number is required';
             } else if (!(value.toUpperCase().startsWith('ADS') || value.toUpperCase().startsWith('RES') ) ||
                value.length != 16 ||
                !isNumeric(value.substring(3))) {
              return 'ADS / Island Resident not valid';
            } else {
              return null;
            }
          },
          onSaved: (value) {
            if (value != null) {
              widget.passengerDetail.adsNumber = value.trim();
            }
          },
        ),
      ));
    }
    if(widget.isAdsBooking ) {
      list.add( Padding(
        padding: _padding,
        child: TextFormField(
          maxLength: 4,
          textCapitalization: TextCapitalization.characters,
          decoration: getDecoration('ADS / Island Resident Pin'),
          keyboardType: TextInputType.text,
          obscureText: true,
          controller: _adsPinTextEditingController,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp("[0-9]"))
          ],
          onFieldSubmitted: (value) {
            widget.passengerDetail.adsPin = value;
          },
          validator: (value) {
            if (value!.isEmpty) {
              return 'ADS Pin is required';
            } else {
              return null;
            }

          },
          onSaved: (value) {
            if (value != null) {
              widget.passengerDetail.adsPin = value.trim();
            }
          },
        ),
      ));
    }

    if( widget.isLeadPassenger) {
// phone
    if( gblSettings.wantInternatDialCode) {

      list.add(InternationalPhoneInput(
        padding: const EdgeInsets.fromLTRB(0, 8.0, 0, 8),
        popupTitle: translate('Select phone country'),
        controller: _phoneTextEditingController,
          codeController: gblPhoneCodeEditingController,
        //initialPhoneNumber: _phoneNumberTextEditingController.text,
        decoration: InputDecoration.collapsed(hintText: '(123) 123-1234'),
        onSaved: (String newNumber) {
          setState(() {
            widget.passengerDetail.phonenumber = newNumber + _phoneTextEditingController.text; //newNumber ;
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
        initialPhoneNumber: _phoneTextEditingController.text,
      ));

    } else {
      list.add(Padding(
        padding: _padding,
        child: new Theme(
          data: theme,
          child: getPhoneNumber(),
        ),
      ));
    }

      // email
      list.add(Padding(
        padding: _padding,
        child: new Theme(
          data: theme,
          child: V2TextWidget(
            maxLength: 50,
            decoration: getDecoration('Email'),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            controller: _emailTextEditingController,
            inputFormatters: [
              FilteringTextInputFormatter.deny(RegExp("[#'!£^&*(){},|]"))
            ],
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
                String er = validateEmail(value!.trim());
                if(er != '' ) return er;
                return null;

            },
            onFieldSubmitted: (value) {
              widget.passengerDetail.email = value;
            },
            onSaved: (value) {
              if (value != null) {
                widget.passengerDetail.email = value.trim();
              }
            },
          ),
        ),
      ));
    }

// Gender
   if( gblSettings.wantGender) {
     list.add(Padding(
       padding: _padding,
       child: new Theme(
         data: theme,
         child: genderPicker(_padding, theme),
       ),
     ));
   }


   // redress number
   if ( gblSettings.wantRedressNo ) {
     list.add(Padding(
       padding: _padding,
       child: new Theme(
         data: theme,
         child: TextFormField(
           maxLength: 50,
           decoration: getDecoration('Redress Number (if applicable)'),
           controller: _redressNoTextEditingController,
           keyboardType: TextInputType.streetAddress,
           //inputFormatters: [          FilteringTextInputFormatter.digitsOnly,        ],
           onFieldSubmitted: (value) {
             widget.passengerDetail.redressNo = value;
           },
           onSaved: (value) {
             if (value != null) {
               widget.passengerDetail.redressNo = value.trim();
             }
           },
         ),
       ),
     ));
   }

   // know traveller number
   if ( gblSettings.wantKnownTravNo ) {
     list.add(Padding(
       padding: _padding,
       child: new Theme(
         data: theme,
         child: TextFormField(
           maxLength: 50,
           decoration: getDecoration('Known Traveller Number (if applicable)'),
           controller: _knownTravellerNoTextEditingController,
           keyboardType: TextInputType.streetAddress,
           //inputFormatters: [          FilteringTextInputFormatter.digitsOnly,        ],
           onFieldSubmitted: (value) {
             widget.passengerDetail.knowTravellerNo = value;
           },
           onSaved: (value) {
             if (value != null) {
               widget.passengerDetail.knowTravellerNo = value.trim();
             }
           },
         ),
       ),
     ));
   }


// Country
   if( gblSettings.wantCountry) {
     list.add(Padding(
       padding: _padding,
       child: new Theme(
         data: theme,
         child: countryPicker(_padding, theme) as Widget,
       ),
     ));
   }
// Senior ID
   if( widget.passengerDetail.paxType == PaxType.senior && gblSettings.aircode == 'T6' && widget.passengerDetail.country == 'Philippines' ) {
     list.add(Padding(
       padding: _padding,
       child: new Theme(
         data: theme,
         child: TextFormField(
           maxLength: 50,
           decoration: getDecoration('Senior Citizen ID'),
           controller: _seniorIDTextEditingController,
           keyboardType: TextInputType.streetAddress,
           onFieldSubmitted: (value) {
             widget.passengerDetail.seniorID = value;
           },
           onSaved: (value) {
             if (value != null) {
                widget.passengerDetail.seniorID = value.trim();
             }
           },
         ),
       ),
     ));
     list.add(infoBox(
         'Senior Citizen is entitled of 20% discount and VAT exempt upon presenting valid ID card issued by the OSCA. This discount applies to base fare only and does not apply to products such as prepaid baggage, travel insurance and reserve seats. Failure to provide the required valid identification, evidence and documents upon check-in will result to invalidate the senior citizen discount granted plus a penalty of Php 1,500.00 and airfare difference from the regular fare or forfeiture of ticket.'));
   }
    //logit('Country: ' + widget.passengerDetail.country);

   if (gblSettings.aircode == 'T6' && widget.passengerDetail.country == 'Philippines' &&  widget.passengerDetail.paxType != PaxType.senior) {
     list.add(infoBox(
         'Persons with Disability availing of the 20% discount are required to present a PWD ID issued by the National Council on Disability Affairs (NCDA) or local government unit upon check-in or boarding.' +
        'This discount applies to the base fare, and does not apply to add-ons such as baggage allowance or inflight meals.' ));
// disability
     list.add(Padding(
       padding: _padding,
       child: new Theme(
         data: theme,
         child: TextFormField(
           maxLength: 50,
           decoration: getDecoration('disability ID'),
           controller: _disabilityIDTextEditingController,
           //keyboardType: TextInputType.emailAddress,
           //validator: (value) => validateEmail(value.trim()),
           onFieldSubmitted: (value) {
             widget.passengerDetail.disabilityID = value;
           },
           onSaved: (value) {
             if (value != null) {
                widget.passengerDetail.disabilityID = value.trim();
             }
           },
         ),
       ),
     ));
   }

   if( gblSettings.wantCovidWarning) {
     String covidText = 'Are you travelling (back) to the UK? You may need a negative COVID-19 test result, and you may be required to quarentine.';

     list.add(warningBox(covidText ));
   }

   list.add(ButtonBar(
     alignment: MainAxisAlignment.start,
     children: [
       TextButton(
         style: TextButton.styleFrom(
             backgroundColor: actionButtonColor(),
             side: BorderSide(color:  gblSystemColors.textButtonTextColor, width: 1),
             foregroundColor: gblSystemColors.primaryButtonTextColor),
         onPressed: () {
           if( gblActionBtnDisabled == false) {
             gblActionBtnDisabled = true;
             setState(() {
             });
             validateAndSubmit();
           }
         },
         child: Text( '    ' + translate('SAVE') + '    '),
       ),
     ],
   ));

   list.add(Padding(
     padding: new EdgeInsets.only(top: 10.0),
   ));




    if( gblSettings.wantRememberMe && widget.isLeadPassenger && (widget.passengerDetail.lastName == null || widget.passengerDetail.lastName.isEmpty) ) {
      // add check box
      list.add(CheckboxListTile(
        title: TrText("Remember me"),
        value: gblRememberMe,
        onChanged: (newValue) {
          setState(() {
            gblRememberMe = newValue!;
          });
        },
        controlAffinity: ListTileControlAffinity.leading,  //  <-- leading Checkbox
      ));
    }
   return list;

  }

Widget genderPicker (EdgeInsetsGeometry padding, ThemeData theme) {
  var index = 0;

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
                logit('Value = ' + value.toString());
                widget.passengerDetail.gender = genderList[ value!];

              });
            },
          ) )
  );

}


  Widget? countryPicker(EdgeInsetsGeometry padding, ThemeData theme) {
    // get current country index

    return FutureBuilder(
        future: getCountrylist(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data != null) {
              Countrylist countrylist = snapshot.data;
             // String val = countrylist.countries[0].enShortName;
              var curIndex ;
              var index = 0;
              var tempIndex = 0;
              if(widget.passengerDetail.country != '' ) {
                countrylist.countries!.forEach((country) {
                  if (widget.passengerDetail.country.toUpperCase() ==
                      country.enShortName.toUpperCase()) {
                    curIndex = tempIndex;
                  }
                  tempIndex += 1;
                });
              }
              return Padding(
                  padding: padding,
                  child: new Theme(
                  data: theme,
                  child: DropdownButtonFormField<int>(
                    decoration: getDecoration('Country'),
                      value: curIndex,
                      items: countrylist.countries!.map((country ) {
                       // logit('index= $index curIndex=$curIndex ${country.enShortName}');
                       // if( curIndex == index+1) logit('index==curIndex ${country.enShortName}');
                      return DropdownMenuItem(
                           child: addCountry(country), //ext(trimCountry(country.enShortName)),
                           value: index++,
                         );
                      }
                      ).toList(),

                     // DbCountryext('Country'),
                      onChanged: (value) {
                        setState(() {
                          logit('Value = ' + value.toString());
                          widget.passengerDetail.country = countrylist.countries![value!].enShortName;
                          logit('sel country = ' + widget.passengerDetail.country);
                         // _ratingController = value;
                        });
                      },
                    ) )
              );
            }
          } else {
            return new CircularProgressIndicator();
          }
          return Container();
        });
  }

 String trimCountry(String name) {
    if( name.length > 15) {
      name = name.substring(0,14);
    }
    return name;
  }


  ListView optionListView() {
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

  void _updateTitle(String value) {
    setState(() {
      widget.passengerDetail.title = value;
      _titleTextEditingController.text = translate(value);
      //FocusScope.of(context).requestFocus(new FocusNode());
    });
  }

  Future<void> adsValidate() async {
    setState(() {
      //_loadingInProgress = true;
    });
    logit('adsValidate E');
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
        gblActionBtnDisabled = false;
        Navigator.pop(context, widget.passengerDetail);
      } else {
        _error = 'Please check your details';
        gblActionBtnDisabled = false;
        _actionCompleted();
        _showDialog();
      }
    } catch (e) {
      gblActionBtnDisabled = false;
      _actionCompleted();
      _showDialog();
    }
  }

  void _actionCompleted() {
    setState(() {
      //_loadingInProgress = false;
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
              : new Text("ADS login failed. Please try again"),
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

  _showCalenderDialog(PaxType paxType) {
    DateTime dateTime = DateTime.now();
    DateTime _maximumDate;
    DateTime _minimumDate;
    DateTime _initialDateTime;
    int _minimumYear;
    int _maximumYear;
    formSave();

    // VRS uses todays date - not date of travel, code here to use date of travel if required
    DateTime lastFltDate = DateTime.now();
//    DateTime lastFltDate = widget.newBooking.departureDate;
//    if( widget.newBooking.returnDate != null ){
//      lastFltDate = widget.newBooking.returnDate;
//    }

//    logit('dep dt: ' + widget.newBooking.departureDate.toString());
//    logit('ret dt: ' + widget.newBooking.returnDate.toString());

    switch (paxType) {
      case PaxType.infant:
        {
          _initialDateTime = DateTime.now();
          _minimumDate = DateTime.now().subtract(new Duration(days: (365 * 2 -1 )));
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
          _initialDateTime = DateTime( lastFltDate.year - gblSettings.passengerTypes.youthMinAge, lastFltDate.month, lastFltDate.day );
          _minimumDate = DateTime( lastFltDate.year - gblSettings.passengerTypes.youthMaxAge, lastFltDate.month, lastFltDate.day );
          logit('init $_initialDateTime' );
          logit('min $_minimumDate' );
          //_initialDateTime =DateTime.now().subtract(new Duration(days: (4015)));
          //_minimumDate = DateTime.now().subtract(new Duration(days: (5840)));
        }
        break;
/*      case PaxType.student:
        {
          _initialDateTime =
              DateTime.now().subtract(new Duration(days: (4015)));
          _minimumDate = DateTime.now().subtract(new Duration(days: (5840)));
        }
        break;
      case PaxType.senior:
        {
          _initialDateTime =
              DateTime.now().subtract(new Duration(days: (4015)));
          _minimumDate = DateTime.now().subtract(new Duration(days: (5840)));
        }
        break;

 */
      case PaxType.adult:
        {
          _initialDateTime = DateTime.now();
          _minimumDate = DateTime( 110, 0, 0 );
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
    dateTime = _initialDateTime;

    _updateDateOfBirth(_initialDateTime);

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
                  brightness: brightnessValue,
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
                     // print(newValue);
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
              child: new TrText("OK", style: TextStyle(color: txtColor),
              ),
              onPressed: () {
                Navigator.pop(context, dateTime);
                _updateDateOfBirth(dateTime );
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

  bool validateAndSave() {
    final form = formKey.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    } else {
      return false;
    }
  }

  void formSave() {
    final form = formKey.currentState;
    form!.save();
  }

  void validateAndSubmit() async {
    if (validateAndSave()) {
      if (widget.isAdsBooking /*&& widget.isLeadPassenger */ && widget.passengerDetail.adsNumber != '') {
        await adsValidate();
      } else {
        try {
          gblActionBtnDisabled = false;
          Navigator.pop(context, widget.passengerDetail);
        } catch (e) {
          print('Error: $e');
        }
      }
    } else {
      gblActionBtnDisabled = false;
    }
  }

  bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return num.tryParse(s) != null;
  }

}
