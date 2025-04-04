
import 'package:flutter/material.dart';
import 'package:vmba/Helpers/bookingHelper.dart';
import 'package:vmba/Helpers/settingsHelper.dart';
import 'dart:convert';
import 'package:vmba/data/models/models.dart';
import 'package:vmba/data/models/pnr.dart';
import 'package:vmba/data/repository.dart';
import 'package:vmba/menu/menu.dart';
import 'package:vmba/passengerDetails/widgets/editPage.dart';
import 'package:vmba/passengerDetails/widgets/EditPax.dart';
import 'package:vmba/utilities/helper.dart';
import 'package:vmba/utilities/navigation.dart';
import 'package:vmba/utilities/widgets/snackbarWidget.dart';
import 'package:vmba/data/globals.dart';
import 'package:vmba/components/trText.dart';
import 'package:vmba/utilities/widgets/appBarWidget.dart';
import 'package:vmba/passengerDetails/DangerousGoodsWidget.dart';

import '../Products/optionsPage.dart';
import '../calendar/bookingFunctions.dart';
import '../components/bottomNav.dart';
import '../components/pageStyleV2.dart';
import '../components/vidButtons.dart';
import '../controllers/vrsCommands.dart';
import '../home/home_page.dart';
import 'package:vmba/components/showDialog.dart';

import '../payment/choosePaymentMethod.dart';
import '../utilities/widgets/CustomPageRoute.dart';
import '../v3pages/controls/V3Constants.dart';
import 'contactListPage.dart';


class PassengerDetailsWidget extends StatefulWidget {
  PassengerDetailsWidget({/*Key key= const Key("paxdetailswid_key"),*/ required this.newBooking, this.pnrModel}) /*: super(key: key)*/;
  final NewBooking newBooking;
  final PnrModel? pnrModel;

  _PassengerDetailsWidgetState createState() => _PassengerDetailsWidgetState();
}

class _PassengerDetailsWidgetState extends State<PassengerDetailsWidget> {
  List<PassengerDetail> _passengerDetails = [];
  // List<PassengerDetail>();
  //GlobalKey<ScaffoldState> _key = GlobalKey();
  final formKey = new GlobalKey<FormState>();
  bool allPaxDetailsCompleted = false;
  bool preLoadDetails = false;
  bool backPressed = false;

  //UserProfileRecord userProfileRecord;
  PassengerDetail? passengerDetailRecord;

