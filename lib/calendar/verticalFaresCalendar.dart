
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vmba/calendar/calendarFunctions.dart';
import 'package:vmba/calendar/returningFlightPage.dart';
import 'package:vmba/components/vidButtons.dart';

import '../FlightSelectionSummary/FlightSelectionSummaryPage.dart';
import '../Helpers/settingsHelper.dart';
import '../Products/productFunctions.dart';
import '../chooseFlight/chooseFlightPage.dart';
import '../components/showDialog.dart';
import '../components/trText.dart';
import '../data/globals.dart';
import '../data/models/availability.dart';
import '../data/models/models.dart';
import '../data/models/pnr.dart';
import '../passengerDetails/passengerDetailsPage.dart';
import '../utilities/helper.dart';
import '../utilities/messagePages.dart';
import '../utilities/timeHelper.dart';
import '../utilities/widgets/CustomPageRoute.dart';
import '../v3pages/v3Theme.dart';
import 'bookingFunctions.dart';
import 'flightPageUtils.dart';


class VerticalFaresCalendar  extends StatefulWidget {
  AvailabilityModel objAv;
  NewBooking newBooking;
  void Function(bool ) loadData;
  bool isReturnFlight;
  void Function() showProgress;

  VerticalFaresCalendar({required this.newBooking, required this.objAv, required this.loadData, required this.showProgress, this.isReturnFlight = false }) ;

  _VerticalFaresCalendarState createState() => new _VerticalFaresCalendarState();

}
class _VerticalFaresCalendarState extends State<VerticalFaresCalendar> {
  ScrollController _scrollController = ScrollController();
  int selectedFlt = 0;
  int expandedFlt = 0;
  int selectedFare = -1;


  get flightSelected => null;
  List<ExpansionTileController> _controllerList = [];

  @override
  void initState() {
    super.initState();
    double animateTo = 250;
    DateTime _departureDate = DateTime.parse(
        DateFormat('y-MM-dd').format(
            widget.newBooking.departureDate as DateTime));
    DateTime _currentDate =
    DateTime.parse(DateFormat('y-MM-dd').format(getGmtTime()));

    int calenderWidgetSelectedItem = 0;
    // count flights
    if (widget.objAv.availability.cal != null &&
        widget.objAv.availability.cal?.day != null) {
      for (var f in widget.objAv.availability.cal!.day) {
        if (DateTime.parse(f.daylcl).isAfter(_currentDate) ||
            isSearchDate(DateTime.parse(f.daylcl), _departureDate)) {
          calenderWidgetSelectedItem += 1;
          if (isSearchDate(DateTime.parse(f.daylcl), _departureDate)) {
            break;
          }
        }
      }
    }

    if (calenderWidgetSelectedItem == 0 || calenderWidgetSelectedItem == 1) {
      animateTo = 0;
    } else if (calenderWidgetSelectedItem == 2) {
      animateTo = 150;
    }
    // scroll control for cal day bar
    WidgetsBinding.instance.addPostFrameCallback((_) =>
        _scrollController.animateTo(animateTo,
            duration: new Duration(microseconds: 1), curve: Curves.ease));
    // what is expanded and selected
    if (widget.objAv != null && widget.objAv.availability.itin != null &&
        widget.objAv.availability.itin!.length == 1) {
      selectedFlt = 1;
      expandedFlt = 1;
    } else {
      selectedFlt = 1;
    }
    if(  widget.objAv != null &&  widget.objAv.availability != null &&  widget.objAv.availability.itin != null ) {
      widget.objAv.availability.itin!.forEach((element) {
        _controllerList.add(new ExpansionTileController());
      });
    }
  }

//Widget verticalFaresCalendar()

  @override
  Widget build(BuildContext context) {
    EdgeInsets mar = EdgeInsets.fromLTRB(10, 10, 0, 10);

    return new Column(
      children: <Widget>[
        new Container(
          //margin: EdgeInsets.symmetric(vertical: 1.0),
          margin: mar,
          //height: 70.0,
          constraints: new BoxConstraints(
            minHeight: 65.0,
            maxHeight: 80.0,
          ),
          child: getCalenderDays(widget.objAv, widget.newBooking),
        ),
        new Expanded(
          child: flightList(widget.objAv),
        ),
      ],
    );
  }

