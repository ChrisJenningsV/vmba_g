

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../data/globals.dart';
import '../../../data/models/seatplan.dart';
import '../../../v3pages/v3Theme.dart';
import '../mmb/widgets/seatplan.dart';



Widget getSeatKey2() {
  List<Widget> seatList = [];
  seatList.add(seatRow('1X',  SeatType.selected, 'Selected Seat', SeatSize.large));

  seatList.add(seatRow('1X',  SeatType.emergency , 'Emergency Seat', SeatSize.large));
  seatList.add(seatRow('1X',  SeatType.available, 'Available Seat (suitable for infants)', SeatSize.large ));
  seatList.add(seatRow('1X',  SeatType.availableRestricted, 'Available Seat (unsuitable for infants)', SeatSize.large ));
  seatList.add(seatRow('1X',  SeatType.occupied, 'Occupied Seat' , SeatSize.large));


  return Card(
    margin: EdgeInsets.fromLTRB(10, 15, 10, 0),
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
              color: gblSystemColors.seatPlanBackColor,
              child:
              ExpansionTile(
                //backgroundColor: Colors.white,
                dense: true,
                iconColor: gblSystemColors.fltText,
                collapsedIconColor: gblSystemColors.fltText,
                onExpansionChanged: (selected) {

                },
                childrenPadding: EdgeInsets.all(0),
                initiallyExpanded: gblSettings.wantSeatKeyExpanded,
                tilePadding: EdgeInsets.fromLTRB(10, -10, 10, 0),
                title: VTitleText('Seat Key', color: Colors.white, translate: true, size: TextSize.large,),
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


Widget seatRow(String seatNo,  SeatType seatType, String text, SeatSize seatSize  ){
  return Padding( padding: EdgeInsets.fromLTRB(10, 5, 20, 5),
      child: Row( children: [ seat2(seatNo, seatType,seatSize ),
        Padding(padding: EdgeInsets.all(5)),
        VTitleText(text, size: TextSize.small,)]
      )
  );
}


Widget seat2(String seatNo,  SeatType seatType, SeatSize seatSize ) {
  Color? seatClr = Colors.grey;
  Color? seatTxtColor = Colors.black;
//  logit(' seat $seatNo t=$seatType');

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
    case SeatType.unavailable:
      seatClr = Colors.grey;
      if( gblSystemColors.seatPlanColorUnavailable != null ) seatTxtColor = gblSystemColors.seatPlanColorUnavailable;
    case  SeatType.blank:
      seatClr = Colors.grey;
      if( gblSystemColors.seatPlanColorUnavailable != null ) seatTxtColor = gblSystemColors.seatPlanColorUnavailable;

    }

  Widget body =  VTitleText(seatNo,size:  TextSize.small,color: seatTxtColor);
  if( seatSize == SeatSize.small) body =  VBodyText(seatNo,size:  TextSize.small,color: seatTxtColor);
  if( seatType == SeatType.occupied){
    List<Widget> list = [];
    //list.add(Icon(Icons.person,  size: 30,color: Colors.grey.shade300,));
    //list.add(  Positioned(  left: 5,  top: 5,  child: CustomPaint(painter: LinePainter())  ));
    list.add(Align( alignment: Alignment.center, child:Icon(Icons.close, color: Colors.grey.shade400, size: 45,)));
    list.add(Align( alignment: Alignment.center, child: VTitleText(seatNo,size:  TextSize.small, color: Colors.black,)));
    body = Stack( children: list,);
  }

  if( gblSettings.seatStyle != null &&  gblSettings.seatStyle == 'line'){
    return Container(
      padding: EdgeInsets.all(0),
      alignment: Alignment.center,
      height: gblSeatPlanDef!.seatHeight,
      width: gblSeatPlanDef!.seatWidth,
      decoration: BoxDecoration(
          border: Border(
            top: BorderSide(width: 1.0, color: seatClr as Color),
            left: BorderSide(width: 1.0, color: seatClr as Color),
            right: BorderSide(width: 1.0, color: seatClr as Color),
            bottom: BorderSide(width: 15.0, color: seatClr as Color),
          ),
          borderRadius: BorderRadius.all(
            Radius.circular(5.0)),
//        color: seatClr,
      ),
      child: body,
    );
  }
  return Container(
    //color: seatClr,
    padding: EdgeInsets.all(0),
    alignment: Alignment.center,
    height: gblSeatPlanDef!.seatHeight,
    width: gblSeatPlanDef!.seatWidth,
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey, width: 1),
      borderRadius: BorderRadius.all(
          Radius.circular(5.0)),
      color: seatClr,
    ),
    child: body,
  );
}