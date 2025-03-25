


import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vmba/Seats/seatLayout.dart';
import 'package:vmba/components/vidButtons.dart';
import 'package:vmba/seats/seat.dart';
import 'package:vmba/seats/wing.dart';
import 'package:vmba/mmb/widgets/seatplan.dart';

import '../../../calendar/flightPageUtils.dart';
import '../../../components/showDialog.dart';
import '../../../components/trText.dart';
import '../../../data/globals.dart';
import '../../../data/models/pax.dart';
import '../../../data/models/pnr.dart';
import '../../../data/models/seatplan.dart';
import '../../../utilities/helper.dart';
import '../../../utilities/widgets/snackbarWidget.dart';
import '../../../v3pages/v3Theme.dart';
import '../Helpers/settingsHelper.dart';

// seat layouts / seat plans found at https://www.aerolopa.com/lm-e45


double cellSize = 45.0; //28.0;
double cellFontSize = 13.0;
double cellPadding = 5.0;
double aisleCellSize = 20.0;
bool nullSeatNoSpace = true;

class RenderSeatPlan2 extends StatefulWidget {
  const RenderSeatPlan2(
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

  _RenderSeatPlanSeatState2 createState() => _RenderSeatPlanSeatState2();
}
String acceptTermsText =
    'This seat is a priority for customers with reduced mobility. As such you may be moved if this seat is required for that purpose. If moved, your seat charge will be refunded.';
String notAllowEmergencySeatingText =
    'Infants can not select this seat';

List<String> gblSelectedSeats = [];

class _RenderSeatPlanSeatState2 extends State<RenderSeatPlan2> {
  Seat? selectedSeat;

  PaxList? paxlist;

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
    loadData();
    logit('got it');
    gblSeatplan = widget.seatplan;
  }

