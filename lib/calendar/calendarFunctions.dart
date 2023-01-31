
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vmba/Helpers/settingsHelper.dart';
import 'package:vmba/calendar/widgets/cannedFact.dart';
import 'package:vmba/components/vidGraphics.dart';
import 'package:vmba/data/globals.dart';

import '../chooseFlight/chooseFlightPage.dart';
import '../components/trText.dart';
import '../data/models/availability.dart';
import '../data/models/models.dart';
import '../utilities/helper.dart';
import 'flightPageUtils.dart';

class CalFlightItemWidget extends StatefulWidget {
  final void Function(BuildContext context, List<String> flt, List<Flt> outboundflts, String className) flightSelected;

  CalFlightItemWidget({Key key,this.newBooking, this.objAv, this.item, this.flightSelected, this.seatCount})
      : super(key: key);
  NewBooking newBooking;
  AvailabilityModel objAv;
  avItin item;
  int seatCount;
  //void flightSelected(List<String> list, List<Flt> flts, String class);


  _CalFlightItemWidgetState createState() => _CalFlightItemWidgetState();
}

class _CalFlightItemWidgetState extends State<CalFlightItemWidget> {

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return calFlightItem(context, widget.newBooking, widget.objAv, widget.item);
  }

  void goToClassScreen(BuildContext context,NewBooking newBooking, AvailabilityModel objAv, int index, List<Flt> flts) async {
    gblActionBtnDisabled = false;

    var selectedFlt = await Navigator.push(
        context,
        SlideTopRoute(
            page: ChooseFlight(
              classband: objAv.availability.classbands.band[index],
              flts: flts, //objAv.availability.itin[0].flt,
              seats: widget.seatCount,
            )));
    widget.flightSelected(context,  selectedFlt, flts, objAv.availability.classbands.band[index].cbname);
  }

  Widget pricebuttons(BuildContext context, NewBooking newBooking,AvailabilityModel objAv, List<Flt> item) {
    EdgeInsets pad = EdgeInsets.symmetric(vertical: 5,horizontal: 15);
    if( wantRtl()){
      pad = EdgeInsets.symmetric(vertical: 5,horizontal: 10);
    }
    if (item[0].fltav.pri.length > 3) {

      return Container(
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            //color: Colors.grey,
              border: Border(top: BorderSide(color: gblSystemColors.primaryHeaderColor, width: 2),
              )),
          child: Wrap(

              spacing: 8.0, //gap between adjacent chips
              runSpacing: 4.0, // gap between lines
              children: new List.generate(
                  item[0].fltav.pri.length,
                      (index) => GestureDetector(
                      onTap: () => {
                        item[0].fltav.fav[index] != '0'
                            ? goToClassScreen(context, newBooking, objAv, index, item)
                            : print('No av')
                      },
                      child: Chip(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5.0))),
                        padding: pad,
                        backgroundColor:
                        index.floor().isOdd ? gblSystemColors.accentColor :gblSystemColors.primaryButtonColor,
                        label: Column(
                          children: <Widget>[
                            TrText(
                                objAv.availability.classbands.band[index]
                                    .cbdisplayname ==
                                    'Fly Flex Plus'
                                    ? 'Fly Flex +'
                                    : objAv.availability.classbands.band[index]
                                    .cbdisplayname,
                                style: TextStyle(
                                    color: gblSystemColors
                                        .primaryButtonTextColor)),
                            item[0].fltav.fav[index] != '0'
                                ? new Text(
                              calenderPrice(
                                  item[0].fltav.cur[index],
                                  item
                                      .fold(
                                      0.0,
                                          (previous, current) =>
                                      previous +
                                          (double.tryParse(current
                                              .fltav.pri[index]) ??
                                              0.0) +
                                          (double.tryParse(current
                                              .fltav.tax[index]) ??
                                              0.0))
                                      .toStringAsFixed(2),
                                  item[0].fltav.miles[index]),
                              style: new TextStyle(
                                color: gblSystemColors
                                    .primaryButtonTextColor,
                                fontSize: 12.0,
                              ),
                            )
                                : new TrText('No Seats',
                                style: new TextStyle(
                                  color: gblSystemColors
                                      .primaryButtonTextColor,
                                  fontSize: 12.0,
                                )),

                            // Text(calenderPrice('NGN', '55000'),
                            //  style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      )))
          )
      );
    } else {
      MainAxisAlignment _mainAxisAlignment = MainAxisAlignment.spaceAround;
      if (item[0].fltav.pri.length == 2) {
        _mainAxisAlignment = MainAxisAlignment.spaceAround;
      } else if (item[0].fltav.pri.length == 3) {
        _mainAxisAlignment = MainAxisAlignment.spaceBetween;
      }
      return Container(
          padding: EdgeInsets.only(left: 10, right: 10, top: 5),
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            //color: Colors.grey,
              border: Border(top: BorderSide(color: gblSystemColors.primaryHeaderColor, width: 2),
              )),

          child: Row(
              mainAxisAlignment: _mainAxisAlignment,
              children: new List.generate(
                item[0].fltav.pri.length,
                    (index) => ElevatedButton(
                    onPressed: () {
                      item[0].fltav.fav[index] != '0'
                          ? goToClassScreen(context,newBooking,objAv, index, item)
                          : print('No av');
                    },
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5.0))), //RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                        primary:
                        gblSystemColors.primaryButtonColor,
                        padding: pad ), //new EdgeInsets.all(5.0)),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: new Column(
                        children: <Widget>[
                          new Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              new TrText(
                                objAv.availability.classbands.band[index]
                                    .cbdisplayname ==
                                    'Fly Flex Plus'
                                    ? 'Fly Flex +'
                                    : objAv.availability.classbands.band[index]
                                    .cbdisplayname,
                                style: new TextStyle(
                                  color: gblSystemColors
                                      .primaryButtonTextColor,
                                  fontSize: 16.0,
                                ),
                              ),
                            ],
                          ),
                          new Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              item[0].fltav.fav[index] != '0'
                                  ? new Text(
                                calenderPrice(
                                    item[0].fltav.cur[index],
                                    item
                                        .fold(
                                        0.0,
                                            (previous, current) =>
                                        previous +
                                            (double.tryParse(current
                                                .fltav.pri[index]) ??
                                                0.0) +
                                            (double.tryParse(current
                                                .fltav.tax[index]) ??
                                                0.0))
                                        .toStringAsFixed(2),
                                    item[0].fltav.miles[index]),
                                style: new TextStyle(
                                  color: gblSystemColors
                                      .primaryButtonTextColor,
                                  fontSize: 12.0,
                                ),
                              )
                                  : new TrText('No Seats',
                                  style: new TextStyle(
                                    color: gblSystemColors
                                        .primaryButtonTextColor,
                                    fontSize: 12.0,
                                  )),
                            ],
                          )
                        ],
                      ),
                    )),
              )
          )
      );
    }
  }


  Widget calFlightItem(BuildContext context,NewBooking newBooking, AvailabilityModel objAv, avItin item) {
    List <Widget> topList = [];
    List <Widget> innerList = [];

    innerList.add(flightRow(context, item));

    if(gblSettings.wantCanFacs && item.flt.first.fltdet.canfac.fac.isNotEmpty) {
      innerList.add(Divider());
      innerList.add(CannedFactWidget(flt: item.flt));
    }
    if(! wantPageV2()){
      innerList.add(infoRow(context, item));
    }

    topList.add(flightTopRow(item));
    topList.add(Container(
      // margin: EdgeInsets.only(top: 10, bottom: 10.0, left: 5, right: 5),
        padding: EdgeInsets.all(10),
        child: Column(
          children: innerList,
        )
    ));
    //new Divider(),

    topList.add(pricebuttons(context, newBooking,objAv, item.flt));

    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: gblSystemColors.primaryHeaderColor, width: 2),
          borderRadius: BorderRadius.all(
              Radius.circular(15.0)),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 3,
              blurRadius: 3,
              offset: Offset(0, 4), // changes position of shadow
            ),]

      ),

      margin: EdgeInsets.only(top: 10, bottom: 10.0, left: 5, right: 5),
      padding: EdgeInsets.only(
          left: 0, right: 0, bottom: 8.0, top: 8.0),
      child: Column(
          children:  topList
      ),
    );
  }

}


