  Widget getCalenderDays(AvailabilityModel objAv, NewBooking newBooking) {
    if (objAv != null && objAv.availability.cal != null &&
        objAv.availability.cal!.day != null) {
      return new ListView(
          shrinkWrap: true,
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          children: objAv.availability.cal!.day
              .map(
                (item) =>
                getCalDay(item, 'out', widget.isReturnFlight ? newBooking.returnDate as DateTime : newBooking.departureDate as DateTime,
                    DateTime.parse(DateFormat('y-MM-dd').format(getGmtTime())),
                    onPressed: () =>
                    {
                      hasDataConnection().then((result) {
                        if (result == true) {
                          logit('changeSearchDate ${item.daylcl}');
                          _changeSearchDate(DateTime.parse(item.daylcl));
                        } else {
//                    noInternetSnackBar(context);
                        }
                      })
                    }),

          )
              .toList());
    } else {
      return new TrText('No Calender results');
    }
  }

  _changeSearchDate(DateTime newDate) {
    selectedFlt = 0;
    expandedFlt = 0;
    selectedFare = -1;

    // collapse all fares
    try {
      _controllerList.forEach((element) {
        element.collapse();
      });
    } catch (e) {}


    setState(() {
      if(widget.isReturnFlight) {
        this.widget.newBooking.returnDate = newDate;
        print(this.widget.newBooking.returnDate.toString());

      } else {
        this.widget.newBooking.departureDate = newDate;
        print(this.widget.newBooking.departureDate.toString());
      }
      widget.loadData(true);
    });
  }

  Widget flightList(AvailabilityModel objAv) {
    if (objAv != null && objAv.availability.itin != null &&
        objAv.availability.itin!.length > 0) {
      int fltNo = 1;
      List<Widget> list = [];
      objAv.availability.itin!.forEach((item) {
        //(objAv.availability.itin!.map((item) {
        list.add(flight(item, fltNo));
        fltNo ++;
      });

      return new
      ListView(
          scrollDirection: Axis.vertical,
          children: list);
    } else {
      return noFlightsFound();
    }
  }