  emergencySeatSelection(BuildContext context, String selectedSeat) {
/*
    String acceptTermsText =
        'By selecting this seat you confirm that you are over 16 years old and do not have any physical or vision impairment';
    String notAllowEmergencySeatingText =
        'To select this seat you must be over 16 years old';
*/

    var paxTypesNotAllowed = ['CH', 'IN'];
    Pax selectPax = this.paxlist!.list!.firstWhere((p) => p.selected == true);

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

  void loadData() {
    paxlist = new PaxList();
    gblSelectedSeats = [];
    paxlist!.init(widget.pax);
    paxlist!.list!.forEach((f) => gblSelectedSeats.add(f.seat));

    gblSeatPlanDef = this.widget.seatplan.getPlanDataTable();
  }

  prmSeatSelection(BuildContext context, Seat selectedSeat) {
/*
    String acceptTermsText =
        'This seat is a priority for customers with reduced mobility. As such you may be moved if this seat is required for that purpose. If moved, your seat charge will be refunded.';
*/
    bool isAllowEmergencySeating = true;
    Pax selectPax = this.paxlist!.list!.firstWhere((p) => p.selected == true);

    if (selectedSeat.noInfantSeat) {
      var paxTypesNotAllowed = ['IN'];

      if (paxTypesNotAllowed.contains(selectPax.paxType)) {
        isAllowEmergencySeating = false;
      }
    }
    if (gblPnrModel!.paxHasInfant(selectPax)) {
      notAllowEmergencySeatingText =
      'You are trying to allocate a restricted seat to a passenger who is accompanying an infant. Please select another seat!.';
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

  void selectPaxForSeat(BuildContext context, Seat iselectedSeat) {
    selectedSeat = iselectedSeat;

/*
  String msg = '';
  String seatType = '';

  if( selectedSeat!.sCellDescription == 'EmergencySeat' ) {
    seatType = 'EmergencySeat';
    msg =
    'By selecting this seat you confirm that you are over 16 years old and do not have any physical or vision impairment ' + '\n' +
     notAllowEmergencySeatingText;
  } else if( selectedSeat!.pRMSeat == true ) {
    seatType = 'Restricted seat';
    msg = acceptTermsText;
  }


  List<Widget> list = [];
  if( msg != '' ) {
    list.add(Padding(
      padding: EdgeInsets.only(left: 10.0, right: 10.0),
      child: TextField(
        readOnly: true,
        decoration: InputDecoration(
          hintText: msg,
          border: InputBorder.none,
        ),
        maxLines: 4,
      ),
    ));

    list.add(V3Divider());
  }
  list.add(Padding(padding: EdgeInsets.all(15), child:  VBodyText('Who is going to occupy this seat?', wantTranslate: true,)));
  list.add(getPaxSeatList(selectedSeat));
  list.add(V3Divider());

 Widget content = Column(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    mainAxisSize: MainAxisSize.min,
    children: list
  );
*/
    String seatType = '';
    if (selectedSeat!.sCellDescription == 'EmergencySeat') {
      seatType = 'EmergencySeat';
    } else if (selectedSeat!.pRMSeat == true) {
      seatType = 'Restricted seat';
    }
    showVidDialog(context, 'Seat ${selectedSeat!.sCode} $seatType', '',
        type: DialogType.Custom, getContent: getContent,
        onComplete: () {
          Navigator.of(context).pop();
          widget.onChanged(paxlist!.list!);
        }
    );
  }


  Widget getContent(void Function(void Function()) setState2) {
    String msg = '';


    if (selectedSeat!.sCellDescription == 'EmergencySeat') {
      msg =
          'By selecting this seat you confirm that you are over 16 years old and do not have any physical or vision impairment ' +
              '\n' +
              notAllowEmergencySeatingText;
    } else if (selectedSeat!.pRMSeat == true) {
      msg = acceptTermsText;
    }


    List<Widget> list = [];
    if (msg != '') {
      list.add(Padding(
        padding: EdgeInsets.only(left: 10.0, right: 10.0),
        child: TextField(
          readOnly: true,
          decoration: InputDecoration(
            hintText: translate(msg),
            border: InputBorder.none,
          ),
          maxLines: 8,
        ),
      ));

      list.add(V3Divider());
    }
    list.add(Padding(padding: EdgeInsets.all(15),
        child: VBodyText(
          'Who is going to occupy this seat?', wantTranslate: true,)));
    list.add(getPaxSeatList(selectedSeat as Seat, setState2));
    list.add(V3Divider());

    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: list
    );
  }


  Widget getPaxSeatList(Seat seat, void Function(void Function()) setState2) {
    List<Widget> paxes = [];

    // check if seat already selected
    int index = 0;
    bool seatSelected = false;
    paxlist!.list!.forEach((p) {
      if (paxlist!.list![index].seat == seat.sCode) {
        seatSelected = true;
      }
      index+=1;
    });

    index = 0;
    paxlist!.list!.forEach((p) {
      List<String> nameArray = p.name.split(' ');
      List<Widget> textList = [];
      nameArray.forEach((element) {
        textList.add(VBodyText(element));
      });
      String action = '';
      if (paxlist!.list![index].seat == '') {
        action = 'Select';
      } else if (paxlist!.list![index].seat == seat.sCode) {
        action = 'Release';
      } else {
        action = 'Replace';
      }

      String price = 'Included';
      if (seat.sScprice != '' && seat.sScprice != '0') {
        price = formatPrice(seat.sCur, double.parse(seat.sScprice)) +
            ' ' + seat.sScinfo;
      }

      paxes.add(ListTile(
          contentPadding: EdgeInsets.all(0),
          title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // seat no
                (p.seat != '') ? Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 5, 0),
                  child: getSeat2(
                      Seat(sCode: p.seat, sCellDescription: 'Seat'), false,
                      SeatSize.medium, noCode: true, occupant: this.paxlist!.getOccupant(seat.sCode, seat, widget.rloc)),) : Container(),
                // name
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: textList,),
                // cannot select a seat more than once
                (action == 'Select' && seatSelected) ? Container() :
                vidActionButton(context, action,
                    params: new ButtonClickParams(paxNo: index, action: action),
                    isRectangular: true,
                    subCaption: action == 'Select' ? price : '',
                    color: paxlist!.list![index].seat != ''
                        ? gblSystemColors.seatSelectButtonColor as Color
                        : gblSystemColors.seatSelectTextColor as Color,
                    bkColor: paxlist!.list![index].seat != ''
                        ? Colors.white
                        : gblSystemColors.seatSelectButtonColor as Color,
                    lineColor: paxlist!.list![index].seat != ''
                        ? gblSystemColors.seatSelectButtonColor as Color
                        : null,
                        (p0, params) {
                      // select pax for this seat

                      logit(
                          'pax ${params!.paxNo} ${params.action} ${paxlist!
                              .list![params.paxNo].name} to seat ${seat
                              .sCode}');
                      if (params.action.toLowerCase() == 'release') {
                        paxlist!.releaseSeat(seat.sCode);
                      } else { //replace
                        paxlist!.releaseSeat(p.seat);
                        paxlist!.list![params.paxNo].selected = true;
                        paxlist!.list![params.paxNo].seat = seat.sCode;
                        gblSelectedSeats.add(seat.sCode);
                      }
                      setState2(() {

                      });
                    })
              ]
          )
      )
      );
      index++;
    });

    double setVal = 120;
    double maxVal = 220;
    if (paxes.length > 2) {
      if (paxes.length < 5) {
        maxVal = paxes.length * 60;
        setVal = paxes.length * 50;
      } else {
        maxVal = 300;
        setVal = 200;
      }
    }
    return Flexible(child:
    SizedBox(
        height: clampDouble(setVal, 10, maxVal),
        child:
        SingleChildScrollView(
            child: Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: paxes,),
            )
        ))
    );
  }

  void _seatSelected(String _seatNumber) {
    int paxIndex = 0;
    int lastPax = 0;
    setState(() {
      paxlist!.list!.forEach((element) {
        if (element.selected == true) {
          element.seat = _seatNumber;
          lastPax = paxIndex;
          gblCurPax = paxIndex;
          element.selected = false;
        }
        paxIndex++;
      });
      gblSelectedSeats.clear();
      paxlist!.list!.forEach((f) => gblSelectedSeats.add(f.seat));
    });

    String message = '${translate('Seat')} $_seatNumber ${translate(
        'selected')}';
    if ((lastPax + 1) < paxlist!.list!.length) {
      gblCurPax++;
      paxlist!.list![gblCurPax].selected = true;
      message += ' ${translate('select seat for next passenger')}';
    }

    try {
      ScaffoldMessenger.of(context).showSnackBar(snackbar(message));
    } catch (e) {}

    widget.onChanged(paxlist!.list!);
  }

  @override
  Widget build(BuildContext context) {
    int minCol = -1;
    int maxCol = -1;
    //new List<int>();

    this.widget.seatplan.seats.seat.forEach((s) {
      if (minCol == -1 || minCol > s.sCol) {
        minCol = s.sCol;
      }
      if (s.sCol > maxCol) {
        maxCol = s.sCol;
      }
    });
    //Get the number of rows
    this.widget.seatplan.seats.seat.sort((a, b) => a.sRow.compareTo(b.sRow));
    int rows = this.widget.seatplan.seats.seat.last.sRow;

    logit('render seatplan $rows rows, $minCol minCol, $maxCol maxCol');

    this.widget.seatplan.seats.seat.sort((a, b) => a.sCol.compareTo(b.sCol));
    // List<int> arrayColumn = [];


    if (rows <= 0 || minCol == -1 || maxCol < 2) {
      return Container(
          child: buildMessage('SeatPlan error', 'No Columns', onComplete: () {
            gblPaymentMsg = '';
            setState(() {});
          }));
    }


/*
    Column( children: [
        noFlts > 1 ? title : Container(),
*/
    if (gblLoadSeatState == VrsCmdState.loading) {
      return Expanded(child:
      Container(
        margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
        padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
        height: 2000,
        width: 400,
        decoration: BoxDecoration(
          //border: Border.all(color: v2BorderColor(), width: v2BorderWidth()),
          borderRadius: BorderRadius.all(
              Radius.circular(10.0)),
          color: Colors.grey,
        ),
        child: TrText('Loading...'),
      )
      );
    }

    return seatsByPosition();
  }

  List<Widget> renderSeats(int rows, int minCol, int maxCol, String rloc,
      String cabin) {
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
    bool hasWings = this.widget.seatplan.hasWings();
    int leftWingIndex = this.widget.seatplan.getLeftWing();
    int rightWingIndex = this.widget.seatplan.getRightWing();


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
//      if (seats == null) {} else {
        seats.sort((a, b) => a.sRow.compareTo(b.sCol));
  //    }
      // check for large plane
      if (maxCol > 8) {
        cellSize = 30;
        cellPadding = 1;
        aisleCellSize = 14;
        cellFontSize = 11;
        print('use small seat size');
      }
      bool dumpSeats = true;
      String dumpMsg = '$indexRow ';
      if (indexRow < 10) dumpMsg = ' $indexRow ';

      row = [];
      String leftWing = 'f';
      String rightWing = 'f';
      bool rowHasSeats = false;
      // new List<Widget>();
      for (var indexColumn = minCol;
      indexColumn <= maxCol;
      indexColumn++) {
        Seat? seat;
        seats.forEach((element) {
          if (element.sCol == indexColumn) {
            seat = element;
          }
        });

        selectableSeat = true;

        // get price for row
        currentSeatPrice = '0';
        seats.forEach((element) {
            if (double.parse(element.sScprice) >
                double.parse(currentSeatPrice)) {
              currentSeatPrice = element.sScprice;
              currentSeatPriceLabel = element.sScinfo;
              currencyCode = element.sCur;
            }
        });

        if (seat != null && seat!.sRLOC != '') {
          logit('s=${seat!.sCode} r=${seat!.sRLOC}');
        }

        if (indexColumn == leftWingIndex &&
            (seat == null || seat!.sCellDescription == '')) {
//          row.add(getWingPath(context, 'f', 50, 45, true));
        } else if (indexColumn == rightWingIndex &&
            (seat == null || seat!.sCellDescription == '')) {
          //          row.add(getWingPath(context, 'f', 50, 45, false));
        } else if (seat == null && indexRow != 1) {
          dumpMsg += ' n ';
          if (nullSeatNoSpace) {
            row.add(Padding(
              padding: EdgeInsets.all(0),
            ));
          } else {
            row.add(Padding(
              padding: EdgeInsets.all(cellPadding),
              child: Container(
                child: Text(''),
                width: cellSize,
              ),
            ));
          }
        } else if (seat == null && indexRow == 1 ||
            seat!.sCellDescription == 'Aisle') {
          dumpMsg += ' a ';
          row.add(
            Container(
              child: Text(''),
              width: aisleCellSize,
            ),
          );
        } else if (seat!.sCellDescription.length == 1) {
          dumpMsg += ' ${seat!.sCellDescription} ';
          row.add(
            Padding(
                padding: EdgeInsets.all(cellPadding),
                child: Container(
                  width: cellSize,
                  child: Center(
                      child: Text(seat!.sCellDescription)),
                )),
          );
        } else if (seat!.sCellDescription == 'SeatPlanWidthMarker' ||
            seat!.sCellDescription == 'Wing Start' ||
            seat!.sCellDescription == 'Wing Middle' ||
            seat!.sCellDescription == 'Wing End' ||
            seat!.sCellDescription == 'DoorDown' ||
            seat!.sCellDescription == 'DoorUp') {

          if ( gblSettings.seatPlanStyle.contains('W')) {
            switch (seat!.sCellDescription) {
              case 'SeatPlanWidthMarker':
                //seatTxt = 'w';
                indexColumn < 3 ? leftWing = 'w' : rightWing = 'w';
                break;
              case 'Wing Start':
                //seatTxt = 's';
                indexColumn < 3 ? leftWing = 's' : rightWing = 's';
                //pathWidget = getWingPath(context, 's', 50, 45, indexColumn < 3);
                break;
              case 'Wing Middle':
                ///pathWidget = getWingPath(context, 'm', 50, 45, indexColumn < 3);
                indexColumn < 3 ? leftWing = 'm' : rightWing = 'm';
                //seatTxt = 'm';
                break;
              case 'Wing End':
                //pathWidget = getWingPath(context, 'e', 50, 45, indexColumn < 3);
                indexColumn < 3 ? leftWing = 'e' : rightWing = 'e';
                //seatTxt = 'e';
                break;
              case 'DoorDown':
                //pathWidget = getWingPath(context, 'd', 50, 45, indexColumn < 3);
                indexColumn < 3 ? leftWing = 'd' : rightWing = 'd';
                //seatTxt = 'd';
                break;
              case 'DoorUp':
                //pathWidget = getWingPath(context, 'd', 50, 45, indexColumn < 3);
                indexColumn < 3 ? leftWing = 'd' : rightWing = 'd';
                //seatTxt = 'u';
                break;
            }
          }

          /*row.add(pathWidget ??
              Padding(
            padding: EdgeInsets.all(cellPadding),
            child: Container(
              child: Text(seatTxt),
              width: cellSize,
            ),
          ));*/
        } else
        if ((seat!.sRLOC != '' && seat!.sRLOC != rloc) ||
            (seat!.sSeatID != '0' &&
                (seat!.sRLOC == '')) ||
            (seat!.sCellDescription == 'Block Seat') ||
            ((seat!.sCabinClass != widget.cabin) && widget.cabin != '')) {
          rowHasSeats = true;
          row.add(hookUpSeat(seat, false, false, gblSeatPlanDef!.seatSize));
        } else {
          var color;
          dumpMsg += '${seat!.sCode} ';
          switch (seat!.sCellDescription) {
            case 'EmergencySeat':
              color = gblSystemColors.seatPlanColorEmergency;
              break;
            case 'Seat':
              if (seat!.noInfantSeat) {
                color = gblSystemColors.seatPlanColorRestricted;
              } else {
                color = gblSystemColors.seatPlanColorAvailable;
              }
              if (seat!.sRLOC != '') {
                SeatType.selected;
              }
              break;

            default:
              if (seat!.noInfantSeat) {
                color = gblSystemColors.seatPlanColorRestricted;
              } else {
                color = gblSystemColors.seatPlanColorSelected;
              }
              selectableSeat = false;
          }

          //Is the seat already selected by one of the pax
          if (gblSelectedSeats.contains(seat!.sCode)) {
            color = gblSystemColors.seatPlanColorSelected;
            selectableSeat = false;
          }
          bool selected = false;
          if (seat != null && seat!.sCode != '' &&
              gblSelectedSeats.contains(seat!.sCode)) {
            selected = true;
          }

          rowHasSeats = true;
          row.add(hookUpSeat(
              seat, selected, selectableSeat, gblSeatPlanDef!.seatSize));
/*          row.add(Padding(
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
              )));*/
        }
        selectableSeat = true;
        //logit('r${indexRow} c${indexColumn} Emerg w${cellPadding } + getSeat');

      }
      if (gblLogProducts) logit('price $currentSeatPrice r=$indexRow');
      if (widget.displaySeatPrices &&
          currentSeatPrice != "0") {
        //add row price
        if (previousSeatPrice != currentSeatPrice) {
          //TODO: Get currency code from object
          rowHasSeats = true;
          // check if

          obj.add(
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    (hasWings && gblSettings.seatPlanStyle.contains('W'))
                        ? getWingPath(context, 'f', 50, 45, true)
                        : Container(),
                    Expanded(child: Container(
                        color: gblSettings.seatPlanStyle.contains('I')
                            ? gblSystemColors.seatPlanBackColor
                            : null,
                        child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Padding(padding: EdgeInsets.all(5)),
                              Container(
                                margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                                decoration: BoxDecoration(
                                    border: Border(
                                      top: BorderSide(width: 2.0,
                                          color: gblSystemColors
                                              .seatPriceColor as Color),
                                      left: BorderSide(width: 2.0,
                                          color: gblSystemColors
                                              .seatPriceColor as Color),
                                      right: BorderSide(width: 2.0,
                                          color: gblSystemColors
                                              .seatPriceColor as Color),
                                    )),
                                child: Center(
                                  child: Text(
                                    formatPrice(currencyCode,
                                        double.parse(currentSeatPrice)) +
                                        '\n ' + currentSeatPriceLabel,
                                    style: TextStyle(color: gblSystemColors
                                        .seatPriceColor as Color),
                                  ),
                                  //' Seat Charge'),
                                ),
                              ),
                            ]))),
                    (hasWings && gblSettings.seatPlanStyle.contains('W'))
                        ? getWingPath(context, 'f', 50, 45, false)
                        : Container(),

                  ]
              )
          );
        }
        previousSeatPrice = currentSeatPrice;
      }
      if (dumpSeats) {
        logit(dumpMsg);
      }
      if (rowHasSeats) {
        obj.add(
            Row(
                children: [
                  gblSettings.seatPlanStyle.contains('W') ? getWingPath(
                      context, leftWing, 50, 45, true) : Container(),
                  Expanded(child: Container(
                      color: gblSettings.seatPlanStyle.contains('I')
                          ? gblSystemColors.seatPlanBackColor
                          : null,
                      child:
                      new Row(
                        children: row,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      ))
                  ),
                  gblSettings.seatPlanStyle.contains('W') ? getWingPath(
                      context, rightWing, 50, 45, false) : Container()
                ]
            ));
      }
    }
    obj.add(new Padding(
      padding: EdgeInsets.all(30.0),
    ));
    return obj;
  }

