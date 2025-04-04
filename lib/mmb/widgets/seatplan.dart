import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:vmba/components/showDialog.dart';
import 'package:vmba/data/models/models.dart';
import 'package:vmba/data/models/pax.dart';
import 'package:vmba/data/models/pnr.dart';
import 'package:vmba/data/models/seatplan.dart';
import 'package:vmba/data/models/vrsRequest.dart';
import 'package:vmba/data/repository.dart';
import 'package:vmba/Seats/flights.dart';
import 'package:vmba/Seats/plan.dart';
import 'package:vmba/Seats/seat.dart';
import 'dart:async';
import 'dart:convert';
import 'package:vmba/mmb/widgets/seatPlanPassengers.dart';
import 'package:vmba/payment/choosePaymentMethod.dart';
import 'package:vmba/utilities/helper.dart';
import 'package:vmba/utilities/widgets/snackbarWidget.dart';
import 'package:vmba/data/globals.dart';
import 'package:vmba/components/trText.dart';
import 'package:vmba/v3pages/controls/V3Constants.dart';
import 'package:vmba/v3pages/v3Theme.dart';

import '../../calendar/bookingFunctions.dart';
import '../../components/vidButtons.dart';
import '../../controllers/vrsCommands.dart';
import '../../Managers/commsManager.dart';
import '../../data/models/dialog.dart';
import '../../dialogs/smartDialog.dart';
import '../../menu/menu.dart';
import '../../utilities/widgets/CustomPageRoute.dart';
import '../../utilities/widgets/colourHelper.dart';
import '../../v3pages/controls/V3AppBar.dart';
import '../../v3pages/fields/typography.dart';

//enum SeatType { regular, emergency }
enum SeatType{
  selected,
  emergency,
  available,
  unavailable,
  availableRestricted,
  occupied,
  blank,
}

double cellSize = 36.0; //28.0;
double cellFontSize = 13.0;
double cellPadding = 5.0;
double aisleCellSize = 20.0;

class SeatPlanWidget extends StatefulWidget {
  SeatPlanWidget(
      {Key key= const Key("seatplanwi_key"),
      this.paxlist ,
      this.seatplan ='',
      this.rloc ='',
      this.journeyNo = '0',
      this.cabin = '',
        this.flt='',
      this.selectedpaxNo = 1,
      this.isMmb = false,
      this.ischeckinOpen = false})
      : super(key: key);

  final List<Pax>? paxlist;
  final String seatplan;
  final String cabin;
  final String flt;
  final String rloc;
  final String journeyNo;
  final int selectedpaxNo;
  final bool isMmb;
  final bool ischeckinOpen;
  bool pnrLoaded = false;

  _SeatPlanWidgetState createState() => _SeatPlanWidgetState();
}

class _SeatPlanWidgetState extends State<SeatPlanWidget> {
  GlobalKey<ScaffoldState> _key = GlobalKey();
  bool _loadingInProgress=false;
  String _displayProcessingText = '';
  Seatplan? objSeatplan;
  //List<Pax>? paxlist;
  PaxList? paxlist;
  bool showkey = true;
  String seatplan = '';
  //bool _noInternet = false;
  bool _noSeats = false;
  Session? session;
  ExpansionTileController  _controller = new ExpansionTileController();

  @override
  void initState() {
    super.initState();
    gblPaymentMsg = '';
    setError( '');


    //_noInternet = false;
    _noSeats = false;
    _loadingInProgress = true;
    _displayProcessingText = translate('Loading seat plan...');
    seatplan = widget.seatplan;
    int journeyNo = 0;
    if( widget.journeyNo != '') {
      journeyNo = int.parse(widget.journeyNo);
    }
    gblCurJourney = journeyNo;
    seatplan = 'ls';
    seatplan += gblPnrModel!.pNR.itinerary.itin[journeyNo].airID;
    seatplan += gblPnrModel!.pNR.itinerary.itin[journeyNo].fltNo;
    seatplan += '/' + DateFormat('ddMMM').format(DateTime.parse(gblPnrModel!.pNR.itinerary.itin[journeyNo].depDate + ' ' +
            gblPnrModel!.pNR.itinerary.itin[journeyNo].depTime));
    seatplan +=  gblPnrModel!.pNR.itinerary.itin[journeyNo].depart + gblPnrModel!.pNR.itinerary.itin[journeyNo].arrive;
    seatplan += '[CB=' + gblPnrModel!.pNR.itinerary.itin[journeyNo].classBand;
    seatplan += '][CUR=';
    seatplan += gblPnrModel!.pNR.fareQuote.fQItin[0].cur;
    seatplan += '][MMB=True]~x';

    _loadData(seatplan);
    paxlist = new PaxList();
    gblSelectedSeats = [];
    if( widget.paxlist == null ) {
      List<Pax> paxlists = getPaxlist(gblPnrModel as PnrModel, journeyNo);
      paxlist!.init(paxlists );
    } else {
      paxlist!.init(widget.paxlist as List<Pax>);
    }
    session = Session('', '', '');

    paxlist!.list!.forEach((p) => p.selected = false);
    if (widget.selectedpaxNo == null) {
      paxlist!.list!.firstWhere((p) => p.id == 1).selected = true;
    } else {
      paxlist!.list!.firstWhere((p) => p.id == widget.selectedpaxNo).selected = true;
    }

    showkey = true;
  }

  Widget getRoute(int journeyNo){

    DateTime deps = DateTime.parse(gblPnrModel!.pNR.itinerary.itin[journeyNo].depDate + ' ' + gblPnrModel!.pNR.itinerary.itin[journeyNo].depTime);

    String text =  cityCodetoAirport(gblPnrModel!.pNR.itinerary.itin[journeyNo].depart) + '  '
        + cityCodetoAirport(gblPnrModel!.pNR.itinerary.itin[journeyNo].arrive) +
         ' ' +  DateFormat('dd MMM').format(deps) ;

    if( gblSecurityLevel >= 100  && gblSeatplan != null ) {
      text += ' [' + gblSeatplan!.seats.seatsFlt.sRef + ']';
    }
      return Row( mainAxisAlignment: MainAxisAlignment.center,
          children: [
            VTitleText(text ,
            )
          ]
      );
    }

  void _dataLoaded() {
    setState(() {
      _loadingInProgress = false;
    });
  }

