import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:vmba/contactDetails/contactDetailsPage.dart';
import 'package:vmba/data/models/models.dart';
import 'package:vmba/data/repository.dart';
import 'package:vmba/menu/menu.dart';
import 'package:vmba/passengerDetails/widgets/editPage.dart';
import 'package:vmba/passengerDetails/widgets/editPax.dart';
import 'package:vmba/utilities/helper.dart';
import 'package:vmba/utilities/widgets/snackbarWidget.dart';
import 'package:vmba/data/globals.dart';
import 'package:vmba/components/trText.dart';
import 'package:vmba/utilities/widgets/appBarWidget.dart';
import 'package:vmba/passengerDetails/DangerousGoodsWidget.dart';

class PassengerDetailsWidget extends StatefulWidget {
  PassengerDetailsWidget({Key key, this.newBooking}) : super(key: key);
  final NewBooking newBooking;

  _PassengerDetailsWidgetState createState() => _PassengerDetailsWidgetState();
}

class _PassengerDetailsWidgetState extends State<PassengerDetailsWidget> {
  List<PassengerDetail> _passengerDetails = [];
  // List<PassengerDetail>();
  GlobalKey<ScaffoldState> _key = GlobalKey();
  final formKey = new GlobalKey<FormState>();
  bool allPaxDetailsCompleted = false;
  bool preLoadDetails = false;

  //UserProfileRecord userProfileRecord;
  PassengerDetail passengerDetailRecord;

  @override
  initState() {
    super.initState();
    for (var i = 0;
        i <= widget.newBooking.passengers.totalPassengers() - 1;
        i++) {
      var pax = new PassengerDetail();
      if(i==0) {
        if(gblPassengerDetail != null && gblPassengerDetail.adsNumber != null &&
            gblPassengerDetail.adsNumber.isNotEmpty && gblPassengerDetail.adsPin != null &&
            gblPassengerDetail.adsPin.isNotEmpty ) {
          pax.adsNumber = gblPassengerDetail.adsNumber;
          pax.adsPin = gblPassengerDetail.adsPin;
        }
      }
      _passengerDetails.add(pax);
    }

    //.then((result) result == true ? loadProfileIntoPaxDetails: {});

    if(isUserProfileComplete()) {
      if( loadProfileIntoPaxDetails()) {
        showContinueButton();
      }
    } else {
      Repository.get()
          .getNamedUserProfile('PAX1')
          .then((profile) {
        try {
          if( profile == null ) {
            print('profile null ');
            return;
          }
          Map map = json.decode(
              profile.value.toString().replaceAll(
                  "'", '"')); // .replaceAll(',}', '}')
          passengerDetailRecord = PassengerDetail.fromJson(map);
          if(  passengerDetailRecord.fqtv != null &&  passengerDetailRecord.fqtv.isNotEmpty ) {
            gblFqtvNumber = passengerDetailRecord.fqtv;
          }

          if (gblPassengerDetail != null &&
              gblPassengerDetail.adsNumber != null &&
              gblPassengerDetail.adsNumber.isNotEmpty &&
              gblPassengerDetail.adsPin != null &&
              gblPassengerDetail.adsPin.isNotEmpty) {
            passengerDetailRecord.adsNumber = gblPassengerDetail.adsNumber;
            passengerDetailRecord.adsPin = gblPassengerDetail.adsPin;
          }
          if (isUserProfileComplete()) {
            setState(() {
              preloadProfile(context);
            });
          }
        } catch (e) {
          print(e);
        }
      });
    }
  }

  showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(snackbar(message));
    //final _snackbar = snackbar(message);
    //_key.currentState.showSnackBar(_snackbar);
  }

  updatePassengerDetails(PassengerDetail passengerDetail, int itemNo) {
    if (passengerDetail != null)
      setState(() {
        _passengerDetails[itemNo] = passengerDetail;
      });
    showContinueButton();
  }

  showContinueButton() {
    int uncompletedItems;
    uncompletedItems = _passengerDetails
        .where((pax) => !pax.isComplete()
/*            pax.title == '' || pax.title == null ||
                pax.firstName == '' || pax.firstName == null||
                pax.lastName == '' || pax.lastName == null ||
                (gblSettings.wantGender && (pax.gender == null || pax.gender.isEmpty )) ||
                (gblSettings.wantMiddleName && (pax.middleName == null || pax.middleName.isEmpty ))
*/
    )
        .length;



    if (uncompletedItems == 0) {
      setState(() {
        allPaxDetailsCompleted = true;
      });
    }
  }

  preloadProfile(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new TrText("Load Details"),
          content: TrText("Would you like to preload your details?"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new TextButton(
              child: new TrText("NO"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            new TextButton(
              child: new TrText("YES"),
              onPressed: () {
                preLoadDetails = true;
                if( loadProfileIntoPaxDetails()) {
                  showContinueButton();
                }
                Navigator.pop(context);
                setState(() {
                });
              },
            ),
          ],
        );
      },
    );
  }

  bool loadProfileIntoPaxDetails() {
    int paxNo = 0;
    bool gotAllDetails = true;
//    setState(() {
      if (passengerDetailRecord.title != null && passengerDetailRecord.title.length > 0) {
        _passengerDetails[paxNo].title = passengerDetailRecord.title;
      } else {
        gotAllDetails = false;
      }

      if (passengerDetailRecord.firstName != null && passengerDetailRecord.firstName.length > 0) {
        _passengerDetails[paxNo].firstName = passengerDetailRecord.firstName;
      } else {
        gotAllDetails = false;
      }

    if (passengerDetailRecord.middleName != null && passengerDetailRecord.middleName.length > 0) {
      _passengerDetails[paxNo].middleName = passengerDetailRecord.middleName;
    }

    if (passengerDetailRecord.lastName != null && passengerDetailRecord.lastName != 'null' && passengerDetailRecord.lastName.length > 0) {
        _passengerDetails[paxNo].lastName = passengerDetailRecord.lastName;
    } else {
      gotAllDetails = false;
      }

      if (passengerDetailRecord.fqtv != null &&  passengerDetailRecord.fqtv != 'null' && passengerDetailRecord.fqtv.length > 0 ) {
        _passengerDetails[paxNo].fqtv = passengerDetailRecord.fqtv;
      }

      if (passengerDetailRecord.adsNumber != null && passengerDetailRecord.adsNumber != 'null' && passengerDetailRecord.adsNumber.length > 0) {
        _passengerDetails[paxNo].adsNumber = passengerDetailRecord.adsNumber;
      }

      if (passengerDetailRecord.adsPin != null && passengerDetailRecord.adsPin != 'null' && passengerDetailRecord.adsPin.length > 0) {
        _passengerDetails[paxNo].adsPin =passengerDetailRecord.adsPin;
      }

      if (passengerDetailRecord.adsPin != null && passengerDetailRecord.adsPin != 'null' && passengerDetailRecord.adsPin.length > 0) {
        _passengerDetails[paxNo].adsPin =passengerDetailRecord.adsPin;
      }
    if (passengerDetailRecord.email != null && passengerDetailRecord.email != 'null' && passengerDetailRecord.email.length > 0) {
      _passengerDetails[paxNo].email =passengerDetailRecord.email;
    } else {
      gotAllDetails = false;
    }

    if (passengerDetailRecord.phonenumber != null && passengerDetailRecord.phonenumber != 'null' && passengerDetailRecord.phonenumber.length > 0) {
      _passengerDetails[paxNo].phonenumber =passengerDetailRecord.phonenumber;
    } else {
      gotAllDetails = false;
    }

    if (passengerDetailRecord.disabilityID != null && passengerDetailRecord.disabilityID != 'null' && passengerDetailRecord.disabilityID.length > 0) {
      _passengerDetails[paxNo].disabilityID =passengerDetailRecord.disabilityID;
    }
    if (passengerDetailRecord.seniorID != null && passengerDetailRecord.seniorID != 'null' && passengerDetailRecord.seniorID.length > 0) {
      _passengerDetails[paxNo].seniorID =passengerDetailRecord.seniorID;
    }
    if (passengerDetailRecord.country != null && passengerDetailRecord.country != 'null' && passengerDetailRecord.country.length > 0) {
      _passengerDetails[paxNo].country =passengerDetailRecord.country;
    }

    if( gblSettings.wantApis ) {
      if (passengerDetailRecord.redressNo != null &&
          passengerDetailRecord.redressNo.length > 0) {
        _passengerDetails[paxNo].redressNo = passengerDetailRecord.redressNo;
      } else {
        gotAllDetails = false;
      }

      if (passengerDetailRecord.knowTravellerNo != null &&
          passengerDetailRecord.knowTravellerNo.length > 0) {
        _passengerDetails[paxNo].knowTravellerNo =
            passengerDetailRecord.knowTravellerNo;
      } else {
        gotAllDetails = false;
      }

      if (passengerDetailRecord.gender != null &&
          passengerDetailRecord.gender.length > 0) {
        _passengerDetails[paxNo].gender = passengerDetailRecord.gender;
      } else {
        gotAllDetails = false;
      }

      if (passengerDetailRecord.dateOfBirth != null) {
        _passengerDetails[paxNo].dateOfBirth =
            passengerDetailRecord.dateOfBirth;
      } else {
        gotAllDetails = false;
      }
    }


    preLoadDetails = true;
    //showContinueButton();
    return gotAllDetails;
//    });
  }

  bool isUserProfileComplete() {
    if( passengerDetailRecord == null ) {
      if( gblPassengerDetail == null ) {
        return false;
      }
      passengerDetailRecord = gblPassengerDetail;
    }
    if(passengerDetailRecord.firstName != null && (passengerDetailRecord.firstName.length == 0) ||
        (passengerDetailRecord.firstName == '')) {
      return false;
    }

    if (passengerDetailRecord.lastName != null && (passengerDetailRecord.lastName.length == 0) ||
        (passengerDetailRecord.lastName  == '')) {
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    //Show dialog
    //print('build');

    return new Scaffold(
      key: _key,
      appBar: appBar(context, 'Passengers Details',
          curStep: 4,
          newBooking: widget.newBooking,
          imageName:  gblSettings.wantPageImages ? 'paxDetails': null ),
//      extendBodyBehindAppBar: gblSettings.wantCityImages,
      endDrawer: DrawerMenu(),
      body: new Form(
        key: formKey,
        child: new SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Column(
              children: renderPax(widget.newBooking.passengers),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> renderPax(Passengers pax) {
    List<Widget> paxWidgets = [];
    //print('renderPax');
    // List<Widget>();
    int i = 0;
//    paxWidgets.add(Padding(padding: EdgeInsets.all(50),));

    //Adult start
    if (pax.adults == 1) {
      paxWidgets.add(paxEntryHeader(PaxType.adult, true));
    } else if (pax.adults > 1) {
      paxWidgets.add(paxEntryHeader(PaxType.adult, false));
    }
    for (var adults = 1; adults < pax.adults + 1; adults++) {
      paxWidgets.add(renderFieldsV2(i += 1, PaxType.adult));
    }
    if (pax.adults != 0) {
      paxWidgets.add(Divider());
    }
    //Adult end

    //Youth start
    if (pax.youths == 1) {
      paxWidgets.add(paxEntryHeader(PaxType.youth, true));
    } else if (pax.youths > 1) {
      paxWidgets.add(paxEntryHeader(PaxType.youth, false));
    }
    for (var youths = 1; youths < pax.youths + 1; youths++) {
      paxWidgets.add(renderFieldsV2(i += 1, PaxType.youth));
    }
    if (pax.youths != 0) {
      paxWidgets.add(Divider());
    }
    //Youth end

    //studentstart
    if (pax.students == 1) {
      paxWidgets.add(paxEntryHeader(PaxType.student, true));
    } else if (pax.students > 1) {
      paxWidgets.add(paxEntryHeader(PaxType.student, false));
    }
    for (var students = 1; students < pax.students + 1; students++) {
      paxWidgets.add(renderFieldsV2(i += 1, PaxType.student));
    }
    if (pax.students != 0) {
      paxWidgets.add(Divider());
    }
    //student

    //senior start
    if (pax.seniors == 1) {
      paxWidgets.add(paxEntryHeader(PaxType.senior, true));
    } else if (pax.seniors > 1) {
      paxWidgets.add(paxEntryHeader(PaxType.senior, false));
    }
    for (var seniors = 1; seniors < pax.seniors + 1; seniors++) {
      paxWidgets.add(renderFieldsV2(i += 1, PaxType.senior));
    }
    if (pax.seniors != 0) {
      paxWidgets.add(Divider());
    }
    //senior

    //Child start
    if (pax.children == 1) {
      paxWidgets.add(paxEntryHeader(PaxType.child, true));
    } else if (pax.children > 1) {
      paxWidgets.add(paxEntryHeader(PaxType.child, false));
    }
    for (var child = 1; child < pax.children + 1; child++) {
      paxWidgets.add(renderFieldsV2(i += 1, PaxType.child));
    }
    if (pax.children != 0) {
      paxWidgets.add(Divider());
    }
    //Child end
    //Infant start
    if (pax.infants == 1) {
      paxWidgets.add(paxEntryHeader(PaxType.infant, true));
    } else if (pax.infants > 1) {
      paxWidgets.add(paxEntryHeader(PaxType.infant, false));
    }
    for (var infant = 1; infant < pax.infants + 1; infant++) {
      paxWidgets.add(renderFieldsV2(i += 1, PaxType.infant));
    }

    if (pax.infants != 0) {
      paxWidgets.add(Divider());
    }
    //Infant end

    if (allPaxDetailsCompleted) {
      paxWidgets.add(ElevatedButton(
        onPressed: () {
          gblPaymentMsg=null;
          validateAndSubmit();
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
            Icon(
              Icons.check,
              color: Colors.white,
            ),
            TrText(
              'CONTINUE',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ));
    }
    paxWidgets.add(Padding(
      padding: new EdgeInsets.only(top: 60.0),
    ));
    //print('end renderPax');
    return paxWidgets;
  }

  String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

  Row paxEntryHeader(PaxType paxType, bool single) {
    //print('paxEntryHeader');
    String _passenger = translate('Passengers');
    if (single) {
      _passenger = translate('Passenger');
    }
    String pType = translate(capitalize(paxType.toString().split('.')[1]));
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Text(
          '$pType $_passenger',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ],
    );
    //print('end paxEntryHeader');
  }

  Widget renderFieldsV2(int paxNo, PaxType paxType) {
    //print('renderFieldsV2');

    bool isLeadPassenger = paxNo == 1 ? true : false;
    _passengerDetails[paxNo - 1].paxType = paxType;
    _passengerDetails[paxNo - 1].paxNumber = paxNo.toString();
    if (_passengerDetails[paxNo - 1].firstName != '' && _passengerDetails[paxNo - 1].firstName != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
              '${_passengerDetails[paxNo - 1].title} ${_passengerDetails[paxNo - 1].firstName} ${_passengerDetails[paxNo - 1].lastName}'),
          IconButton(
            onPressed: () {
              if (gblSettings.wantNewEditPax) {
                Navigator.push(
                    context,
                    SlideTopRoute(
                        page: EditPaxWidget(
                      passengerDetail: _passengerDetails[paxNo - 1],
                      isAdsBooking: widget.newBooking.ads.isAdsBooking(),
                      isLeadPassenger: isLeadPassenger,
                      destination: widget.newBooking.arrival,
                            newBooking: widget.newBooking,
                    ))).then((passengerDetails) {
                  updatePassengerDetails(passengerDetails, paxNo - 1);
                });
              } else {
                Navigator.push(
                    context,
                    SlideTopRoute(
                        page: EditDetailsWidget(
                          passengerDetail: _passengerDetails[paxNo - 1],
                          isAdsBooking: widget.newBooking.ads.isAdsBooking(),
                          isLeadPassenger: isLeadPassenger,
                        ))).then((passengerDetails) {
                  updatePassengerDetails(passengerDetails, paxNo - 1);
                });

              }
            },
            icon: Icon(Icons.edit),
            iconSize: 20,
          )
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(translate('Add new') + ' ${paxType.toString().split('.')[1]} ' + translate('passenger')),
          IconButton(
              onPressed: () {
                if (gblSettings.wantNewEditPax) {
                  Navigator.push(
                      context,
                      SlideTopRoute(
                          page: EditPaxWidget(
                              passengerDetail: _passengerDetails[paxNo - 1],
                              isAdsBooking:
                              widget.newBooking.ads.isAdsBooking(),
                              isLeadPassenger: isLeadPassenger,
                              destination: widget.newBooking.arrival,
                            newBooking: widget.newBooking,)))
                      .then((passengerDetails) {
                    updatePassengerDetails(passengerDetails, paxNo - 1);
                  });
                } else {
                  Navigator.push(
                      context,
                      SlideTopRoute(
                          page: EditDetailsWidget(
                              passengerDetail: _passengerDetails[paxNo - 1],
                              isAdsBooking:
                              widget.newBooking.ads.isAdsBooking(),
                              isLeadPassenger: isLeadPassenger)))
                      .then((passengerDetails) {
                    updatePassengerDetails(passengerDetails, paxNo - 1);
                  });
                }
              },
              icon: Icon(Icons.add_circle),
              iconSize: 20)
        ],
      );
    }
    //print('end renderFieldsV2');
  }

  void validateAndSubmit() async {
    try {
      if (widget.newBooking.ads.isAdsBooking()) {
        widget.newBooking.ads.number = _passengerDetails[0].adsNumber;
        widget.newBooking.ads.pin = _passengerDetails[0].adsPin;
      }
      widget.newBooking.passengerDetails = _passengerDetails;

      hasDataConnection().then((result) async {
        if (result == true) {
            if( gblSettings.wantDangerousGoods == true ){
              Navigator.push(
                  context,
                  SlideTopRoute(
                      page: DangerousGoodsWidget( preLoadDetails: preLoadDetails, newBooking: widget.newBooking, passengerDetailRecord: passengerDetailRecord, ))).then((passengerDetails) {
                //updatePassengerDetails(passengerDetails, paxNo - 1);
              });
            } else {
              var _error = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ContactDetailsWidget(
                            newbooking: widget.newBooking,
                            preLoadDetails: preLoadDetails,
                            passengerDetailRecord: passengerDetailRecord,
                          )));
              displayError(_error);
            }

        } else {
          //showSnackBar('Please, check your internet connection');
          noInternetSnackBar(context);
        }
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  void displayError(String error) {
    {
      // flutter defined function
      if (error != null) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            // return object of type Dialog
            return AlertDialog(
              title: new TrText("Error"),
              content:
                  error != '' ? new Text(error) : new TrText("Please try again"),
              actions: <Widget>[
                // usually buttons at the bottom of the dialog
                new TextButton(
                  child: new TrText("OK"),
                  onPressed: () {
                    // _error = '';
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    }
  }
}