/*
  List<Widget> renderSeats2(int rows, int minCol, int maxCol, String rloc,
      String cabin) {
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


    List<TableRow> tabRows = [];

    for (var indexRow = 1; indexRow <= rows; indexRow++) {
      seats = this
          .widget
          .seatplan
          .seats
          .seat
          .where((a) => a.sRow == indexRow)
          .toList();
      if (seats == null) {} else {
        seats.sort((a, b) => a.sRow.compareTo(b.sCol));
      }
      // check for large plane
      if (maxCol > 8) {
        cellSize = 30;
        cellPadding = 1;
        aisleCellSize = 14;
        cellFontSize = 11;
        print('use small seat size');
      }
      row = [];

      List<Widget> list = [];
      for (int i = minCol; i <= maxCol; i++) {
        Seat? seat = gblSeatPlanDef!.getSeatAt(indexRow, i);
        bool selected = false;
        if (seat == null) {

        } else {
          //logit('r=${seat.sRow} c=${seat.sCol} code=${seat.sCode}');
        }
        if (selectedSeats != null && seat != null && seat!.sCode != '' &&
            selectedSeats.contains(seat!.sCode)) {
          //color = gblSystemColors.seatPlanColorSelected;
          selected = true;
          // selectableSeat = false;
        }
        if (seat != null && cabin != seat.sCabinClass) {
          seat = Seat(sCode: seat.sCode, sCellDescription: 'Occupied');
        }
        if (seat != null && seat.sCode == '') {
          list.add(Container());
        } else {
          //if( seat != null ) logit('hookup ${seat!.sCode}');
          list.add(hookUpSeat(
              seat, selected, selectableSeat, gblSeatPlanDef!.seatSize));
        }
      }
      TableRow tableRow = TableRow(children: list);


      if (gblLogProducts) logit('price $currentSeatPrice r=$indexRow');
      */