  Widget flight(AvItin item, int fltNo) {
/*
    int seatCount = widget.newBooking.passengers.adults +
        widget.newBooking.passengers.youths +
        widget.newBooking.passengers.seniors +
        widget.newBooking.passengers.students +
        widget.newBooking.passengers.children;
*/


    return Card(
      color: selectedFlt == fltNo
          ? gblSystemColors.selectedFlt
          : gblSystemColors.unselectedFlt,
      elevation: 3,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(5))
      ),
      child: ClipPath(
        child: Container(
          decoration: BoxDecoration(
              border: Border(top: BorderSide(
                  color: Colors.grey.shade200, width: 0))),
          //           height: 100,
          width: double.infinity,
          child:

          ExpansionTile(
              iconColor: gblSystemColors.fltText,
              collapsedIconColor: gblSystemColors.fltText,
              /*  trailing: Icon(
                Icons.keyboard_arrow_down,
                color: Colors.green,
              ),*/
              controller: _controllerList[fltNo - 1],
              onExpansionChanged: (selected) {
                if (selected == true) {
                  //logit('Select $fltNo');
                  selectedFlt = fltNo;
                  expandedFlt = fltNo;
                  selectedFare = -1;
                  // collapse other tiles
                  int index = 1;
                  _controllerList.forEach((element) {
                    if (index == fltNo) {

                    } else {
                      element.collapse();
                    }
                    index ++;
                  });
                  setState(() {

                  });
                } else {
                  setState(() {

                  });
                }
              },
              //backgroundColor: Colors.grey.shade200,
              //tilePadding: EdgeInsets.all(0),
              childrenPadding: EdgeInsets.all(0),
//        backgroundColor:  Colors.blue,
              initiallyExpanded: expandedFlt == fltNo,
              title: flightTitle(item, fltNo),
              children: [ Container(
                  color: Colors.grey.shade200,
                  child: getFareList(item, fltNo))
              ]
          ),
        ),
        clipper: ShapeBorderClipper(shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5))),
      ),

    );
  }

  Widget getFareList(AvItin item, int fltNo) {
    List<Widget> list = [];

    List<String>? prices = item.flt[0].fltav.pri;
    int curFare = 0;
    prices?.forEach((flt) {
      Color bgClr = Colors.white;
      if (gblSystemColors.fareColors != null &&
          gblSystemColors.fareColors!.length > curFare) {
        bgClr = gblSystemColors.fareColors![curFare];
      }
      if (fltNo == selectedFlt && curFare == selectedFare)
        bgClr = gblSystemColors.selectedFare!;
      list.add(Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                  Radius.circular(5.0))),
          color: bgClr,
          child: getFare(item, fltNo, curFare)));
      curFare += 1;
    });

    return Column(
        children: list
    );
  }

  Widget getFare(AvItin item, int curFltNo, int curFare) {
    String? name = widget.objAv.availability.classbands?.band![curFare]
        .cbdisplayname;
    int noAv = getAvalability(item.flt, curFare);
    double upgradePrice = 0;
    Color clr = Colors.black;
    if (curFltNo == selectedFlt && curFare == selectedFare) {
      clr = gblSystemColors.selectedFareText!;
    } else {
      clr = gblSystemColors.defaultFaretext!;
    }
    //   logit('fltNo $curFltNo index $index');

    int fltNo = 1;
    int len = item.flt[fltNo - 1].fltav.pri!.length;
    String cur = '';
    if (noAv > 0 && curFare > 0 &&
        curFare <= item.flt[fltNo - 1].fltav.pri!.length) {
      //logit('a');
      cur = item.flt[fltNo - 1].fltav.cur![0];
      if (item.flt[fltNo - 1].fltav.pri![curFare] != '' &&
          item.flt[fltNo - 1].fltav.pri![curFare - 1 ] != '') {
        //logit('b');
        if (double.parse(item.flt[fltNo - 1].fltav.pri![curFare]) >
            double.parse(item.flt[fltNo - 1].fltav.pri![curFare - 1])) {
          //logit('c');
          if( gblSettings.wantUpgradePrices) {
            upgradePrice =
                double.parse(item.flt[fltNo - 1].fltav.pri![curFare]) -
                    double.parse(item.flt[fltNo - 1].fltav.pri![curFare - 1]);
          } else {
            upgradePrice = 0;
          }
        }
      }
    }
//    logit('index $index upgrade $upgradePrice');

    if (name == 'Fly Flex Plus') name = 'Fly Flex +';

    if (noAv == 0) return Container();

    return InkWell(
        onTap: () {
//          logit('clicketty');
          setState(() {
            selectedFare = curFare;
          });
          _GoToNextPage(item,
              widget.objAv.availability.classbands?.band![curFare] as Band);
        },
        child: Padding(
            padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    VTitleText(name as String, color: clr,),
                    Padding(padding: EdgeInsets.all(5)),
                    curFare == 0 || upgradePrice == 0
                        ? getPrice(item, curFltNo, curFare)
                        : Container(color: Colors.black,
                      padding: EdgeInsets.all(5),
                      child: Column(
                        children: [
                          fltText('Upgrade from'),
                          fltText(calenderPrice(
                              cur, upgradePrice.round().toString(), '')),
                        ],
                      ),
                    ),
                  ],
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      vidTextButton(
                          context, 'View details', _onPressedViewDetails,
                          p1: curFare, p3: name),
                      Padding(padding: EdgeInsets.all(5)),
                      /*curFare == 0 || upgradePrice == 0
                          ? Container()
                          : Container(color: Colors.black,
                        padding: EdgeInsets.all(5),
                        child: Column(
                          children: [
                            fltText('Upgrade from'),
                            fltText(calenderPrice(
                                cur, upgradePrice.round().toString(), '')),
                          ],
                        ),
                        ),
                       */
                    ]
                ),
                V3Divider(),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      fareText('Available', curFltNo, curFare),
                      Padding(padding: EdgeInsets.all(5)),
                      fareText('Select', curFltNo, curFare),
                    ]
                ),
              ],
            )
        )
    );
  }

  void _onPressedFlightDetails({int? p1, int? p2, String? p3}) async {
    gblActionBtnDisabled = false;
    int fltIndex = p1! - 1;

    AvItin itin = widget.objAv.availability.itin![fltIndex];
    // title
    String route = cityCodetoAirport(itin.flt.first.dep) + ' to ' + cityCodetoAirport(itin.flt.last.arr);

    List<Widget> list = [];
    String date = itin.departureDateLocalLong();
    list.add(Align( alignment: Alignment.topLeft,
        child: VTitleText(translate('Departs') + ' $date', size: TextSize.medium)));
    date = itin.arrivalDateLocalLong();
    list.add(Align( alignment: Alignment.topLeft,
        child: VTitleText(translate('Arrives') + ' $date', size: TextSize.medium)));

    list.add(V3Divider());
    // content

    int index = 0;
    itin.flt.forEach((f) {
      list.add(
          Row(
            //mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
                Column(
                mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(DateFormat('kk:mm  ').format(DateTime.parse(f.time.ddaylcl + ' ' + f.time.dtimlcl)).toString()),
                    Padding(padding: EdgeInsets.fromLTRB(0, 50, 0, 0)),
                    Text(DateFormat('kk:mm  ').format(DateTime.parse(f.time.ddaylcl + ' ' + f.time.atimlcl)).toString()),
              ]),
              Column(children: [
                Icon(Icons.circle_outlined, size: 10,),
                V3VertDivider(color: Colors.black),
                Icon(Icons.circle_outlined, size: 10,),
              ]),
              Padding(padding: EdgeInsets.all(3)),
              Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                VTitleText(cityCodetoAirport(f.dep), size: TextSize.medium,),
                VBodyText(f.fltdet.airid + f.fltdet.fltno + ': '),
                VBodyText(f.journeyDuration()),
                Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 0)),
                VTitleText(cityCodetoAirport(f.arr), size: TextSize.medium,),
              ]),
       ]       // out
      ));
        index++;
        //list.add(Padding(padding: EdgeInsets.all(10)));
        if( index < itin.flt.length) {

          // cal transfer time
          DateTime a1 = DateTime.parse(f.time.adaygmt + ' ' + f.time.atimgmt);
          DateTime d1 = DateTime.parse(itin.flt[index].time.ddaygmt + ' ' + itin.flt[index].time.dtimgmt);
          int diff = d1.difference(a1).inMinutes;

          String tranTime =  getDuration(diff);


          /*list.add(Row(children: [
          Column(
          mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Text('00:00   ', style: TextStyle(color: Colors.white),),
          ],),
            Column(children: [
              V3VertDivider(color: Colors.grey.shade300),
            ]),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              VBodyText(tranTime + ' transfer time', size: TextSize.small,),
            ]),
          ])
          );*/
          list.add(Container(
            margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
              padding: EdgeInsets.all(10),
              color: Colors.grey.shade200,
              child:
            Row(
              children: [
                Icon(Icons.airline_seat_recline_extra_sharp),
                Padding(padding: EdgeInsets.all(3)),
                VBodyText(tranTime + ' transfer time', size: TextSize.small,),
              ],
            )));
        } else {
          list.add(Padding(padding: EdgeInsets.all(10)));

        }
    });

    list.add( VBodyText('Journey duration ' + itin.journeyDuration()));

    Widget content = Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: list,);
