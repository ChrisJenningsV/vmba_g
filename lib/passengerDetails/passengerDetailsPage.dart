import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:convert';
import 'package:vmba/contactDetails/contactDetailsPage.dart';
import 'package:vmba/data/models/models.dart';
import 'package:vmba/data/repository.dart';
import 'package:vmba/menu/menu.dart';
import 'package:vmba/passengerDetails/widgets/editPage.dart';
import 'package:vmba/utilities/helper.dart';
import 'package:vmba/utilities/widgets/snackbarWidget.dart';
import 'package:vmba/data/globals.dart';

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
      _passengerDetails.add(new PassengerDetail());
    }

    //.then((result) result == true ? loadProfileIntoPaxDetails: {});

    Repository.get()
        .getNamedUserProfile('PAX1')
        .then((profile) {
      try {
        Map map = json.decode(
            profile.value.toString().replaceAll("'", '"')); // .replaceAll(',}', '}')
        passengerDetailRecord = PassengerDetail.fromJson(map);
        if(isUserProfileComplete()) {
          preloadProfile(context);
        }
        if(gblPassengerDetail != null && gblPassengerDetail.adsNumber != null &&
            gblPassengerDetail.adsNumber.isNotEmpty && gblPassengerDetail.adsPin != null &&
            gblPassengerDetail.adsPin.isNotEmpty ) {
          passengerDetailRecord.adsNumber = gblPassengerDetail.adsNumber;
          passengerDetailRecord.adsPin = gblPassengerDetail.adsPin;
        }
      } catch(e) {
        print(e);
      }
    });


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
        .where((pax) =>
            pax.title == '' || pax.title == null ||
                pax.firstName == '' || pax.firstName == null||
                pax.lastName == '' || pax.lastName == null)
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
          title: new Text("Load Details"),
          content: Text("Would you like to preload your details?"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new TextButton(
              child: new Text("NO"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            new TextButton(
              child: new Text("YES"),
              onPressed: () {
                preLoadDetails = true;
                loadProfileIntoPaxDetails();
                showContinueButton();
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  loadProfileIntoPaxDetails() {
    int paxNo = 0;
    setState(() {
      if (passengerDetailRecord.title != null && passengerDetailRecord.title.length > 0) {
        _passengerDetails[paxNo].title = passengerDetailRecord.title;
      }

      if (passengerDetailRecord.firstName != null && passengerDetailRecord.firstName.length > 0) {
        _passengerDetails[paxNo].firstName = passengerDetailRecord.firstName;
      }

      if (passengerDetailRecord.lastName != null && passengerDetailRecord.lastName != 'null' && passengerDetailRecord.lastName.length > 0) {
        _passengerDetails[paxNo].lastName = passengerDetailRecord.lastName;
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

    });
  }

  bool isUserProfileComplete() {
    if( (passengerDetailRecord.firstName.length ==            0) ||
        (passengerDetailRecord.firstName ==            '')) {
      return false;
    }

    if ((passengerDetailRecord.lastName.length == 0) ||
        (passengerDetailRecord.lastName  == '')) {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    //Show dialog

    return new Scaffold(
      key: _key,
      appBar: new AppBar(
        brightness: gblSystemColors.statusBar,
        backgroundColor: gblSystemColors.primaryHeaderColor,
        iconTheme: IconThemeData(
            color: gblSystemColors.headerTextColor),
        title: new Text('Passengers Details',
            style: TextStyle(
                color:
                gblSystemColors.headerTextColor)),
      ),
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
    // List<Widget>();
    int i = 0;

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
            Text(
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
    return paxWidgets;
  }

  String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

  Row paxEntryHeader(PaxType paxType, bool single) {
    String _passenger = 'Passengers';
    if (single) {
      _passenger = 'Passenger';
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Text(
          '${capitalize(paxType.toString().split('.')[1])} $_passenger',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ],
    );
  }

  Widget renderFieldsV2(int paxNo, PaxType paxType) {
    bool isLeadPassenger = paxNo == 1 ? true : false;
    _passengerDetails[paxNo - 1].paxType = paxType;
    if (_passengerDetails[paxNo - 1].firstName != '' && _passengerDetails[paxNo - 1].firstName != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
              '${_passengerDetails[paxNo - 1].title} ${_passengerDetails[paxNo - 1].firstName} ${_passengerDetails[paxNo - 1].lastName}'),
          IconButton(
            onPressed: () {
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
          Text('Add new ${paxType.toString().split('.')[1]} passenger'),
          IconButton(
              onPressed: () {
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
              },
              icon: Icon(Icons.add_circle),
              iconSize: 20)
        ],
      );
    }
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
          var _error = await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ContactDetailsWidget(
                        newbooking: widget.newBooking,
                        preLoadDetails: preLoadDetails,
                      passengerDetailRecord: passengerDetailRecord,
                      )));
          displayError(_error);
        } else {
          showSnackBar('Please check your internet connection');
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
              title: new Text("Error"),
              content:
                  error != '' ? new Text(error) : new Text("Please try again"),
              actions: <Widget>[
                // usually buttons at the bottom of the dialog
                new TextButton(
                  child: new Text("OK"),
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