/* if (widget.displaySeatPrices &&
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
      }*/ /*

      row.add(VerticalDivider(width: 2,
        color: Colors.amber,
        indent: 0,
        endIndent: 0,
        thickness: 3,));
      row.add(_getSeatPriceInfo());
      if (seats != null && seats.length > 0) {
        obj.add(new Row(
          children: row,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
        ));
      } else {
        //logit( ' row  empty' );
      }
      row.add(Container()); // space filler (will be price!)
      tabRows.add(tableRow);
    }
    obj.add(new Padding(
      padding: EdgeInsets.all(30.0),
    ));
    //return obj;
    obj = [];
    Map <int, TableColumnWidth> colWidths = Map();

    bool beforSeats = true;

    for (int i = 0; i <= maxCol - minCol; i++) {
      if (gblSeatPlanDef!.colTypes == null ||
          gblSeatPlanDef!.colTypes.length < i) {
        colWidths[i] = FixedColumnWidth(5);
      } else {
        if (gblSeatPlanDef!.colTypes[i + minCol] == 'A') {
          if (beforSeats) {
            colWidths[i] = FixedColumnWidth(0);
          } else {
            colWidths[i] = FixedColumnWidth(gblSeatPlanDef!.asileWidth);
          }
        } else {
          colWidths[i] = FixedColumnWidth(gblSeatPlanDef!.seatWidth);
          beforSeats = false;
        }
      }
    }
    colWidths[maxCol - minCol + 1] = IntrinsicColumnWidth();


    obj.add(Table(

        columnWidths: colWidths,
        border: TableBorder.all(color: Colors.transparent),
        children: tabRows)
    );
    obj.add(Padding(padding: EdgeInsets.all(20)));
    return obj;
  }
*/
  Widget dummySeat(String id, Color clr) {
    return Container(
      alignment: Alignment.center,
      width: seatWidth,
      height: seatHeight,
      decoration: BoxDecoration(
        border: Border.all(color: v2BorderColor(), width: v2BorderWidth()),
        borderRadius: BorderRadius.all(
            Radius.circular(3.0)),
        color: clr,
      ),
      child: Text(id),
    );
  }

  Widget seatsByPosition() {
    return Expanded(
        child: SingleChildScrollView(
            child: Stack(
              children:
              AddSeats(context, hookUpSeat),
            )
        )
    );
  }


