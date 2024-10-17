


import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vmba/components/vidButtons.dart';
import 'package:vmba/mmb/widgets/seatComponents/seat.dart';
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

double cellSize = 45.0; //28.0;
double cellFontSize = 13.0;
double cellPadding = 5.0;
double aisleCellSize = 20.0;

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

class _RenderSeatPlanSeatState2 extends State<RenderSeatPlan2> {
  Seat? selectedSeat;
  String acceptTermsText =
      'This seat is a priority for customers with reduced mobility. As such you may be moved if this seat is required for that purpose. If moved, your seat charge will be refunded.';
  String notAllowEmergencySeatingText =
      'Infants can not select this seat';

  PaxList? paxlist;
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
    loadData();
    logit('got it');
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
    paxlist!.init(widget.pax);
    paxlist!.list!.forEach((f) => selectedSeats.add(f.seat));

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
    bool isAllowEmergencySeating = true;
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
            hintText: msg,
            border: InputBorder.none,
          ),
          maxLines: 4,
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

    int index = 0;
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
      if( seat.sScprice != '' && seat.sScprice != '0') {
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
                    child: _getSeat(
                        Seat(sCode: p.seat, sCellDescription: 'Seat'), false,
                        SeatSize.medium, noCode: true), ) : Container(),
                // name
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: textList,),
                vidActionButton(context, action,
                    params: new ButtonClickParams(i1: index),
                    isRectangular: true,
                    subCaption: action == 'Select' ? price : '',
                    color: paxlist!.list![index].seat != ''
                        ? Colors.blue
                        : Colors.black,
                    bkColor: paxlist!.list![index].seat != ''
                        ? Colors.white
                        : Colors.amber,
                    lineColor: paxlist!.list![index].seat != ''
                        ? Colors.amber
                        : null,
                        (p0, params) {
                      // select pax for this seat

                      logit(
                          'set ${paxlist!.list![params!.i1].name} to seat ${seat
                              .sCode}');
                      paxlist!.releaseSeat(seat.sCode);
                      paxlist!.list![params!.i1].selected = true;
                      paxlist!.list![params!.i1].seat = seat.sCode;
                      setState2(() {

                      });
                    })
              ]
          )
      )
      );
      index++;
    });

    double setVal = 100;
    double maxVal = 200;
    if (paxes.length > 2) {
      if (paxes.length < 5) {
        maxVal = paxes.length * 50;
        setVal = paxes.length * 40;
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
      selectedSeats.clear();
      paxlist!.list!.forEach((f) => selectedSeats.add(f.seat));
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

    return Container(
        margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
        padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
/*
        height: 2000,
        width: 400,
*/
        decoration: BoxDecoration(
          //border: Border.all(color: v2BorderColor(), width: v2BorderWidth()),
          borderRadius: BorderRadius.all(
              Radius.circular(10.0)),
          color: Colors.black,
        ),
        child: Column(children: renderSeats(
            rows, minCol, maxCol, widget.rloc, widget.cabin))
    );

    Expanded(child:
    Container(
        margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
        padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
        height: 2000,
        width: 400,
        decoration: BoxDecoration(
          //border: Border.all(color: v2BorderColor(), width: v2BorderWidth()),
          borderRadius: BorderRadius.all(
              Radius.circular(10.0)),
          color: Colors.black,
        ),
        child: Row(
            children: [
              Expanded(
                  flex: 2,
                  child: ListView(
                    controller: _controller,
                    padding: EdgeInsets.only(left: 5, right: 5),
                    children: renderSeats(
                        rows, minCol, maxCol, widget.rloc, widget.cabin),
                  )),
              Expanded(
                  flex: 1,
                  child: Text('price', style: TextStyle(color: Colors.red),)
              ),
            ]
//        )
        )
    )
    );
/*
    ],
    ) ;
*/
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
      if (seats == null) {} else {
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
      if (maxCol > 8) {
        cellSize = 30;
        cellPadding = 1;
        aisleCellSize = 14;
        cellFontSize = 11;
        print('use small seat size');
      }
      row = [];
      bool rowHasSeats = false;
      // new List<Widget>();
      for (var indexColumn = minCol;
      indexColumn <= maxCol;
      indexColumn++) {
/*
        if( indexRow == 14) {
          var test = 1;
        }
*/

        Seat? seat;
        bool found = false;
        seats.forEach((element) {
          if (element.sCol == indexColumn) {
            seat = element;
            found = true;
          }
        });

        selectableSeat = true;

        // get price for row
        currentSeatPrice = '0';
        seats.forEach((element) {
          if (element != null && element.sScprice != null) {
            if (double.parse(element.sScprice) >
                double.parse(currentSeatPrice)) {
              currentSeatPrice = element.sScprice;
              currentSeatPriceLabel = element.sScinfo;
              currencyCode = element.sCur;
            }
          }
        });
        if (seat == null && indexRow != 1) {
          row.add(Padding(
            padding: EdgeInsets.all(cellPadding),
            child: Container(
              child: Text(''),
              width: cellSize,
            ),
          ));
        } else if (seat == null && indexRow == 1 ||
            seat!.sCellDescription == 'Aisle') {
          row.add(
            Container(
              child: Text(''),
              width: aisleCellSize,
            ),
          );
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
        } else
        if ((seat!.sRLOC != null && seat!.sRLOC != '' && seat!.sRLOC != rloc) ||
            (seat!.sSeatID != '0' &&
                (seat!.sRLOC == null || seat!.sRLOC == '')) ||
            (seat!.sCellDescription == 'Block Seat') ||
            ((seat!.sCabinClass != widget.cabin) && widget.cabin != '')) {
          rowHasSeats = true;
          row.add(hookUpSeat(seat, false, false, gblSeatPlanDef!.seatSize));
          /* row.add(
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
          );*/

        } else {
          var color;
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
          if (selectedSeats.contains(seat!.sCode)) {
            color = gblSystemColors.seatPlanColorSelected;
            selectableSeat = false;
          }
          bool selected = false;
          if (selectedSeats != null && seat != null && seat!.sCode != '' &&
              selectedSeats.contains(seat!.sCode)) {
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
          currentSeatPrice != null &&
          currentSeatPrice != "0") {
        //add row price
        if (previousSeatPrice != currentSeatPrice) {
          //TODO: Get currency code from object
          rowHasSeats = true;
          obj.add(
            Column(
              children: [
                Padding(padding: EdgeInsets.all(5)),
            Container(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
              decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(width: 2.0,
                        color: Colors.white /*Color(0xFFFF000000)*/),
                    left: BorderSide(width: 2.0, color: Colors.white),
                    right: BorderSide(width: 2.0, color: Colors.white),
                  )),
              child: Center(
                child: Text(
                  formatPrice(currencyCode, double.parse(currentSeatPrice)) +
                      ' ' + currentSeatPriceLabel,
                  style: TextStyle(color: Colors.white),
                ),
                //' Seat Charge'),
              ),
            ),
          ])
          );
        }
        previousSeatPrice = currentSeatPrice;
      }
      if( rowHasSeats) {
        obj.add(new Row(
          children: row,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
        ));
      }
    }
    obj.add(new Padding(
      padding: EdgeInsets.all(30.0),
    ));
    return obj;
  }

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
      }*/
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

  Widget hookUpSeat(Seat? seat, bool selected, bool selectableSeat,
      SeatSize seatSize) {
    return Padding(
        padding: EdgeInsets.all(cellPadding),
        child: GestureDetector(
          child: _getSeat(seat, selected, seatSize),
          onTap: () {
            if (selectableSeat && !selectedSeats.contains(seat!.sCode)) {
              selectPaxForSeat(context, seat!);
            }
          },
        ));
  }

  Widget _getSeat(Seat? seat, bool selected, SeatSize seatSize, {bool noCode=false}) {
    SeatType seatType = SeatType.occupied;
    if (seat == null) {
      return Container();
    }
    switch (seat!.sCellDescription) {
      case 'Occupied':
        seatType = SeatType.occupied;
        break;
      case 'Block Seat':
        seatType = SeatType.unavailable;
        break;
      case 'EmergencySeat':
        seatType = SeatType.emergency;
        break;
      case 'Seat':
        if (seat!.noInfantSeat) {
          seatType = SeatType.availableRestricted;
        } else {
          seatType = SeatType.available;
        }
        if (selected) seatType = SeatType.selected;
        break;
      default:
        if (seat!.noInfantSeat) {
          seatType = SeatType.availableRestricted;
        } else {
          seatType = SeatType.available;
        }
        if (selected) seatType = SeatType.selected;
        break;
    }
    String code = seat!.sCode;
    if( noCode == false) code = this.paxlist!.getOccupant(code);
    if( code != seat!.sCode){
      // occupied seat
      seatType = SeatType.selected;
    }


    return seat2(code, seatType, seatSize);
  }
}

Widget getSeatplanTitle() {
  Itin flt = gblPnrModel!.pNR.itinerary.itin[gblCurJourney];
  int noFlts = gblPnrModel!.pNR.itinerary.itin.length;
  String outLong = '${flt.airID} ${flt.fltNo} ${flt.depart} to ${flt.arrive} ${getIntlDate('EEE dd MMM', DateTime.parse(flt.depDate + ' ' + flt.depTime))}';
  return   Align( alignment: Alignment.topLeft, child: Padding( padding: EdgeInsets.fromLTRB(10,0,0,0), child:VTitleText(outLong, size: TextSize.large,)));

}