  @override
  initState() {
    super.initState();
    // logit('i paxDet');
    if( gblCurPage != 'CHOOSEFLIGHT') {
      backPressed = true;
    }
    commonPageInit('PASSENGERDETAILS');
    gblPnrModel = widget.pnrModel;
    gblNewBooking = widget.newBooking;

    for (var i = 0;
        i <= widget.newBooking.passengers.totalPassengers() - 1;
        i++) {
      var pax = new PassengerDetail();
      if(i==0) {
        if(gblPassengerDetail != null && gblPassengerDetail!.adsNumber != null &&
            gblPassengerDetail!.adsNumber.isNotEmpty && gblPassengerDetail!.adsPin != null &&
            gblPassengerDetail!.adsPin.isNotEmpty ) {
          pax.adsNumber = gblPassengerDetail!.adsNumber;
          pax.adsPin = gblPassengerDetail!.adsPin;
        }
      }
      _passengerDetails.add(pax);
    }

    //.then((result) result == true ? loadProfileIntoPaxDetails: {});

    if(isUserProfileComplete()) {
      // logit('i paxDet 1');
      if( loadProfileIntoPaxDetails()) {
        showContinueButton();
      }
    } else {
      // logit('i paxDet 2');
      Repository.get()
          .getNamedUserProfile('PAX1')
          .then((profile) {
        try {
          if( profile == null || profile.name == 'Error' ) {
            print('profile null ');
            return;
          }
          Map<String, dynamic> map = json.decode(
              profile.value.toString().replaceAll(
                  "'", '"')); // .replaceAll(',}', '}')
          passengerDetailRecord = PassengerDetail.fromJson(map);
          if(  passengerDetailRecord!.fqtv != null &&  passengerDetailRecord!.fqtv.isNotEmpty ) {
            gblFqtvNumber = passengerDetailRecord!.fqtv;
          }

          if (gblPassengerDetail != null &&
              gblPassengerDetail!.adsNumber != null &&
              gblPassengerDetail!.adsNumber.isNotEmpty &&
              gblPassengerDetail!.adsPin != null &&
              gblPassengerDetail!.adsPin.isNotEmpty) {
            passengerDetailRecord!.adsNumber = gblPassengerDetail!.adsNumber;
            passengerDetailRecord!.adsPin = gblPassengerDetail!.adsPin;
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
    int uncompletedItems = 0;
    gblWarning = '';

    int index =1;
    _passengerDetails.forEach((pax){
        ErrorParams errorParams = pax.isComplete(index); // int.parse(pax.paxNumber)
        index++;
        if( errorParams.isError){
          uncompletedItems++;
        }
    });

/*
    uncompletedItems = _passengerDetails
        .where((pax) => !pax.isComplete(int.parse(pax.paxNumber))
    )
        .length;
*/



    if (uncompletedItems == 0) {
      setState(() {
        allPaxDetailsCompleted = true;
      });
    } else {
      allPaxDetailsCompleted = false;
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
      if (passengerDetailRecord!.title != null && passengerDetailRecord!.title.length > 0) {
        _passengerDetails[paxNo].title = passengerDetailRecord!.title;
      } else {
        gotAllDetails = false;
      }

      if (passengerDetailRecord!.firstName != null && passengerDetailRecord!.firstName.length > 0) {
        _passengerDetails[paxNo].firstName = passengerDetailRecord!.firstName;
      } else {
        gotAllDetails = false;
      }

    if (passengerDetailRecord!.middleName != null && passengerDetailRecord!.middleName.length > 0) {
      _passengerDetails[paxNo].middleName = passengerDetailRecord!.middleName;
    }

    if (passengerDetailRecord!.lastName != null && passengerDetailRecord!.lastName != 'null' && passengerDetailRecord!.lastName.length > 0) {
        _passengerDetails[paxNo].lastName = passengerDetailRecord!.lastName;
    } else {
      gotAllDetails = false;
      }

      if (passengerDetailRecord!.fqtv != null &&  passengerDetailRecord!.fqtv != 'null' && passengerDetailRecord!.fqtv.length > 0 ) {
        _passengerDetails[paxNo].fqtv = passengerDetailRecord!.fqtv;
      }

      if (passengerDetailRecord!.adsNumber != null && passengerDetailRecord!.adsNumber != 'null' && passengerDetailRecord!.adsNumber.length > 0) {
        _passengerDetails[paxNo].adsNumber = passengerDetailRecord!.adsNumber;
      }

      if (passengerDetailRecord!.adsPin != null && passengerDetailRecord!.adsPin != 'null' && passengerDetailRecord!.adsPin.length > 0) {
        _passengerDetails[paxNo].adsPin =passengerDetailRecord!.adsPin;
      }

      if (passengerDetailRecord!.adsPin != null && passengerDetailRecord!.adsPin != 'null' && passengerDetailRecord!.adsPin.length > 0) {
        _passengerDetails[paxNo].adsPin =passengerDetailRecord!.adsPin;
      }
    if (passengerDetailRecord!.email != null && passengerDetailRecord!.email != 'null' && passengerDetailRecord!.email.length > 0) {
      _passengerDetails[paxNo].email =passengerDetailRecord!.email;
    } else {
      gotAllDetails = false;
    }

    if (passengerDetailRecord!.phonenumber != null && passengerDetailRecord!.phonenumber != 'null' && passengerDetailRecord!.phonenumber.length > 0) {
      _passengerDetails[paxNo].phonenumber =passengerDetailRecord!.phonenumber;
    } else {
      gotAllDetails = false;
    }

    if (passengerDetailRecord!.disabilityID != null && passengerDetailRecord!.disabilityID != 'null' && passengerDetailRecord!.disabilityID.length > 0) {
      _passengerDetails[paxNo].disabilityID =passengerDetailRecord!.disabilityID;
    }
    if (passengerDetailRecord!.seniorID != null && passengerDetailRecord!.seniorID != 'null' && passengerDetailRecord!.seniorID.length > 0) {
      _passengerDetails[paxNo].seniorID =passengerDetailRecord!.seniorID;
    }
    if (passengerDetailRecord!.country != null && passengerDetailRecord!.country != 'null' && passengerDetailRecord!.country.length > 0) {
      _passengerDetails[paxNo].country =passengerDetailRecord!.country;
    }

    if( gblSettings.wantApis ) {
      if( gblSettings.wantRedressNo) {
        if (passengerDetailRecord!.redressNo != null &&
            passengerDetailRecord!.redressNo.length > 0) {
          _passengerDetails[paxNo].redressNo = passengerDetailRecord!.redressNo;
        } else {
          gotAllDetails = false;
        }
      }

      if (passengerDetailRecord!.knowTravellerNo != null &&
          passengerDetailRecord!.knowTravellerNo.length > 0) {
        _passengerDetails[paxNo].knowTravellerNo =
            passengerDetailRecord!.knowTravellerNo;
      } else {
        //gotAllDetails = false;
      }

      }
    if (gblSettings.wantGender) {
      if (passengerDetailRecord!.gender != null &&
          passengerDetailRecord!.gender.length > 0) {
        _passengerDetails[paxNo].gender = passengerDetailRecord!.gender;
      } else {
        gotAllDetails = false;
      }
    }
    if( gblSettings.wantCountry){
      if( passengerDetailRecord!.country != null && passengerDetailRecord!.country.length > 0) {
        _passengerDetails[paxNo].country =  passengerDetailRecord!.country;
      } else {
        gotAllDetails = false;
      }
    }
    if( gblSettings.wantWeight){
      if( passengerDetailRecord!.weight != null && passengerDetailRecord!.weight.length > 0) {
        _passengerDetails[paxNo].weight =  passengerDetailRecord!.weight;
      } else {
        gotAllDetails = false;
      }

    }


    if( gblSettings.passengerTypes.wantAdultDOB) {
      if (passengerDetailRecord!.dateOfBirth != null) {
        _passengerDetails[paxNo].dateOfBirth =
            passengerDetailRecord!.dateOfBirth;
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
    if(passengerDetailRecord!.firstName != null && (passengerDetailRecord!.firstName.length == 0) ||
        (passengerDetailRecord!.firstName == '')) {
      return false;
    }

    if (passengerDetailRecord!.lastName != null && (passengerDetailRecord!.lastName.length == 0) ||
        (passengerDetailRecord!.lastName  == '')) {
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    //logit('b paxDet');
    //logit('pd');
    //Show dialog
    //print('build');
    Widget? floatBtn ;
    if (allPaxDetailsCompleted) {
      floatBtn = vidWideActionButton(context, 'CONTINUE', _onContinuePressed, offset: 35);
    }

 /*   return WillPopScope(
        onWillPop: _onWillPop,*/
    return
      CustomWillPopScope(
          action: () {

            print('pop');
            if( gblSettings.canGoBackFromPaxPage) {
              Navigator.pop(context);
              setState(() {
                //product.is_favorite = isFavorite;
              });
            } else {
              onWillPop(context);
            }
          },
          onWillPop: true,
        child: Scaffold(
      //key: _key,
      appBar: appBar(context, 'Passengers Details', PageEnum.passengerDetails,'PAXDETAILS',
          curStep: 4,
          newBooking: widget.newBooking,
          imageName:  gblSettings.wantPageImages ? 'paxDetails': '' ),
//      extendBodyBehindAppBar: gblSettings.wantCityImages,
      endDrawer: DrawerMenu(),
          bottomNavigationBar: getBottomNav(context, 'PAXDETAILS'),
      body: getSummaryBody(context, widget.newBooking,  _body, statusGlobalKeyPax),
      floatingActionButton: floatBtn,
    ))  ;
  }
    Future<bool> _onWillPop() async {
      return onWillPop(context);
    }

  Widget _body(NewBooking newBooking){
    if( gblError != '') {

      return displayMessage(context,'Booking Error', gblError );
    }
      return new Form(
        key: formKey,
        child: new SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Column(
              children: renderPax(newBooking.passengers),
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

    paxWidgets.add(Padding(
      padding: new EdgeInsets.only(top: 60.0),
    ));

    // test button
    if( gblIsLive == false && pax.totalPassengers() > 1 ){
      paxWidgets.add(vidDemoButton((context), 'Populate with test PAX', (p0) {
        _populatePax();
      }));
    }

    //print('end renderPax');
    return paxWidgets;
  }
  void _populatePax() {
    int index =0;
    List<String> firstNames = ['Alexander', 'Briony', 'Cassandra', 'Dan',   'Ed','Frederik', 'George', 'Harry', 'Ingrid', 'Jess','Kerry'];
    List<String> titles =     ['Mr',        'Mrs',    'Mrs',      'Mr',   'Mr', 'Mr',       'Mr',     'Mrs','Mr','Mrs','Mrs','Mrs','Mr'];
    List <String> genderList = ['Male',     'Female', 'Female',   'Male', 'Male','Male',    'Male',    'Female','Male','Female','Female','Female','Male',];
    List <String> countryList = ['United Kingdom', 'United Kingdom', 'United Kingdom','United Kingdom', 'United Kingdom','United Kingdom', 'United Kingdom', 'United Kingdom','United Kingdom','United Kingdom','United Kingdom','United Kingdom','United Kingdom',];
    String seedName = 'TEST';

    _passengerDetails.forEach((pax) {
      if(pax.lastName == '' ){
        pax.lastName = seedName;
        pax.title = titles[index];
        pax.firstName = firstNames[index];
        pax.gender = genderList[index];
        pax.country = countryList[index];
        pax.phonenumber = '052525252525';
        pax.email = 'test@test.com';
        // DOB ?

      } else if (index == 0){
        // use surname as seed
        seedName = pax.lastName;
      }
     index++;
    });
    //allPaxDetailsCompleted = true;
    showContinueButton();
    setState(() {

    });
  }

  Widget paxTypeEntry(PaxType paxType, int count, int paxNo){
    String _passenger = translate('Passengers');
    List<Widget> list = [];

    if (count == 1) {
      _passenger = translate('Passenger');
    }
    String pType = translate(capitalize(paxType.toString().split('.')[1]));

    for (var c = 1; c < count + 1; c++) {
      list.add(renderFieldsV2(paxNo += 1, PaxType.adult));
    }

    return v2BorderBox(context,   '$pType $_passenger',
        Column(children: list), titleText: true);

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
  _onContinuePressed(BuildContext context, dynamic p) {
    if( !gblActionBtnDisabled && !gblNoNetwork) {
      gblPaymentMsg = '';
      gblActionBtnDisabled = true;
      setState(() {

      });
      validateAndSubmit();
    }
  }
  Widget renderFieldsV2(int paxNo, PaxType paxType) {
    //print('renderFieldsV2');

    bool isLeadPassenger = paxNo == 1 ? true : false;
    _passengerDetails[paxNo - 1].paxType = paxType;
    _passengerDetails[paxNo - 1].paxNumber = paxNo.toString();
    if (_passengerDetails[paxNo - 1].firstName != '' && _passengerDetails[paxNo - 1].firstName != null) {
      // validate this pax
      gblWarning = '';
      ErrorParams errorParams = _passengerDetails[paxNo - 1].isComplete(paxNo);

      return InkWell(
          onTap: (){
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
          },
          child: Column(
          children: [
            Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          //Wrap( children:[
          Text(
              '${_passengerDetails[paxNo - 1].title} ${_passengerDetails[paxNo - 1].firstName} ${_passengerDetails[paxNo - 1].lastName}',
                maxLines: 2,
                softWrap:  true ,
              ),
                    //]                ),
          IconButton(
            onPressed: () {
            //  if (gblSettings.wantNewEditPax) {
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
              /*} else {
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

              }*/
            },
            icon: Icon(Icons.edit, color: wantPageV2() ? gblSystemColors.primaryHeaderColor : null ,),
            iconSize: 20,
          )
        ],
        ),
        errorParams.isError ? Align(alignment:  Alignment.centerLeft , child:  Text( errorParams.msg, style: TextStyle(color: Colors.red)),) : Container() ,
        ])
      );

    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(translate('Add new') + ' ${paxType.toString().split('.')[1]} ' + translate('passenger')),
          (gblSettings.wantAddContact && gblContacts != null ) ?
          IconButton(
              onPressed: () {
                  Navigator.push(
                      context,
                      SlideTopRoute(
                          page: ContactListPageWidget()))
                      .then((paxIndex) {
                        // pax has been selected
                        _passengerDetails[paxNo - 1].title = gblContacts!.contacts![paxIndex].title;
                        _passengerDetails[paxNo - 1].firstName = gblContacts!.contacts![paxIndex].firstname;
                        _passengerDetails[paxNo - 1].lastName = gblContacts!.contacts![paxIndex].lastname;
                        showContinueButton();
                          setState(() {

                          });
                  });
              },
              icon: Icon(Icons.person_add_alt,color: wantPageV2() ? gblSystemColors.primaryHeaderColor : null ),
              iconSize: 20)
              : Container(),
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
                        if(passengerDetails==null ) passengerDetails=PaymentDetails();
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
              icon: Icon(Icons.add_circle,color: wantPageV2() ? gblSystemColors.primaryHeaderColor : null ),
              iconSize: 20)
        ],
      );
    }
    //print('end renderFieldsV2');
  }

  void validateAndSubmit() async {
    try {
      setError('');

      if (widget.newBooking.ads.isAdsBooking()) {
        widget.newBooking.ads.number = _passengerDetails[0].adsNumber;
        widget.newBooking.ads.pin = _passengerDetails[0].adsPin;
      }
      widget.newBooking.passengerDetails = _passengerDetails;

      hasDataConnection().then((result) async {
        if (result == true) {
            if( gblNewBooking == null ){
              // booking failed
              showVidDialog(context, 'Error', 'Booking failed', onComplete:()
              {
                navToFlightSearchPage(context);
              });
            } else if( gblSettings.wantNewSeats) {
              gblError = '';
              PnrModel pnrModel = PnrModel();
              gblPnrModel = await makeBooking(widget.newBooking, pnrModel).catchError((e) {
                logit('book error ${e.toString()}');
              });
              if(gblPnrModel == null ) {
                String errMsg = 'Booking failed';
                if( gblError != ''){
                  errMsg += '\n\n' + gblError;
                }
                showVidDialog(context, 'Error', errMsg, onComplete:()
                {
                  gblError = '';
                  Navigator.of(context).pop();
                  //navToFlightSearchPage(context);
                });
              } else {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            SeatsAndOptionsPageWidget(
                                newBooking: gblNewBooking!)));
              }
            } else if( gblSettings.wantDangerousGoods == true )
            {

              if( passengerDetailRecord ==  null ){
                logit('passengerDetailRecord is null ');
                passengerDetailRecord = PassengerDetail();
              } else {
                logit('passengerDetailRecord has value');
              }

              Navigator.push(
                  context,
                  SlideTopRoute(
                      page: DangerousGoodsWidget( preLoadDetails: preLoadDetails, newBooking: widget.newBooking, passengerDetailRecord: passengerDetailRecord, ))
              ).then((passengerDetails) {
                logit('return from DG');
              });
            }
            else {

              setError( '');
              PnrModel pnrModel = PnrModel();
              gblPnrModel = await makeBooking(widget.newBooking, pnrModel).catchError((e) {
              });

              if( gblSettings.wantProducts) {
                if( gblError == '') {
                  refreshStatusBar();
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              SeatsAndOptionsPageWidget(
                                  newBooking: this.widget.newBooking)));
                } else {
                  setState(() {
                    gblActionBtnDisabled = false;
                  });
                }
              } else {
                if( passengerDetailRecord ==  null ){
                  logit('passengerDetailRecord is null ');
                  passengerDetailRecord = PassengerDetail();
                } else {
                  logit('passengerDetailRecord has value');
                }
                if( gblPnrModel != null ) {
                  var _error = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              ChoosePaymenMethodWidget(
                                //SelectPaymentProviderWidget()
                                newBooking: widget.newBooking,
                                pnrModel: gblPnrModel as PnrModel,
                                isMmb: false,)
                      )
                  );
                }
                displayError(gblError);
                gblActionBtnDisabled = false;
              }
            }

        } else {
          //showSnackBar('Please, check your internet connection');
          gblActionBtnDisabled = false;
          //noInternetSnackBar(context);
        }
      });
    } catch (e) {
      gblActionBtnDisabled = false;
      print('Error: $e');
    }
  }

  void displayError(String error) {
    {
      // flutter defined function
      if (error != null) {
        logit('displayError $error');

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
                    gblError = '';
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