Widget flightTopRow(avItin item)
{
  return Container(
    padding: EdgeInsets.only(top: 2, bottom: 2, left: 10, right: 0),
    decoration: BoxDecoration(
      border: Border(bottom: BorderSide(color: gblSystemColors.primaryHeaderColor, width: 2),
    )
    ),
      child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(translate('Flight No:') + ' ' + item.flt[0].fltdet.airid + item.flt[0].fltdet.fltno),
        Padding(padding: EdgeInsets.all(2)),
        (item.flt[0].fltdet.airid == gblSettings.aircode) ?
        Image.asset('lib/assets/$gblAppTitle/images/logo.png', height: 30,)
            :Container()
        ]
    ),
  );
} 

Widget flightRow(BuildContext context, avItin item) {
  if( wantPageV2()){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            getDate(item.flt[0].time.ddaylcl),
            getTime(item.flt.first.time.dtimlcl),
            getAirport(item.flt.first.dep),
            getTerminal(item.flt.first, true),
          ],
        ),
        Column(children: [
          new RotatedBox(
              quarterTurns: 1,
              child: new Icon(
                Icons.airplanemode_active,
                size: 40.0,
              )),
          Text(item.journeyDuration()),
          getConnections(context, item),
        ]),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            getDate(item.flt.last.time.adaylcl),
            getTime(item.flt.last.time.atimlcl),
            getAirport(item.flt.last.arr),
            getTerminal(item.flt.first, false),
          ],
        )
      ],
    );
  } else {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            getDate(item.flt[0].time.ddaylcl),
            getTime(item.flt.first.time.dtimlcl),
            getAirport(item.flt.first.dep),
            getTerminal(item.flt.first, true),
          ],
        ),
        Column(children: [
          new RotatedBox(
              quarterTurns: 1,
              child: new Icon(
                Icons.airplanemode_active,
                size: 60.0,
              )),
        ]),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            getDate(item.flt.last.time.adaylcl),
            getTime(item.flt.last.time.atimlcl),
            getAirport(item.flt.last.arr),
            getTerminal(item.flt.first, false),
          ],
        )
      ],
    );
  }
}