//'Flight Details\n' +
    _viewDetailDialog(context,  route, content);
  }

  void _onPressedViewDetails({int? p1, int? p2, String? p3}) async {
    logit('view details');
    gblActionBtnDisabled = false;
    Band classband = widget.objAv.availability.classbands!.band![p1!];

    String? fareName = p3;
    if (fareName == null) fareName = 'fare name';
    fareName = fareName == 'Fly Flex Plus' ? 'Fly Flex +' : fareName;

    _viewDetailDialog(context, fareName, classbandText(classband));
  }

  int getAvalability(List<Flt> item, int index) {
    int noAv = int.parse(item[0].fltav.fav![index]);
    item.forEach((element) {
      if (element.fltav.fav![index] == '0') {
        noAv = 0;
      }
      if (element.fltav.av![index] == '0' || element.fltav.av![index] == '') {
        noAv = 0;
      }
    });
    return noAv;
  }


  Widget getPrice(AvItin item, int fltNo, int curfare) {
    int noAv = getAvalability(item.flt, curfare);

    Color clr = Colors.black;
    if (fltNo == selectedFlt && curfare == selectedFare) {
      clr = gblSystemColors.selectedFareText!;
    } else {
      clr = gblSystemColors.defaultFaretext!;
    }
    if (noAv > 0) {
      Prices prices = item.getPrices(curfare);
      return VTitleText(calenderPrice(prices.currency,
          prices.price.toStringAsFixed(gblSettings.currencyDecimalPlaces),
          prices.miles.toString()),
        color: clr,
        );
    } else {
      return getNoSeatsRow();
    }
  }


  Widget flightTitle(AvItin? item, int fltNo) {
    List <Widget> innerList = [];

    innerList.add(vertFlightRow(context, item, fltNo));
    /* if (gblSettings.wantCanFacs &&
        item!.flt.first.fltdet.canfac?.fac.isNotEmpty != null) {
      innerList.add(V3Divider());
      innerList.add(CannedFactWidget(flt: item.flt));
    }
    innerList.add(infoRow(context, item!));*/
    return Container(
      // margin: EdgeInsets.only(top: 10, bottom: 10.0, left: 5, right: 5),
        color: selectedFlt == fltNo
            ? gblSystemColors.selectedFlt
            : gblSystemColors.unselectedFlt,
        padding: EdgeInsets.fromLTRB(5, 5, 5, 0),
        child: Column(
          children: innerList,
        )
    );
  }

  Widget vertFlightRow(BuildContext context, AvItin? item, int fltNo) {
    Prices prices = item!.getLowestPrice();

    return Column(children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              vertGetTime(item.flt.first.time.dtimlcl as String),
              vertGetDate(item.flt[0].time.ddaylcl as String),
              vertGetAirport(item.flt.first.dep as String),
              getTerminal(
                  getTerminalString(item.flt.first as Flt, true), true),
            ],
          ),
          Column(children: [
            /*   new RotatedBox(
              quarterTurns: 1,
              child: new Icon(
                Icons.airplanemode_active,
                size: 60.0,
              )),*/
          ]),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              vertGetTime(item.flt.last.time.atimlcl as String),
              vertGetDate(item.flt.last.time.adaylcl as String),
              vertGetAirport(item.flt.last.arr as String),
              getTerminal(
                  getTerminalString(item.flt.first as Flt, false), false),
            ],
          ),
          V3VertDivider(color: gblSystemColors.fltText),
          Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                fltText('from'),
                fltText(calenderPrice(prices.currency,
                    prices.price.toStringAsFixed(
                        gblSettings.currencyDecimalPlaces),
                    prices.miles.toString())),
              ]),

        ],
      ),
      //V3Divider(),
      Align(
          alignment: Alignment.topLeft,
          child:
          Container(
            margin: EdgeInsets.all(0),
            child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.min,
                children: [
                  vidTextButton(
                      context, 'Flight details', _onPressedFlightDetails, p1: fltNo,
                      p3: '',
                      color: gblSystemColors.fltText,
                      minHeight: true),
                  Padding(padding: EdgeInsets.all(5))]),
          )),
      //Text('here', style: TextStyle(color: Colors.white),)
    ]);
  }

  Future<void> _GoToNextPage(AvItin item, Band classband) async {
    gblError = '';

    // save flt
    List<String> msgs = buildfltRequestMsg(item.flt,
        classband.cbname,
        classband.cabin,
        int.parse(classband.cb as String),
        this.widget.newBooking.passengers.totalPassengers());

    if (widget.isReturnFlight) {
      if (msgs != null && msgs.length > 0) {
        this.widget.newBooking.returningflight = msgs;
        this.widget.newBooking.returningflts = item.flt;
        this.widget.newBooking.returningClass = classband.cbname;
      }
    } else {
      if (msgs != null && msgs.length > 0) {
        this.widget.newBooking.outboundflight = msgs;
        this.widget.newBooking.outboundflts = item.flt;
        this.widget.newBooking.outboundClass = classband.cbname;
      }
    }
    try {
      PnrModel pnrModel = await searchSaveBooking(
          this.widget.newBooking);
      gblPnrModel = pnrModel;
    } catch (e) {

    }
    if (gblError != '') {
      showVidDialog(context, 'Error', gblError, type: DialogType.Error);
    } else {
      // if single, get fare quote and go to summary page
      if (gblSearchParams.isReturn == true && widget.isReturnFlight == false) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    ReturnFlightSeletionPage(
                      newBooking: this.widget.newBooking,
                      outboundFlight: item.flt.last,
                      outboundAvItem: item,
                    )));
      } else {
        if (gblSettings.wantProducts) {
          Navigator.push(
              context,
              //MaterialPageRoute(
              CustomPageRoute(
                  builder: (context) =>
                      PassengerDetailsWidget(
                        newBooking: widget.newBooking,
                        pnrModel: gblPnrModel,)));
        } else {
          Navigator.push(
              context,
              // MaterialPageRoute(
              CustomPageRoute(
                  builder: (context) =>
                      FlightSelectionSummaryWidget(
                          newBooking: this.widget.newBooking)));
        }
      }
    }
    // I^-TTTTOne/AdultMr^0LM0032K18Sep24ABZKOIQQ1/08500945(CAB=Y)[CB=Fly]^fg/GBP^fs1^*r~x

    // if single and has products goto pax details page ??

    // if return go to returning flight page


  }

  Widget vertGetDate(String dt) {
    //return fltText(getIntlDate('EEE dd MMM', DateTime.parse(dt)));
    return fltText(getIntlDate('dd MMM', DateTime.parse(dt)));
  }

  Widget vertGetTime(String tm) {
    String formattedTm = tm.substring(0, 5);
    if (gblSettings.avTimeFormat.contains(':')) {

    } else {
      formattedTm = formattedTm.replaceAll(':', '');
    }
    if (wantRtl()) {
      return fltText(getIntlDate('HHmm', DateTime.parse('2022-11-12 ' + tm)));
    } else {
      return fltText(formattedTm);
    }
  }

  Widget fltText(String text) {
    return VBodyText(
      text, size: TextSize.large, color: gblSystemColors.fltText,);
  }

  Widget fareText(String text, int fltNo, int fareNo) {
    // get colour
    Color clr = Colors.black;
    if (fltNo == selectedFlt && fareNo == selectedFare) {
      clr = gblSystemColors.selectedFareText!;
    } else {
      clr = gblSystemColors.defaultFaretext!;
    }
    return VBodyText(text, size: TextSize.large, color: clr,);
  }

  Widget vertGetAirport(String code,) {
    return fltText(cityCodetoAirport(code));
  }

  void _viewDetailDialog(BuildContext context, String? title, Widget content) {

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            shape: alertShape(),
            titlePadding: const EdgeInsets.all(0),
            title: Container(
                alignment: Alignment.topLeft,
                decoration: BoxDecoration(
                    color: gblSystemColors.primaryHeaderColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10.0),
                      topRight: Radius.circular(10.0),)),
                padding: EdgeInsets.only(left: 10, top: 10, bottom: 10),
                child: Text(title!,
                  style: TextStyle(color: gblSystemColors.headerTextColor),)),
            content: content,
            //contentPadding: EdgeInsets.all(5),
            //Text(txt == '' ? 'A newer version of the app is available to download' : txt),
            actions: <Widget>[
              new TextButton(
                child: new Text(
                  'OK',
                  style: TextStyle(color: Colors.black),
                ),
                style: TextButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: BorderSide(
                        color: gblSystemColors.textButtonTextColor, width: 1),
                    foregroundColor: Colors.white),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),

            ]);
      },
    );
  }
}