  void _dataLoadedFailed(errorMsg) {
    _showError(errorMsg);
    setState(() {
      _loadingInProgress = false;
    });
    showVidDialog(context, 'Error booking seats', errorMsg, onComplete: () {
      _loadingInProgress = false;
      Navigator.of(context).pop();
    });
    //showSnackBar(errorMsg);
  }

  showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(snackbar(message));
    //final _snackbar = snackbar(message);
    //_key.currentState.showSnackBar(_snackbar);
  }


  Future _sendVRSCommand(String msg) async {
    try {
      if(msg.startsWith('{' )){
        Map map = json.decode(msg);
        msg = map['Commands'];
      }
      String data = await runVrsCommand(msg);
      return data;
    } catch(e){
      return 'error ${e.toString()}';
    }

  }


  String _getSeatPlanCommand( int journeyNo) {
    if( journeyNo <= gblPnrModel!.pNR.itinerary.itin.length) {
      Itin itin = gblPnrModel!.pNR.itinerary.itin[journeyNo];
      String cur = gblPnrModel!.pNR.fareQuote.fQItin[0].cur;

      //  lsLM0085/25SepABZBHD[CB=FLY][CUR=GBP][MMB=True]~x
      String depDate = '${new DateFormat('ddMMM').format(DateTime.parse(itin.depDate + ' ' + itin.depTime))}';

      String cmd = 'ls${itin.airID}${itin.fltNo}/${depDate}${itin.depart}${itin.arrive}[CB=${itin.classBand}][CUR=$cur][MMB=True]~x';

      return cmd;
    }
    return '';
  }


  //  example lsLM0085/25SepABZBHD[CB=FLY][CUR=GBP][MMB=True]~x
  Future _loadData(String seatPlanCmd) async {
    logit('load seat plan $seatPlanCmd');
    setState(() {

    });
    await Repository.get().getSeatPlan(seatPlanCmd).then((rs) async {
      if (rs.isOk()) {
        objSeatplan = rs.body;

        gblLoadSeatState = VrsCmdState.none;
        if( objSeatplan != null ) {
          objSeatplan!.simplifyPlan();
          gblSeatplan = objSeatplan;
          gblSeatPlanDef = objSeatplan!.getPlanDataTable();
        }

          if (!objSeatplan!.hasSeatsAvailable() && objSeatplan!.hasBlockedSeats()) {
            setState(() {
              _loadingInProgress = false;
              _noSeats = true;
            });
          } else {
            if( !gblSettings.wantNewSeats) {
              _dataLoaded();
            }
          }

          // check for json definition file
          if( gblSettings.wantNewSeats){
            if(gblSeatplan != null && gblSeatplan!.seats.seatsFlt != null && gblSeatplan!.seats.seatsFlt.sRef != '' ) {
              try {
                final jsonString = await http.get(Uri.parse('${gblSettings.gblServerFiles}/seatplans/${gblSeatplan!.seats.seatsFlt.sRef}.json'), headers: {HttpHeaders.contentTypeHeader: "application/json",
                  HttpHeaders.acceptEncodingHeader: 'gzip,deflate,br'}); // ,
                String data = utf8.decode(jsonString.bodyBytes);
                if( data.startsWith('{')) {
                  final Map<String, dynamic> map = json.decode(data);
                  SeatPlanConfig seatPlanConfig = SeatPlanConfig.fromJson(map);
                  gblSeatPlanConfig = seatPlanConfig;
                  logit('load seatplanConfig complete [${gblSeatplan!.seats.seatsFlt.sRef}]' );
                  _dataLoaded();
                } else {
                  logit('load seatplanConfig json INVALID data [${gblSeatplan!.seats.seatsFlt.sRef}]' );
                  _dataLoaded();
                }
              } catch(e) {
                logit('load seatplanConfig json ' + e.toString());
                _dataLoaded();
              }
            } else {
              _dataLoaded();
            }
          }


      } else {
        if( rs.error.contains('ANOTHER CARRIER' )){
          showVidDialog(context, 'Error', 'No seat booking available as flight operated by other carrier', onComplete: (){
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        ChoosePaymenMethodWidget(
                          //SelectPaymentProviderWidget()
                          newBooking: gblNewBooking,
                          pnrModel: gblPnrModel as PnrModel,
                          isMmb: false,)
                )
            );
          });
        } else {
          setError(rs.error);
          setState(() {
            _loadingInProgress = false;
            //_noInternet = true;
          });
        }
      }
    });
  }

  void _handleScrollChanged(bool hide) {
    setState(() {
      showkey = hide;
    });
  }

  void _handleSeatChanged(List<Pax> paxValue) {
    print('_handleSeatChanged');
    setState(() {
      paxlist = new PaxList();
      paxlist!.init(paxValue);
    });
  }

  Future<bool> _handleBookSeats(List<Pax> paxValue, {bool gotoPayment = true, int? journeyNo }) async {
   // _bookSeats();
    setError( '');
    // check is any seats selects
    int seatsSelected = 0;
    if( journeyNo == null ) journeyNo = gblCurJourney;
    paxlist!.list!.forEach((seat) {
      if(seat.seat != '' && seat.seat != seat.savedSeat){
        seatsSelected++;
      }
    });
    if( seatsSelected ==  0){
      showVidDialog(context, 'Error', 'Select Seats First');

    } else {
      String result = await smartBookSeats(gotoPayment,  journeyNo  as int );
      if( result == 'OK') {
        logit('done book seats');
        setState(() {
          paxlist = new PaxList();
          paxlist!.init(paxValue);
          _loadingInProgress = true;
          _displayProcessingText = translate('Booking your seat selection...');
        });
        return true;
      }
    }
    return false;
  }

  Future<String> smartBookSeats(bool gotoPayment , int journeyNo) async {
    gblPayAction = 'BOOKSEAT';
    SeatRequest seat = new SeatRequest();
    gblBookSeatCmd = '';
    seat.pnrLoaded = widget.pnrLoaded;
    widget.pnrLoaded = true;
    seat.paxlist = paxlist!.list;
    seat.rloc = widget.rloc;
    seat.journeyNo = journeyNo ?? int.parse(widget.journeyNo);
    if( widget.isMmb && widget.ischeckinOpen) {
      seat.webCheckinNoSeatCharge = gblSettings.webCheckinNoSeatCharge;
    } else {
      seat.webCheckinNoSeatCharge = false;
    }
    logit('SA book seats j=$journeyNo');

    String data =  json.encode(seat);

    try{
      String reply = await callSmartApi('BOOKSEAT', data);
      Map<String, dynamic> map = json.decode(reply);
      SeatReply seatRs = new SeatReply.fromJson(map);
      double outstanding = double.parse(seatRs.outstandingAmount);
      gblBookSeatCmd = seatRs.bookSeatCmd;
      if( !widget.isMmb) {
        String msg = json.encode(RunVRSCommand(session!, "E*R~X"));
        gblBookSeatCmd = '';

        _sendVRSCommand(msg).then(
                (onValue) {
                  //Repository.get().fetchPnr(widget.rloc).then((pnr) {
                  if (onValue.toString().contains('ERROR')) {
                    _dataLoadedFailed(onValue.toString());
                  } else {
                    logit('booked seat for $journeyNo');
                    Map<String, dynamic> map = json.decode(onValue);
                    PnrModel pnrModel = new PnrModel.fromJson(map);
                    gblPnrModel = pnrModel;

                    if( gblSettings.wantSeatsWithProducts == false && gblSettings.wantNewSeats) {
                      // go to payment page
                      if( (gblCurJourney+1) >= gblPnrModel!.pNR.itinerary.itin.length && gotoPayment) {
                        if (gblPnrModel != null) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      ChoosePaymenMethodWidget(
                                        //SelectPaymentProviderWidget()
                                        newBooking: gblNewBooking,
                                        pnrModel: gblPnrModel as PnrModel,
                                        isMmb: false,)
                              )
                          );
                        }
                      }
                    } else {
                      refreshStatusBar();
                      Navigator.pop(context, pnrModel);
                    }
                  }
                }
            );
        return 'OK';
      } else {
        if (outstanding == 0) { // zero outstanding
          String msg = json.encode(RunVRSCommand(session!, "E"));
          _sendVRSCommand(msg).then(
                  (onValue) =>
                  Repository.get().fetchPnr(widget.rloc).then((pnr) {
                    Map<String, dynamic> map = json.decode(pnr!.data);
                    PnrModel pnrModel = new PnrModel.fromJson(map);
                    gblPnrModel = pnrModel;
                    refreshStatusBar();
                    showSnackBar(translate("Seat(s) allocated"));
                    Navigator.pop(context, pnrModel);
                  }));
        } else if (outstanding < 0) { // Minus outstanding
          String msg = json.encode(RunVRSCommand(session!, "EMT*R"));
          gblBookSeatCmd = '';
          _sendVRSCommand(msg).then(
                  (onValue) =>
                  Repository.get().fetchPnr(widget.rloc).then((pnr) {
                    Map<String, dynamic> map = json.decode(pnr!.data);
                    PnrModel pnrModel = new PnrModel.fromJson(map);
                    gblPnrModel = pnrModel;
                    showSnackBar(translate("Seat(s) allocated"));
                    Navigator.pop(context, pnrModel);
                  }));
        } else {
          String msg;
          int noSeats = 0;
         // if (gblSettings.wantNewPayment) {
            // build undo
            noSeats = gblPnrModel!.pNR.seatCount();

            // was E*R,
            msg = json.encode(RunVRSCommand(session!, "*R~x"));
 /*         } else {
            msg = json.encode(RunVRSCommand(session!, "*${widget.rloc}~x"));
          }*/
          _sendVRSCommand(msg).then((pnrJson) {
            pnrJson =
                pnrJson.replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
                    .replaceAll('<string xmlns="http://videcom.com/">', '')
                    .replaceAll('</string>', '');

            Map<String, dynamic> map = json.decode(pnrJson);

            PnrModel pnrModel = new PnrModel.fromJson(map);
            gblPnrModel = pnrModel;
            int newSeatCount = gblPnrModel!.pNR.seatCount();
            gblUndoCommand ='';
            for( int i = newSeatCount; i > noSeats; i--){
              if(gblUndoCommand.length > 0 ){
                gblUndoCommand += '^';
              }
              gblUndoCommand += '4X$i';
            }
            if(gblUndoCommand.length > 0 ){
              gblUndoCommand += '^E*R';
            }
            refreshStatusBar();
            if( gotoPayment) {
              _navigate(context, pnrModel, session!);
            }
            _resetloadingProgress();
          });
        }
      }
      return 'OK';
    } catch(e) {
      print(e.toString());
      _dataLoadedFailed(e);
      return e.toString();
    }

  }

  _navigate(BuildContext context, PnrModel pnrModel, Session session) async {
    // Navigator.push returns a Future that completes after calling
    // Navigator.pop on the Selection Screen.
    gblPaymentMsg = '';
    final result = await Navigator.push(
      context,
      // Create the SelectionScreen in the next step.
      //MaterialPageRoute(
      CustomPageRoute(
          builder: (context) => ChoosePaymenMethodWidget(
              pnrModel: pnrModel, isMmb: true, session: session, mmbAction: 'SEAT',)),
    );
    if (result == true) {
      _cancelSeatSelection();
      setState(() {
        _loadingInProgress = true;
        _displayProcessingText = 'Cancelling your seat selection...';
      });
    }
  }

  _cancelSeatSelection() {
    String msg = json.encode(RunVRSCommand(session!, "I"));
    _sendVRSCommand(msg).then((_) {
      _resetloadingProgress();
    });
  }

  _resetloadingProgress() {
    setState(() {
      _loadingInProgress = false;
    });
  }

  _showError(String err) {
    logit(err);
    setState(() {
      _loadingInProgress = false;
    });
  }

  retryLoad() {
    setState(() {
      _loadingInProgress = true;
      //_noInternet = false;
      _loadData(widget.seatplan);
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        key: _key,
        endDrawer: (gblSettings.wantNewSeats && !widget.isMmb) ? DrawerMenu() : null,
        appBar: new V3AppBar(
          automaticallyImplyLeading: false,
          PageEnum.chooseSeat,
          actions: (gblSettings.wantNewSeats && !widget.isMmb) ? null : <Widget>[
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                Navigator.pop(context, gblPnrModel);
              }
            )
          ],
          toolbarHeight: 90,
          iconTheme: IconThemeData(
              color: gblSystemColors.headerTextColor),
          title: getTitle(),
        ),
        //endDrawer: DrawerMenu(),

        body: body(),
        floatingActionButton: getActionButton()
    );
  }

  Widget? getActionButton() {
  if(_loadingInProgress || gblNoNetwork || _noSeats) return null;


    if(gblSettings.wantNewSeats ) {
      String caption = 'Save seats and pay';
      if( (gblCurJourney+1) < gblPnrModel!.pNR.itinerary.itin.length){
        caption = 'Save seats and next flight';
      }

      return vidWideActionButton(context, caption, (context, d) async {
        if (!gblActionBtnDisabled) {
          gblActionBtnDisabled = true;
          if ((gblCurJourney + 1) < gblPnrModel!.pNR.itinerary.itin.length) {
            bool result = await _handleBookSeats(paxlist!.list!, gotoPayment: false, journeyNo: gblCurJourney);
            if( result == true) {
              // go to next flight
              gblCurJourney += 1;
              List<Pax> plist = gblPnrModel!.getBookedPaxList(gblCurJourney);
              paxlist!.init(plist);
              _loadData(_getSeatPlanCommand(gblCurJourney));
            }
          } else {
            bool result = await _handleBookSeats( paxlist!.list!, gotoPayment: true, journeyNo: gblCurJourney);
          }
      }},  icon: Icons.check,
          offset: 35.0,
          disabled: paxlist!.allocatedCount() == 0 || gblActionBtnDisabled, );
    }
    return
         Padding(
        padding: EdgeInsets.only(left: 35.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new FloatingActionButton.extended(
                elevation: 0.0,
                isExtended: true,
                label: TrText(
                  gblSettings.wantNewSeats ? 'Save seats' : 'SELECT SEAT',
                  style: TextStyle(
                      color: gblSystemColors.primaryButtonTextColor),
                ),
                icon: gblSettings.wantNewSeats ? null : Icon(
                  Icons.check,
                  color: gblSystemColors
                      .primaryButtonTextColor,
                ),
                backgroundColor: actionButtonColor(),
                onPressed: () {
                  if( gblNoNetwork == false) {
                    _handleBookSeats(paxlist!.list!);
                  }
                }),
          ],
        ));
  }


