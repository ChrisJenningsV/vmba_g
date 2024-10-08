import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vmba/components/vidButtons.dart';
import 'package:vmba/data/SystemColors.dart';
import 'package:vmba/data/models/models.dart';
import 'package:vmba/data/models/pax.dart';

import '../../Helpers/settingsHelper.dart';
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
  final ScrollController _controller = ScrollController();

  List<Pax>? paxlist;
  List<List<Pax>>? paxFltList;

  @override
  initState() {
    super.initState();
    paxlist = widget.paxList;
//    paxFltList = getPaxlist(gblPnrModel as PnrModel, journeyNo);
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
  void _animateToIndex(int index) {
    _controller.animateTo(
      index * 30,
      duration: Duration(seconds: 2),
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    // scroll to pax
    // scroll to selected
    if(gblSettings.wantNewSeats && gblCurPax > 0 ) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _animateToIndex(gblCurPax);
      });
    }

    return gblSettings.wantNewSeats ? NewPaxObj() :
     Wrap(
      children: renderPax(),
    );
  }
  Widget NewPaxObj() {
    double height = 80;
    if(paxlist!.length < 3 ) height = paxlist!.length * 40 - 15;
    return
      Container(
          margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
          padding: EdgeInsets.all(0), //EdgeInsets.fromLTRB(15, 10, 15, 10),
          height: height,
          width: 400,
          decoration: BoxDecoration(
            color: Colors.grey,
          border: Border.all(color: Colors.black, width: v2BorderWidth()),
          borderRadius: BorderRadius.all(
          Radius.circular(10.0)),
          ),
          child: Scrollbar(
            thumbVisibility: true,
            trackVisibility: true,
            thickness: 15,
            child:
    ListView.builder(
      controller: _controller,
      padding: EdgeInsets.all(0),
      shrinkWrap: true,
      itemCount: paxlist!.length,
      itemBuilder: (context, pax) {
        String name = paxlist![pax].name;
        if( paxlist![pax].selected == true) name += ' s';
        return ListTile(
          minVerticalPadding: 0,
          onTap: () {
            for(int i=0; i< paxlist!.length; i++) {
              paxlist![i].selected = false;
            };
            paxlist![pax].selected = true;
            gblCurPax = pax;
            setState(() {

            });
          },
         //tileColor: paxlist![pax].selected ? Colors.black : Colors.white,
         // selectedColor: selectedBackground,
         // textColor: paxlist![pax].selected ? Colors.white :Colors.black,
          selectedTileColor: selectedText,
          selected: paxlist![pax].selected,
          contentPadding: EdgeInsets.all(0),
          title:
        Container(
          height: 30,
          margin: EdgeInsets.fromLTRB(0, 0, 20, 0),
          padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
          color: paxlist![pax].selected ? Colors.black : Colors.white,
          child:Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              name,
              //textScaler: TextScaler.linear(.90),
              style: TextStyle(
                  color: paxlist![pax].selected ? Colors.white :Colors.black),
            ),
            Padding(padding: EdgeInsets.all(5)),
            seatButton(pax),
          ],
        )
        ),
        dense: true,

        visualDensity:VisualDensity(horizontal: 0, vertical: -4),
        );
      }
        ),
          )
    );
  }

  Widget seatButton(int pax){
    return  Container(

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
  }

  List<Widget> renderPax() {
    List<Widget> paxWidgets = [];
    // List<Widget>();
    for (var pax = 0; pax < paxlist!.length; pax++) {
      Widget seatNoButton = seatButton(pax);

      String name = paxlist![pax].name;
      if (name.length > 16) name = name.substring(0, 16) + '..';
      paxWidgets.add(new GestureDetector(
        child: new Container(
          height: 40,
          padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
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