Widget getDate(String dt){
  return Text(getIntlDate(
      'EEE dd MMM', DateTime.parse(dt)),

      style: new TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.w300));
}

Widget getTime(String tm) {
  String formattedTm = tm.substring(0, 5);
  if( gblSettings.avTimeFormat.contains(':'))
    {

    } else {
    formattedTm = formattedTm.replaceAll(':', '');
  }
  if( wantRtl()) {

    return Text(getIntlDate('HHmm', DateTime.parse('2022-11-12 ' + tm)),
        style: new TextStyle(
            fontSize: 36.0,
            fontWeight: FontWeight.w700));

  } else {
    return Text(formattedTm,
        style: new TextStyle(
            fontSize: 36.0,
            fontWeight: FontWeight.w700));
  }
}

Widget getAirport(String code, {double fontSize, FontWeight fontWeight}) {
  if( fontSize == null ) fontSize = 16;
  if( fontWeight == null ) fontWeight =  FontWeight.w300;
  return FutureBuilder(
    future: cityCodeToName(
      code,
    ),
    initialData: code.toString(),
    builder: (BuildContext context,
        AsyncSnapshot<String> text) {
      return TrText(translate(text.data),
          style: new TextStyle(
              fontSize: fontSize,
              fontWeight: fontWeight),
          variety: 'airport', noTrans: true);
    },
  );

}
Widget getTerminal(Flt flt, bool depart){
  if( gblSettings.wantTerminal == false ) return Container();
  if( depart == true &&  (flt.fltdet.depterm == null || flt.fltdet.depterm.isEmpty) ) return Container();
  if( depart == false &&  (flt.fltdet.arrterm == null || flt.fltdet.arrterm.isEmpty)) return Container();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
          TrText('Terminal'),
          Padding(padding: EdgeInsets.only(left: 10)),
          Text( depart ? flt.fltdet.depterm : flt.fltdet.arrterm, textScaleFactor: 1.5,),
        ]);
}


Widget infoRow(BuildContext context, avItin item ) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: <Widget>[
      Column(children: [
        Row(
          children: <Widget>[
            Icon(Icons.timer),
            Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: Text(item.journeyDuration()),
            )
          ],
        )
      ]),
      Column(children: [
        Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: Text(item.flt[0].fltdet.airid + item.flt[0].fltdet.fltno),
            )
          ],
        )
      ]),
      Column(
        children: <Widget>[
          getConnections(context, item),
        ],
      )
    ],
  );
}
Widget getConnections(BuildContext context, avItin item) {
  if (item.flt.length > 1) {
    return GestureDetector(
      onTap: () =>
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                  actions: <Widget>[
                    new TextButton(
                      child: new Text("OK"),
                      onPressed: () {
                        Navigator.of(context)
                            .pop();
                      },
                    ),
                  ],
                  title: new TrText('Connections'),
                  content: Column(
                      mainAxisSize:
                      MainAxisSize.min,
                      children: (item.flt.map(
                            (f) =>
                            Container(
                              child: Row(
                                children: <Widget>[
                                  Text(f.dep),
                                  Padding(
                                    padding:
                                    const EdgeInsets
                                        .all(4.0),
                                    child: Text(DateFormat(
                                        'kk:mm')
                                        .format(DateTime.parse(f
                                        .time
                                        .ddaylcl +
                                        ' ' +
                                        f.time
                                            .dtimlcl))
                                        .toString()),
                                  ),
                                  Padding(
                                    padding:
                                    const EdgeInsets
                                        .all(4.0),
                                    child:
                                    new RotatedBox(
                                        quarterTurns:
                                        1,
                                        child:
                                        new Icon(
                                          Icons
                                              .airplanemode_active,
                                          size:
                                          20.0,
                                        )),
                                  ),
                                  Padding(
                                    padding:
                                    const EdgeInsets
                                        .all(4.0),
                                    child:
                                    Text(f.arr),
                                  ),
                                  Text(DateFormat(
                                      'kk:mm')
                                      .format(DateTime.parse(f
                                      .time
                                      .ddaylcl +
                                      ' ' +
                                      f.time
                                          .atimlcl))
                                      .toString()),
                                ],
                              ),
                            ),
                      )).toList()));
            },
          ),
      child: Row(
        children: <Widget>[
          new Text(
            item.flt.length == 2
                ? '${item.flt.length - 1} connection'
                : '${item.flt.length - 1} connections',
            style: new TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.w300),
          ),
          new Icon(Icons.expand_more),
        ],
      ),
    );
  } else {
    return   TrText(  'Direct Flight' );
}

}