Widget getTitle() {
    if( gblSettings.wantNewSeats ) {
      String title1 = translate('Choose a seat');
      if( gblButtonClickParams != null &&  gblButtonClickParams!.action == 'changeseat'){
        title1 = 'Change seat';
      }

      Itin flt =   gblPnrModel!.pNR.itinerary.itin[gblCurJourney];
      String route = '${cityCodetoAirport(flt.depart)} - ${cityCodetoAirport(flt.arrive)}';
      if(paxlist!.list!.length > 1) {
        title1 = translate('Choose seats');
      }

      List<Widget> listNo = [];
      int index = 0;
      gblPnrModel!.pNR.itinerary.itin.forEach((flight){
        listNo.add(fltButton(index, index == gblCurJourney, (jNo){
          // flt button clicked
          if( jNo != gblCurJourney){
            gblCurJourney = jNo;
            List<Pax> plist =  gblPnrModel!.getBookedPaxList(gblCurJourney);
            paxlist!.init(plist);
            _loadData( _getSeatPlanCommand(gblCurJourney));
          }
        }));
       // listNo.add(Padding(padding: EdgeInsets.all(4)));
        index++;
      });


      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          VTitleText(title1, size: TextSize.large,color:gblSystemColors.headerTextColor),
          Row( children: listNo),
        ],
      );

    } else {
      return new TrText('Choose a seat',
          style: TextStyle(
              color:
              gblSystemColors.headerTextColor));
    }
}
Widget fltButton( int journeyNo, bool selected, void Function(int) onClick){
    Color selectedColor = gblSystemColors.primaryHeaderColor;
    if( selectedColor == Colors.white) {
      selectedColor = gblSystemColors.headerTextColor as Color;
    }
    return Padding(padding: EdgeInsets.all(1), child:  SizedBox.fromSize(
      size: Size(40, 40), // button width and height
      child: Container(
        margin: EdgeInsets.fromLTRB(0, 0, 0, 5),
        padding: EdgeInsets.all(0),
        decoration: BoxDecoration(
          color: selected ? selectedColor : Colors.grey,
            border: Border.all(width: 1, color: selected ? Colors.black : Colors.white),
            borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        //borderRadius: BorderRadius.circular(5.0),
          child: InkWell(
            splashColor: Colors.green, // splash color
            onTap: () {
            onClick(journeyNo);
            }, // button pressed
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                RotatedBox(
                quarterTurns: 1,
                child: new Icon(
                  Icons.airplanemode_active,
                  size: 35.0,
                  color: Colors.white,
                )), // icon
                Text((journeyNo +1).toString(), style: TextStyle(color: selected ? Colors.black : Colors.blueGrey, fontWeight: FontWeight.bold, ),textScaler: TextScaler.linear(1.5),), // text
              ],
            ),
        ),
      ),
    ));
}

  Widget body() {
    if (_loadingInProgress) {
      return new Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            new CircularProgressIndicator(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: new Text(_displayProcessingText),
            ),
          ],
        ),
      );
    }
    else if( gblError != '') {
      return new Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
          Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Text(
              gblError,
              textAlign: TextAlign.justify,
            ),
          ),
      )
    ]
    )
    );
    }
    else if (_noSeats) {
      return new Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  'Please report to the airport check-in desk to complete check-in.',
                  textAlign: TextAlign.justify,
                ),
              ),
