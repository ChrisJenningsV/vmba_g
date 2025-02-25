
import 'package:flutter/material.dart';
import '../components/showDialog.dart';
import '../data/globals.dart';
import '../data/models/seatplan.dart';
import '../utilities/helper.dart';
import '../v3pages/v3Theme.dart';
import 'plan.dart';

// seat layouts / seat plans found at https://www.aerolopa.com/lm-e45


double seatHeight = 40;
double seatWidth = 40;
double vertSpace = 5;
double horzSpace = 5;
double aSpace = 20;
double seatsTop = 220;
double seatsLeft = 20;


List<Widget> AddSeats(BuildContext context, Widget Function(Seat? , bool, bool,SeatSize) hookUpSeat ){
  int rows = gblSeatplan!.seats.seat.last.sRow;
  int minCol = gblSeatplan!.getMinCol();
  int maxCol = gblSeatplan!.getMaxCol();

  List<Widget> list = [];
  List<Seat> seats = [];

  if( gblSeatPlanConfig != null ) {
    seatsTop = gblSeatPlanConfig!.top;
    seatsLeft = gblSeatPlanConfig!.left;
    seatHeight = gblSeatPlanConfig!.seatHeight;
    seatWidth = gblSeatPlanConfig!.aiselWidth;

    gblSeatPlanDef!.seatWidth = seatWidth;
    gblSeatPlanDef!.seatHeight = seatHeight;

    horzSpace = gblSeatPlanConfig!.seatHorzSpace;
    vertSpace = gblSeatPlanConfig!.seatVertSpace;

    logit('set custom seat plan config [$seatsTop]' );
  }

  // Existing Image Block
  bool iLoaded = true;
  Widget floorImg = Image.network('${gblSettings.gblServerFiles}/SeatPlans/${gblSeatplan!.seats.seatsFlt.sRef}.png',
    errorBuilder: (BuildContext context, Object obj,
        StackTrace? stackTrace) {
      logit('Cannot load image ${gblSeatplan!.seats.seatsFlt.sRef}.png');
      iLoaded = false;
      return Text('Cannot load image ${gblSeatplan!.seats.seatsFlt.sRef}.png', style: TextStyle(color: Colors.red));

    },// floor2.png',
    fit: BoxFit.fill,
    );
  if(  iLoaded == false ){
    // get default image
    floorImg = Image.asset('lib/assets/images/floor2.png');
  }
  list.add(floorImg);

  // dump
  if( gblSeatPlanDef != null ){
    gblSeatPlanDef!.dump();
    rows = gblSeatPlanDef!.maxRow;
  }

  logit('last row $rows');

  for (var indexRow = 1; indexRow <= rows; indexRow++) {
      seats = gblSeatplan!.getSeatsForRow(indexRow);
      // logit('ROW: $indexRow');
      for (var indexColumn = minCol; indexColumn <= maxCol; indexColumn++) {
        Seat? seat;
        bool found = false;
        seats.forEach((element) {
          if (element.sCol == indexColumn) {
            seat = element;
            found = true;
          }
        });

        if (seat != null && (seat!.sCellDescription == 'EmergencySeat' ||
            seat!.sCellDescription == 'Seat')) {
          //logit('s ${seat!.sCode} t:${seatsTop + (indexRow-3) * seatHeight + vertSpace}');
          bool selected = false;
          bool selectableSeat = true;
          if (gblSelectedSeats.contains(seat!.sCode)) {
            selectableSeat = false;
          }
          if (gblSelectedSeats != null && seat != null && seat!.sCode != '' &&
              gblSelectedSeats.contains(seat!.sCode)) {
            selected = true;
          }

          list.add(Positioned(
              left: seatsLeft + (indexColumn-minCol) * (seatWidth + horzSpace) + aSpace,
              top: seatsTop + (indexRow-3) * (seatHeight + vertSpace),
              child: hookUpSeat( seat, selected, selectableSeat, SeatSize.medium)
          ));
        }
      }
    }
  /*for( var i = 1 ; i < 5; i++ ) {
    list.add(Positioned(
      left: 100,
      top: seatsTop + i * seatHeight + vertSpace,
      child: dummySeat('${i}A', Colors.teal),
    ));
    list.add(Positioned(
      left: 100 + seatWidth + horzSpace,
      top: seatsTop + i * seatHeight + vertSpace,
      child: dummySeat('${i}B', Colors.grey),
    ));
    list.add(Positioned(
      left: 100+ 2* (seatWidth + horzSpace) + aSpace,
      top: seatsTop + i * seatHeight + vertSpace,
      child: dummySeat('${i}C', Colors.red),
    ));

    list.add(Positioned(
      left: 100 + 3* (seatWidth + horzSpace) + aSpace,
      top: seatsTop + i * seatHeight + vertSpace,
      child: dummySeat('${i}D', Colors.grey),
    ));
  }*/

  return list;
}

/*Widget clickableSeat(BuildContext context, Seat? seat, bool selected, SeatSize seatSize) {
  return GestureDetector(
    child: getSeat2(seat, selected, seatSize),
    onTap: () {
      String seatType = '';
      if (seat!.sCellDescription == 'EmergencySeat') {
        seatType = 'EmergencySeat';
      } else if (seat!.pRMSeat == true) {
        seatType = 'Restricted seat';
      }
      showVidDialog(context, 'Seat ${seat!.sCode} $seatType', '',
          type: DialogType.Custom, getContent: getContent,
          onComplete: () {
            Navigator.of(context).pop();
            widget.onChanged(paxlist!.list!);
          }
      );
*//*
      //if (selectableSeat && !selectedSeats.contains(seat!.sCode)) {
        selectPaxForSeat(context, seat!);
      //}
*//*
    },
  );
}*/