Widget noFlightsFound(){
  return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          TrText(
            'Sorry no flights found',
            style: TextStyle(fontSize: 14.0),
          ),
          TrText(
            'Try search for a different date',
            style: TextStyle(fontSize: 14.0),
          ),
        ],
      ));
}
Widget getCalDay(Day item, String action, DateTime date, DateTime hideBeforeDate, {void Function() onPressed} ) {
  List <Widget> list = [];
  bool showNoFlightIcon = false;
  if( gblRedeemingAirmiles== false && item.amt.length == 0 ){
    if( wantPageV2()) {
      showNoFlightIcon = true;
    }
  }


  list.add(Text(getIntlDate('EEE dd', DateTime.parse(item.daylcl)),
    //new DateFormat('EEE dd').format(DateTime.parse(item.daylcl)),
    style: TextStyle(
        fontSize: 14,
        color: isSearchDate(
            DateTime.parse(item.daylcl),
            date)
            ? Colors.white
            : Colors.black),
  ));

  if( showNoFlightIcon ){
    list.add(vidNoFlights());
  } else {
    list.add(TrText('from', style: TextStyle(fontSize: 14,
        color: isSearchDate(DateTime.parse(item.daylcl), date) ? Colors.white
            : Colors.black),
    ));

    list.add(Text(
      calenderPrice(item.cur, item.amt, item.miles),
      //textScaleFactor: 1.0,
      style: TextStyle(
          fontSize: 14,
          color: isSearchDate(
              DateTime.parse(item.daylcl),
              date)
              ? Colors.white
              : Colors.black),
    ));
  }

if( wantRtl()) {
  return SingleChildScrollView(
      child: Container(
        decoration: new BoxDecoration(
            border: new Border.all(color: Colors.black12),
            color: !isSearchDate(DateTime.parse(item.daylcl),
                date)
                ? Colors.white
                : gblSystemColors.accentButtonColor //Colors.red,
        ),
        width: DateTime.parse(item.daylcl).isBefore(hideBeforeDate)
            ? 0
            : 120.0,
        child: new TextButton(
            onPressed: onPressed,
            child: new Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: list)),
      ));
} else {
  return Container(
        decoration: new BoxDecoration(
            border: new Border.all(color: Colors.black12),
            color: !isSearchDate(DateTime.parse(item.daylcl),
                date)
                ? Colors.white
                : gblSystemColors.accentButtonColor //Colors.red,
        ),
        width: DateTime.parse(item.daylcl).isBefore(hideBeforeDate)
            ? 0
            : 120.0,
        child: new TextButton(
            onPressed: onPressed,
            child: new Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: list)),
      );
}
}



/*

void flightSelected(BuildContext context, NewBooking newBooking, List<String> flt, List<Flt> outboundflts, String className) {
  if (flt != null) {
    print(flt);
    if (flt != null && flt.length > 0) {
      newBooking.outboundflight = flt;
      newBooking.outboundflts = outboundflts;
      newBooking.outboundClass = className;
    }

    hasDataConnection().then((result) async {
      if (result == true) {
        if (newBooking.isReturn &&
            newBooking.outboundflight[0] != null) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ReturnFlightSeletionPage(
                    newBooking: newBooking,
                    outboundFlight: outboundflts.last,
                  )));
        } else if (newBooking.outboundflight[0] != null) {

          if( gblSettings.wantProducts) {
            // first save new booking
            gblError = '';
            PnrModel pnrModel = await searchSaveBooking(
                newBooking);
            gblPnrModel = pnrModel;
            refreshStatusBar();
            // go to options page
            if (gblError != '') {

            } else {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PassengerDetailsWidget(
                        newBooking: newBooking,
                        pnrModel:  pnrModel,)));


            }

          } else {

            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        FlightSelectionSummaryWidget(
                            newBooking: newBooking)));
          }
        }
      } else {
        //showSnackBar(translate('Please, check your internet connection'));
        noInternetSnackBar(context);
      }
    });
  }
}

*/