//1.	Base text: “Seat allocation for certain flights is unavailable online”
//Translation:  “Seat allocation for certain flights is unavailable online. Please report to the airport check-in desk to complete check-in. Your flight is still scheduled to operate.”
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0)),
                  foregroundColor: Colors.black),
              onPressed: () {
                      Navigator.pop(context);
                      },
              child: TrText(
                'OK',
                style: new TextStyle(color: Colors.white),
              ),
            )
          ],
        ),
      );
    } else {
      Itin itin = gblPnrModel!.pNR.itinerary.itin[gblCurJourney];
      DateTime deps = DateTime.parse(itin.depDate + ' ' + itin.depTime);
      Widget fltTitle = V2Heading2Text(translate('Flight') + ' ' + widget.flt+ ' ' +  DateFormat('dd MMM').format(deps) );

      List<Widget> list = [];
      if( gblSettings.wantNewSeats == false) {
        list.add(Padding(padding: EdgeInsets.fromLTRB(15, 10, 15, 0),
            child:             Align(alignment: Alignment.centerLeft,
              child: fltTitle ,
            )));

        list.add(getSeatKey());
        list.add(SeatPlanPassengersWidget(
          paxList: paxlist!.list, segNo: gblCurJourney,
          loadingData: (msg){
            _displayProcessingText = msg;
            _loadingInProgress = true;
            setState(() {
            });
          },
          dataLoaded: () {
            _loadingInProgress = false;
            setState(() {

            });
          },
        ),);
        list.add(Padding(padding: EdgeInsets.only(top: 10.0),),);
        list.add(RenderSeatPlan(
            seatplan: objSeatplan!,
            pax: paxlist!.list!,
            rloc: widget.rloc,
            cabin: widget.cabin,
            onChanged: _handleSeatChanged,
            onScrollCallbackShowKey: _handleScrollChanged,
            displaySeatPrices: true,
            ));
        return Column(
            children: list
        );

    } else {
        list.add(getSeatKey2());
        if( gblSecurityLevel >= 100 ){
          // add debug menu
          String dumpData = gblSeatPlanDef!.dump(false);
          list.add(
            Row(
              children: [
                vidActionButton(context, 'Dump seats', (context, params) {
                DialogDef dialog = new DialogDef(caption: 'Seat dump',
                    actionText: 'OK',
                    action: 'pop');

                dialog.fields.add(
                    new DialogFieldDef(field_type: 'scrolltext', caption: dumpData ));


                gblCurDialog = dialog;
                showSmartDialog(context, null, () {
                  setState(() {});
                });
                })
              ],
            ));
        }

        if( widget.isMmb == false ) {

          list.add(Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                  onPressed: () async {
                    bool bContinue = await confirmDialog(
                        context, 'Are you sure?',
                        "Skipping now means we can't guarantee you'll get your preferred seat later");

                    if (bContinue) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  ChoosePaymenMethodWidget(
                                    //SelectPaymentProviderWidget()
                                    newBooking: gblNewBooking,
                                    pnrModel: gblPnrModel as PnrModel,
                                    isMmb: false,)
                          )
                      );
                    } else {
                      //Navigator.of(context).pop();
                    }
                  },
                  child: Text('Skip', style: TextStyle(
                      decoration: TextDecoration.underline,
                      decorationStyle: TextDecorationStyle.double),))
            ],
          ));
        }
        list.add(getRoute(gblCurJourney));

        // add comment
        if( objSeatplan!.seats.seatsFlt.displayInfo != ''   ) {
          list.add(Padding(padding: EdgeInsets.only(top: 10),
              child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
              children: [Text(objSeatplan!.seats.seatsFlt.displayInfo, style: TextStyle(fontSize: 16),)
          ])));
        }

        list.add(        RenderSeatPlan2(
          seatplan: objSeatplan!,
          pax: paxlist!.list!,
          rloc: widget.rloc,
          cabin: widget.cabin,
          onChanged: _handleSeatChanged,
          onScrollCallbackShowKey: _handleScrollChanged,
          displaySeatPrices: true,
        )
        );
        list.add(Padding(padding: EdgeInsets.all(10)));
        return /*Container(
            child: SingleChildScrollView(
        child:*/
            Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
            children: list
        //)
        );
      }

    }
  }
    /*Widget seat2(String seatNo,  SeatType seatType ) {
      Color? seatClr = Colors.grey;
      Color? seatTxtColor = Colors.black;

      switch ( seatType) {
        case SeatType.availableRestricted:
          seatClr = gblSystemColors.seatPlanColorRestricted;
          if( gblSystemColors.seatPlanTextColorRestricted != null ) seatTxtColor = gblSystemColors.seatPlanTextColorRestricted;
          break;
        case SeatType.selected:
          seatClr = gblSystemColors.seatPlanColorSelected;
          if( gblSystemColors.seatPlanTextColorSelected != null ) seatTxtColor = gblSystemColors.seatPlanTextColorSelected;
          break;
        case SeatType.available:
          seatClr = gblSystemColors.seatPlanColorAvailable;
          if( gblSystemColors.seatPlanTextColorAvailable != null ) seatTxtColor = gblSystemColors.seatPlanTextColorAvailable;
          break;
        case SeatType.occupied:
          seatClr = gblSystemColors.seatPlanColorUnavailable;
          if( gblSystemColors.seatPlanTextColorUnavailable != null ) seatTxtColor = gblSystemColors.seatPlanTextColorUnavailable;
          break;
        case SeatType.emergency:
          seatClr = gblSystemColors.seatPlanColorEmergency;
          if( gblSystemColors.seatPlanTextColorEmergency != null ) seatTxtColor = gblSystemColors.seatPlanTextColorEmergency;
          break;
      }

      Widget body =  VTitleText(seatNo,size:  TextSize.small,color: seatTxtColor);
      if( seatType == SeatType.occupied){
        body = Stack( children: [
          Icon(Icons.person, size: 20,color: Colors.grey.shade100,),
          Positioned(
            left: 0,
              top: 0,
              child: CustomPaint(painter: LinePainter())
          ),
          VTitleText(seatNo,size:  TextSize.small, color: seatTxtColor,),
        ],);
      }

      return Container(
        //color: seatClr,
        padding: EdgeInsets.all(0),
        alignment: Alignment.center,
        height: 30,
        width: 30,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey, width: 1),
          borderRadius: BorderRadius.all(
              Radius.circular(5.0)),
          color: seatClr,
        ),
        child: body,
      );
    }*/

  /*Widget seatRow(String seatNo,  SeatType seatType, String text  ){
    return Padding( padding: EdgeInsets.fromLTRB(10, 5, 20, 5),
      child: Row( children: [ seat2(seatNo, seatType ),
        Padding(padding: EdgeInsets.all(5)),
        VTitleText(text, size: TextSize.small,)]
      )
    );
  }*/