/*
  Widget _getSeatPriceInfo() {
    return Container(child: Row(
      //crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        VerticalDivider(width: 2, color: Colors.red, thickness: 10,),
        Container(
          margin: EdgeInsets.all(0),
          padding: EdgeInsets.all(0),
          width: 3,
          height: 40,
          color: Colors.white,
          child: Padding(padding: EdgeInsets.all(0),),),
        //Padding(padding: EdgeInsets.fromLTRB(40, 0, 20, 0)),
        //     VBodyText('price', color: Colors.white,),
      ],));
  }
*/

  Widget hookUpSeat(Seat? seat, bool selected, bool selectableSeat,SeatSize seatSize) {
    return Padding(
        padding: EdgeInsets.all(cellPadding),
        child: GestureDetector(
          child: getSeat2(seat, selected, seatSize),
          onTap: () {
            if (selectableSeat && !gblSelectedSeats.contains(seat!.sCode)) {
              selectPaxForSeat(context, seat);
            }
          },
        ));
  }
}
  Widget  getSeat2(Seat? seat, bool selected, SeatSize seatSize, {bool noCode=false, String occupant=''}) {
    SeatType seatType = SeatType.occupied;
    if (seat == null) {
      return Container();
    }
    switch (seat.sCellDescription) {
      case 'Occupied':
        seatType = SeatType.occupied;
        break;
      case 'Block Seat':
        seatType = SeatType.unavailable;
        break;
      case 'EmergencySeat':
        seatType = SeatType.emergency;
        if (selected) seatType = SeatType.selected;
        if( seat.sRLOC != '' ) SeatType.selected;
        break;
      case 'Seat':
        if (seat.noInfantSeat) {
          seatType = SeatType.availableRestricted;
        } else {
          seatType = SeatType.available;
        }
        if (selected) {
          seatType = SeatType.selected;
        }
          if( seat.sRLOC != '' ) {
            SeatType.selected;
          }
          break;

      default:
        if (seat.noInfantSeat) {
          seatType = SeatType.availableRestricted;
        } else {
          seatType = SeatType.available;
        }
        if (selected) seatType = SeatType.selected;
        break;
    }
    String code = seat.sCode;
    if( seatType == SeatType.occupied){
      // check
    }
    if( seat.sRLOC != '' ){
      seatType = SeatType.occupied;
      if( seat.sRLOC == gblCurrentRloc) {
        code = gblPnrModel!.getOccupant(code);
      }
    }


    //widget.paxlist.getOccupant(code,seat, String rloc);
    //getOccupant(String code, Seat? seat, String rloc){

    if( noCode == false) {

      String oCode = occupant;
      if( oCode != '' ) code = oCode;
    }
      if( code != '' &&  code != seat.sCode){
        // occupied seat
        seatType = SeatType.selected;
      }


      return seat2(code, seatType, seatSize);
    }



Widget getSeatplanTitle() {
  Itin flt = gblPnrModel!.pNR.itinerary.itin[gblCurJourney];
  int noFlts = gblPnrModel!.pNR.itinerary.itin.length;
  String outLong = '${flt.airID} ${flt.fltNo} ${flt.depart} to ${flt.arrive} ${getIntlDate('EEE dd MMM', DateTime.parse(flt.depDate + ' ' + flt.depTime))}';
  return   Align( alignment: Alignment.topLeft, child: Padding( padding: EdgeInsets.fromLTRB(10,0,0,0), child:VTitleText(outLong, size: TextSize.large,)));

}
