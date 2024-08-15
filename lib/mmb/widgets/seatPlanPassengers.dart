import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:vmba/components/vidButtons.dart';
import 'package:vmba/data/SystemColors.dart';
import 'package:vmba/data/models/models.dart';
import 'package:vmba/data/models/pax.dart';

import '../../calendar/bookingFunctions.dart';
import '../../components/trText.dart';
import '../../data/globals.dart';
import '../../data/models/vrsRequest.dart';
import '../../data/smartApi.dart';
import '../../utilities/helper.dart';

class SeatPlanPassengersWidget extends StatefulWidget {
  SeatPlanPassengersWidget(
      {Key key= const Key("seatplanpax_key"), this.onChanged, this.paxList, this.segNo = '0', required this.loadingData, required this.dataLoaded})
      : super(key: key);
  final List<Pax>? paxList;
  final String segNo;
  //final SystemColors systemColors;
  final ValueChanged<List<Pax>>? onChanged;
  void Function(String msg) loadingData;
  void Function() dataLoaded;

  _SeatPlanPassengersWidgetState createState() =>
      _SeatPlanPassengersWidgetState();
}

class _SeatPlanPassengersWidgetState extends State<SeatPlanPassengersWidget> {
  static Color selectedBackground = Colors.black;
  static Color selectedText = Colors.green;
  static Color unselectedBackground = Colors.white;
  static Color unselectedText = Colors.black;

  List<Pax>? paxlist;

  @override
  initState() {
    super.initState();
    paxlist = widget.paxList;
    selectedBackground = gblSystemColors.primaryButtonColor;
    selectedText = gblSystemColors.primaryButtonTextColor!;
  }

  void _toggleSelectedPax(int _id) {
    setState(() {
      paxlist!.forEach((element) => element.selected = false);
      paxlist![_id - 1].selected = true;
    });
    if (widget.onChanged != null) {
      widget.onChanged!(paxlist!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: renderPax(),
    );
  }

  List<Widget> renderPax() {
    List<Widget> paxWidgets = [];
    // List<Widget>();
    for (var pax = 0; pax < paxlist!.length; pax++) {
      Widget seatNoButton = Container(
        // padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
        //color: Colors.white,
          width: 55,
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black)
          ),

          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(padding: EdgeInsets.all(1)),
              Text(
                paxlist![pax].seat == null || paxlist![pax].seat == ''
                    ? '' /*translate('Select')*/
                    : paxlist![pax].seat,
                //textScaler: TextScaler.linear(1.25),
                style: TextStyle(color: Colors.black),
/*
                color: paxlist![pax].selected == true
                    ? selectedText
                    : unselectedText),
*/
              ),
              (paxlist![pax].seat == null || paxlist![pax].seat == '')
                  ? Container()
                  :
              Align(alignment: Alignment.topRight,
                  child: vidIconButton(context, paxNo: pax,
                      segNo: int.parse(widget.segNo) ,
                      onPressed: (context, paxNo, segNo) {
                        logit('removeSeat pax$paxNo seg$segNo');
                        smartRemoveSeat(paxNo, segNo);
                      },
                      clrIn: Colors.red,
                      icon: Icons.close,
                      size: 20
                  ))
            ],
          ))
      ;

      String name = paxlist![pax].name;
      if (name.length > 16) name = name.substring(0, 16) + '..';
      paxWidgets.add(new GestureDetector(
        child: new Container(
          height: 40,
          color: paxlist![pax].selected == true
              ? selectedBackground
              : unselectedBackground,
          width: MediaQuery
              .of(context)
              .size
              .width * 0.5,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                name,
                textScaler: TextScaler.linear(.90),
                style: TextStyle(
                    color: paxlist![pax].selected == true
                        ? selectedText
                        : unselectedText),
              ),
              Padding(padding: EdgeInsets.all(5)),
              seatNoButton,
            ],
          ),
        ),
        onTap: () => _toggleSelectedPax(paxlist![pax].id),
      ));
    }
    if (!paxlist!.length.isEven) {
      //add blank pax box
      paxWidgets.add(Container(
          color: unselectedBackground,
          width: MediaQuery
              .of(context)
              .size
              .width * 0.5,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Text(''),
              Text(''),
            ],
          )));
    }

    return paxWidgets;
  }


  smartRemoveSeat(int paxNo, int segNo) async {
    gblPayAction = 'RELEASESEAT';
    SeatRequest seat = new SeatRequest();
    gblBookSeatCmd = '';
    seat.paxlist = null;
    seat.journeyNo = 0;
    seat.afxNo = "0";
    seat.rloc = gblPnrModel!.pNR.rLOC;

    // find afx no
    if(gblPnrModel != null && gblPnrModel!.pNR.aPFAX.aFX != null ){
      gblPnrModel!.pNR.aPFAX.aFX.forEach((afx) {
        if( afx.pax == (paxNo+1).toString() && afx.seg == (segNo+1).toString() ){
          seat.afxNo = afx.line;
          logit('release line ${afx.line} seat ${afx.seat}');
        }
      });
    }

    if( seat.afxNo == "0" ){
      // not found, so no saved yet
      paxlist![paxNo].seat = '';
      setState(() {

      });
      return;
    }

    String data =  json.encode(seat);


    try{
      // let server do the work
 //     widget.loadingData(translate('Releasing Seat...'));
      String reply = await callSmartApi('RELEASESEAT', data);
      Map<String, dynamic> map = json.decode(reply);
      SeatReply seatRs = new SeatReply.fromJson(map);
      if( seatRs.reply != null && seatRs.reply != ''){
        showstatusMessage(translate('Seat released.'), context);
        //gblPnrModel!.loadFromString(seatRs.reply);
        MmbBooking _mmbBooking = new MmbBooking();
        gblPnrModel!.reloadAndSave(gblPnrModel!.pNR.rLOC, _mmbBooking, () { });
        // ok
        paxlist![paxNo].seat = '';
 //       widget.dataLoaded();
        setState(() {        });

        // refresh the my booking page
        refreshMmbBooking();
      }
    } catch(e) {
      widget.dataLoaded();
      print(e.toString());
    }
  }
}