/*
  Widget getSeatKey2() {
    List<Widget> seatList = [];
    seatList.add(seatRow('1X',  SeatType.selected, 'Selected Seat'));

    seatList.add(seatRow('1X',  SeatType.emergency , 'Emergency Seat'));
    seatList.add(seatRow('1X',  SeatType.available, 'Available Seat (suitable for infants)' ));
    seatList.add(seatRow('1X',  SeatType.availableRestricted, 'Available Seat (unsuitable for infants)' ));
    seatList.add(seatRow('1X',  SeatType.occupied, 'Occupied Seat' ));


    return Card(
      margin: EdgeInsets.fromLTRB(10, 15, 10, 20),
      color: Colors.black,
      shadowColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10))
      ),
      child: ClipPath(
        child: Container(
          decoration: BoxDecoration(
            //color: Colors.white,
              //borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          //           height: 100,
          width: double.infinity,
          child:
          Container(
            color: Colors.black,
            child:
          ExpansionTile(
              //backgroundColor: Colors.white,
              iconColor: gblSystemColors.fltText,
              collapsedIconColor: gblSystemColors.fltText,
              controller: _controller,
              onExpansionChanged: (selected) {
                if (selected == true) {
                } else {
                  setState(() {

                  });
                }
              },
              //backgroundColor: Colors.grey.shade200,
              //tilePadding: EdgeInsets.all(0),
              childrenPadding: EdgeInsets.all(0),
//        backgroundColor:  Colors.blue,
              initiallyExpanded: true,
              title: VTitleText('What it all means...', color: Colors.white, translate: true, size: TextSize.large,),
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    //borderRadius: BorderRadius.all(Radius.circular(10)),
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade200, width: 0),
                      left: BorderSide(color: Colors.grey, width: 2),
                      right: BorderSide(color: Colors.grey, width: 2),
                      bottom: BorderSide(color: Colors.grey, width: 2),
                    ),
                    color: Colors.white,
                  ),
                child: Column(children: seatList)
              )],
          ))
        ),
        clipper: ShapeBorderClipper(shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5))),
      ),
    );
  }
*/

  Widget getSeatKey() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      height: showkey ? 75.0 : 0,
      padding:
      EdgeInsets.only(top: 10.0, left: 3.0, right: 3.0, bottom: 10.0),
      child: SingleChildScrollView(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            // selected
            Column(
              children: <Widget>[
                getSeat(null, gblSystemColors.seatPlanColorSelected!),
                Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: TrText("Selected",
                      style: TextStyle(
                        fontSize: cellFontSize,
                      )),
                )
              ],
            ),
            // end selected
            Column(
              children: <Widget>[
                getSeat(null, gblSystemColors.seatPlanColorAvailable!),
                Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: TrText("Available",
                      style: TextStyle(
                        fontSize: cellFontSize,
                      )),
                )
              ],
            ),
            Column(
              children: <Widget>[
                getSeat(null, gblSystemColors.seatPlanColorEmergency!),
                Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: TrText("Emergency",
                      style: TextStyle(
                        fontSize: cellFontSize,
                      )),
                )
              ],
            ),
            Column(
              children: <Widget>[
                getSeat(null, gblSystemColors.seatPlanColorRestricted!),
                Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: TrText("Restricted",
                      style: TextStyle(
                        fontSize: cellFontSize,
                      )),
                )
              ],
            ),
            Column(
              children: <Widget>[
                Container(
                  width: cellSize,
                  height: cellSize,
                  decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      color: gblSystemColors.seatPlanColorUnavailable,
                      borderRadius:
                      new BorderRadius.all(new Radius.circular(5.0))),
                  child: Center(
                      child: Icon(
                        Icons.person,
                        size: cellSize,
                        color: Colors.white,
                      )),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: TrText("Unavailable",
                      style: TextStyle(
                        fontSize: cellFontSize,
                      )),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

class RenderSeatPlan extends StatefulWidget {
  const RenderSeatPlan(
      {Key key= const Key("renderpeatp_key"),
      required this.seatplan,
        required this.pax,
        required this.rloc,
        required this.displaySeatPrices,
        required this.onChanged,
        this.cabin = '',
        required this.onScrollCallbackShowKey})
      : super(key: key);

  final Seatplan seatplan;
  final String cabin;
  final List<Pax> pax;
  final ValueChanged<List<Pax>> onChanged;
  final ValueChanged<bool> onScrollCallbackShowKey;
  final String rloc;
  final bool displaySeatPrices;

  _RenderSeatPlanSeatState createState() => _RenderSeatPlanSeatState();
}

class _RenderSeatPlanSeatState extends State<RenderSeatPlan> {
  List<Pax>? paxlist;
  List<String> selectedSeats = [];
  // List<String>();
  ScrollController? _controller;
  bool showkey = false;

  _scrollListener() {
    if (!showkey &&
        _controller!.position.userScrollDirection.toString() ==
            "ScrollDirection.forward") {
      print('ScrollDirection.up');
      print(_controller!.offset);
      showkey = true;
      widget.onScrollCallbackShowKey(showkey);
    } else if (showkey &&
        _controller!.offset >= 40 &&
        _controller!.position.userScrollDirection.toString() ==
            "ScrollDirection.reverse") {
      print('ScrollDirection.down');
      print(_controller!.offset);
      showkey = false;
      widget.onScrollCallbackShowKey(showkey);
    }
  }

  @override
  initState() {
    super.initState();
    _controller = new ScrollController();
    _controller!.addListener(_scrollListener);
    showkey = true;
    paxlist = widget.pax;
    paxlist!.forEach((f) => selectedSeats.add(f.seat));
  }

  emergencySeatSelection(BuildContext context, String selectedSeat) {
    String acceptTermsText =
        'By selecting this seat you confirm that you are over 16 years old and do not have any physical or vision impairment';
    String notAllowEmergencySeatingText =
        'To select this seat you must be over 16 years old';

    var paxTypesNotAllowed = ['CH', 'IN'];
    Pax selectPax = this.paxlist!.firstWhere((p) => p.selected == true);

    bool isAllowEmergencySeating =
        !paxTypesNotAllowed.contains(selectPax.paxType);

    Widget cancelButton = TextButton(
      child: TrText('Cancel'),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    Widget continueButton = TextButton(
      child: TrText('OK'),
      onPressed: () {
        Navigator.of(context).pop();
        _seatSelected(selectedSeat);
      },
    );

    Widget okButton = TextButton(
      child: TrText('OK'),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    AlertDialog alert = AlertDialog(
      title: TrText('Emergency seating'),
      content: TrText(isAllowEmergencySeating
          ? acceptTermsText
          : notAllowEmergencySeatingText),
      actions: isAllowEmergencySeating
          ? <Widget>[cancelButton, continueButton]
          : <Widget>[okButton],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }


  prmSeatSelection(BuildContext context, Seat selectedSeat) {
    String acceptTermsText =
        'This seat is a priority for customers with reduced mobility. As such you may be moved if this seat is required for that purpose. If moved, your seat charge will be refunded.';
    String notAllowEmergencySeatingText =
        'Infants can not select this seat';
    bool isAllowEmergencySeating = true;
    Pax selectPax = this.paxlist!.firstWhere((p) => p.selected == true);

    if( selectedSeat.noInfantSeat) {
       var paxTypesNotAllowed = ['IN'];

         if( paxTypesNotAllowed.contains(selectPax.paxType)) {
           isAllowEmergencySeating = false;
         }
    }
    if( gblPnrModel!.paxHasInfant(selectPax) ) {
      notAllowEmergencySeatingText = 'You are trying to allocate a restricted seat to a passenger who is accompanying an infant. Please select another seat!.';
      isAllowEmergencySeating = false;
    }

    Widget cancelButton = TextButton(
      child: TrText('Cancel'),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    Widget continueButton = TextButton(
      child: TrText('OK'),
      onPressed: () {
        Navigator.of(context).pop();
        _seatSelected(selectedSeat.sCode);
      },
    );

    Widget okButton = TextButton(
      child: TrText('OK'),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    AlertDialog alert = AlertDialog(
      title: TrText('Notice'),
      content: TrText(isAllowEmergencySeating
          ? acceptTermsText
          : notAllowEmergencySeatingText),
      actions: isAllowEmergencySeating
          ? <Widget>[cancelButton, continueButton]
          : <Widget>[okButton],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void _seatSelected(String _seatNumber) {
    setState(() {
      paxlist!.forEach((element) {
        if (element.selected == true) {
          element.seat = _seatNumber;
        }
      });
      selectedSeats.clear();
      paxlist!.forEach((f) => selectedSeats.add(f.seat));
    });
    widget.onChanged(paxlist!);
  }

  @override
  Widget build(BuildContext context) {

    int minCol = -1;
    int maxCol = -1;
    //new List<int>();

    this.widget.seatplan.seats.seat.forEach((s) {
      if(minCol == -1 || minCol > s.sCol ){
        minCol = s.sCol;
      }
      if(s.sCol > maxCol ) {
        maxCol = s.sCol;
      }
    });
    //Get the number of rows
    this.widget.seatplan.seats.seat.sort((a, b) => a.sRow.compareTo(b.sRow));
    int rows = this.widget.seatplan.seats.seat.last.sRow;


    this.widget.seatplan.seats.seat.sort((a, b) => a.sCol.compareTo(b.sCol));
   // List<int> arrayColumn = [];


    if( rows <= 0 || minCol == -1 || maxCol <2 ){
      return Container( child: buildMessage('SeatPlan error', 'No Columns', onComplete: () {
        gblPaymentMsg = '';
        setState(() {});
      }));
    }

    return new Expanded(
        child: ListView(
      controller: _controller,
      padding: EdgeInsets.only(left: 5, right: 5),
      children: renderSeats(rows, minCol, maxCol, widget.rloc, widget.cabin),
    ));
  }

  List<Widget> renderSeats(int rows, int minCol, int maxCol, String rloc, String cabin) {
    List<Widget> obj = [];
    // new List<Widget>();
    List<Seat> seats = [];
    // new List<Seat>();
    List<Widget> row = [];
    // new List<Widget>();

    String currentSeatPrice = '';
    String currentSeatPriceLabel = '';
    String currencyCode = '';
    String previousSeatPrice = '';
    bool selectableSeat = true;

    // get max no cols
//    int maxCol = 0;



    for (var indexRow = 1; indexRow <= rows; indexRow++) {
      seats = this
          .widget
          .seatplan
          .seats
          .seat
          .where((a) => a.sRow == indexRow)
          .toList();
      if( seats == null ) {
      } else {
        seats.sort((a, b) => a.sRow.compareTo(b.sCol));

/*
        seats.forEach((element) {
          if (element.sCol != null && element.sCol > maxCol) {
            maxCol = element.sCol;
          }
        });
*/
      }
      // check for large plane
      if( maxCol > 8){
        cellSize = 30;
        cellPadding = 1;
        aisleCellSize = 14;
        cellFontSize = 11;
        print('use small seat size');
      }
      row = [];
      // new List<Widget>();
      for (var indexColumn = minCol;
          indexColumn <= maxCol;
          indexColumn++) {
/*
        if( indexRow == 14) {
          var test = 1;
        }
*/

    Seat? seat ;
    bool found = false;
    seats.forEach((element) {
      if( element.sCol == indexColumn){
        seat = element;
        found = true;
      }
    });
/*
        var seat =
            seats.firstWhere((f) => f.sCol == indexColumn, */
/*orElse: () => null*//*
);
*/


        selectableSeat = true;

        // get price for row
        currentSeatPrice = '0';
        seats.forEach((element) {
          if( element != null &&  element.sScprice != null  ) {
            if( double.parse(element.sScprice) > double.parse(currentSeatPrice)) {
            currentSeatPrice = element.sScprice;
            currentSeatPriceLabel = element.sScinfo;
            currencyCode = element.sCur;
            }
          }
        });
        /*if( seat != null ) {
          currentSeatPrice = seat!.sScprice;
          currencyCode = seat!.sCur;
        }*/
        //Color color = Colors.grey.shade300;
        if (seat == null && indexRow != 1) {
          row.add(Padding(
            padding: EdgeInsets.all(cellPadding),
            child: Container(
              child: Text(''),
              width: cellSize,
            ),
          ));
          //logit('r${indexRow} c${indexColumn} null w${cellSize + cellPadding}');
        } else if (seat == null && indexRow == 1 ||
            seat!.sCellDescription == 'Aisle') {
          row.add(
            Container(
              child: Text(''),
              width: aisleCellSize,
            ),
          );
          //logit('r${indexRow} c${indexColumn} aisle w${aisleCellSize}');

        } else if (seat!.sCellDescription.length == 1) {
          row.add(
            Padding(
                padding: EdgeInsets.all(cellPadding),
                child: Container(
                  width: cellSize,
                  child: Center(
                      child: Text(seat!.sCellDescription != null
                          ? seat!.sCellDescription
                          : '')),
                )),
          );
          //logit('r${indexRow} c${indexColumn} desc==1 w${cellPadding + cellSize}');

        } else if (seat!.sCellDescription == 'SeatPlanWidthMarker' ||
            seat!.sCellDescription == 'Wing Start' ||
            seat!.sCellDescription == 'Wing Middle' ||
            seat!.sCellDescription == 'Wing End' ||
            seat!.sCellDescription == 'DoorDown') {
          row.add(Padding(
            padding: EdgeInsets.all(cellPadding),
            child: Container(
              child: Text(''),
              //width: 10.0,
             // width: 18,
               width: cellSize,
            ),
          ));
          //logit('r${indexRow} c${indexColumn} marker w${cellPadding + cellSize}');

        } else if ((seat!.sRLOC != null && seat!.sRLOC != '' && seat!.sRLOC != rloc) ||
            (seat!.sSeatID != '0' && (seat!.sRLOC == null || seat!.sRLOC == '')) ||
            (seat!.sCellDescription == 'Block Seat') ||
            ((seat!.sCabinClass != widget.cabin) && widget.cabin !='')  ) {

          row.add(
            Padding(
                padding: EdgeInsets.all(cellPadding),
                child: Container(
                  width: cellSize,
                  height: cellSize,
                  decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      color: gblSystemColors.seatPlanColorUnavailable, // gblSystemColors.seatPlanColorRestricted,
                      borderRadius:
                          new BorderRadius.all(new Radius.circular(5.0))),
                  child: Center(
                      child: Icon(
                    Icons.person,
                    size: cellSize,
                    color: Colors.white,
                  )),
                )),
          );
          //logit('r${indexRow} c${indexColumn} block w${cellSize}');

        } else {
          //logit( ' seat r${seat!.sRow} c${seat!.sCol} ${seat!.sCellDescription} s${seat!.sStatus} i${seat!.sSeatID} n${seat!.noInfantSeat}');

          var color;
          switch (seat!.sCellDescription) {
            case 'EmergencySeat':
              color = gblSystemColors.seatPlanColorEmergency;
              break;
            case 'Seat':
              if( seat!.noInfantSeat) {
                color = gblSystemColors.seatPlanColorRestricted;

              } else {
                color = gblSystemColors.seatPlanColorAvailable;
              }
              break;
            default:
              if( seat!.noInfantSeat) {
                color = gblSystemColors.seatPlanColorRestricted;

              } else {
                color = gblSystemColors.seatPlanColorSelected;
              }
              selectableSeat = false;
          }

          //Is the seat already selected by one of the pax
          if (selectedSeats.contains(seat!.sCode)) {
            color = gblSystemColors.seatPlanColorSelected;
            selectableSeat = false;
          }

          row.add(Padding(
              padding: EdgeInsets.all(cellPadding),
              child: GestureDetector(
                child: getSeat(seat,color),
                onTap: () {
                  if( selectableSeat && !selectedSeats.contains(seat!.sCode)) {
                      if( seat!.sCellDescription == 'EmergencySeat' ) {
                        emergencySeatSelection(context, seat!.sCode);
                      } else if( seat!.pRMSeat == true ) {
                        prmSeatSelection(context, seat!);
                      } else {
                        _seatSelected(seat!.sCode);
                      }
                }},
              )));
        }
        selectableSeat = true;
        //logit('r${indexRow} c${indexColumn} Emerg w${cellPadding } + getSeat');

      }
      if( gblLogProducts) logit('price $currentSeatPrice r=$indexRow');
      if (widget.displaySeatPrices &&
          currentSeatPrice != null &&
          currentSeatPrice != "0") {
        //add row price
        if (previousSeatPrice != currentSeatPrice) {
          //TODO: Get currency code from object
          obj.add(
            Container(
              decoration: BoxDecoration(
                  // borderRadius: new BorderRadius.only(
                  //      topLeft: const Radius.circular(1.0),
                  //       topRight: const Radius.circular(1.0)),
                  border: Border(
                top: BorderSide(width: 1.0, color: Color(0xFFFF000000)),
                left: BorderSide(width: 1.0, color: Color(0xFFFF000000)),
                right: BorderSide(width: 1.0, color: Color(0xFFFF000000)),
              )),
              child: Center(
                child: Text(
                  formatPrice(currencyCode, double.parse(currentSeatPrice)) +
                    ' ' + currentSeatPriceLabel), //' Seat Charge'),
              ),
            ),
          );
        }
        previousSeatPrice = currentSeatPrice;
      }
      obj.add(new Row(
        children: row,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
      ));
    }
    obj.add(new Padding(
      padding: EdgeInsets.all(30.0),
    ));
    return obj;
  }
}

Widget getSeat(Seat? seat, Color color) {
  return Column(
  children: [
    Row(children: [
      Align( alignment: FractionalOffset.bottomCenter,
      child: Padding(
        padding: EdgeInsets.only(top: cellSize / 4),
          child: Container(
        width: (1 * cellSize)/10,
        height:  cellSize / 2,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: color,
          border: Border.all(width: 1, color: Colors.black)      ,
          borderRadius:
          new BorderRadius.only( topLeft: Radius.circular(5.0)              ),
        ),
     ))),

       Container(
    width: (4 * cellSize) / 5,
    height: (3 * cellSize) / 4,
    decoration: BoxDecoration(
      shape: BoxShape.rectangle,
      color: color,
                      borderRadius:
                          new BorderRadius.only(topLeft:  new Radius.circular(5.0), topRight:  new Radius.circular(5.0))
    ),
    child: Center(
        child: Text((seat != null && seat.sCode != null) ? seat.sCode : '',
            style: TextStyle(
              fontSize: cellFontSize,
            ))),
  ),

      Align( alignment: FractionalOffset.bottomCenter,
          child: Padding(
              padding: EdgeInsets.only(top: cellSize / 4),
              child: Container(
                width: (1 * cellSize)/10,
                height:  cellSize / 2,
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: color,
                  border: Border.all(width: 1, color: Colors.black)      ,
                  borderRadius:
                  new BorderRadius.only( topRight: Radius.circular(5.0)              ),
                ),
              ))),

    ]),
  Container(
  width: cellSize,
  height:  cellSize / 4,
  decoration: BoxDecoration(
  shape: BoxShape.rectangle,
  color: color,
     border: Border.all(width: 1, color: Colors.black)      ,
          borderRadius:
              new BorderRadius.only( bottomLeft: Radius.circular(5.0),
              bottomRight: Radius.circular(5.0)),
      ),
    ),

  ]);
}
class LinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {

    final p1 = Offset(23 ,23 );
    final p2 = Offset(-5, -5);
    final paint = Paint()
      ..color = Colors.black38
      ..strokeWidth = 2;
    canvas.drawLine(p1, p2, paint);
  }

  @override
  bool shouldRepaint(LinePainter oldDelegate) => false;
}