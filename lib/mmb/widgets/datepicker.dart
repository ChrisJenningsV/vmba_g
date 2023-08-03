
import 'package:flutter/material.dart';
import 'package:vmba/datePickers/models/flightDatesModel.dart';
import 'package:vmba/datePickers/widgets/dayPicker.dart';
import 'package:intl/intl.dart';
import 'package:vmba/menu/menu.dart';
import 'package:vmba/data/models/pnr.dart';
import 'package:vmba/data/models/models.dart';
import 'package:vmba/mmb/changeFlightPage.dart';
import 'package:vmba/data/globals.dart';
import 'package:vmba/components/trText.dart';

class MmbDatePickerWidget extends StatefulWidget {
  MmbDatePickerWidget(
      {Key key= const Key("mmbdate_key"), required this.pnr,required  this.journeyToChange,required  this.mmbBooking})
      : super(key: key);

  final PnrModel pnr;
  final int journeyToChange;
  final MmbBooking mmbBooking;

  @override
  _DatePickerWidgetState createState() => _DatePickerWidgetState();
}

class _DatePickerWidgetState extends State<MmbDatePickerWidget>
    with TickerProviderStateMixin {
  DateTime? departureDate ;
  DateTime? lastDate;
  DateTime? firstDate;
  late MmbBooking mmbBooking;
  @override
  void initState() {
    super.initState();
    mmbBooking = widget.mmbBooking;
    setDateRange();
  }

  void setDateRange() {
    firstDate = DateTime.now();
    departureDate = DateTime.parse(mmbBooking
            .journeys.journey[widget.journeyToChange - 1].itin.first.depDate +
        ' 00:00:00');
    if (DateTime.now().isAfter(departureDate!)) {
      departureDate = DateTime.now();
    }


    lastDate = DateTime.now().add(Duration(days: 364));// +
    //mmbBooking.journeys.journey[widget.journeyToChange-1].itin.first.depTime);
    //Oneway flight
    if (widget.journeyToChange == 1 &&
        mmbBooking.journeys.journey.length == 1) {
      firstDate = DateTime.now();
    }
    //Return flight first segment
    else if (widget.journeyToChange == 1 &&
        mmbBooking.journeys.journey.length == 2) {
      firstDate = DateTime.now();
      lastDate = DateTime.parse(
          mmbBooking.journeys.journey.last.itin.first.depDate +
              ' ' +
              mmbBooking.journeys.journey.last.itin.first.depTime);
    }
    //Return flight second segment
    else if (widget.journeyToChange == 2 &&
        mmbBooking.journeys.journey.length == 2) {
      firstDate = DateTime.parse(
          mmbBooking.journeys.journey.first.itin.last.depDate +
              ' ' +
              mmbBooking.journeys.journey.first.itin.last.arrTime);

      if (DateTime.now().isAfter(firstDate!)) {
        firstDate = DateTime.now();
      }
    }
  }

  void _handleDateChanged(FlightDates newValue) {
    departureDate = newValue.departureDate;
    //widget.mmbBooking.departureDate = departureDate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: TrText(
            'New Travel Date',
            style: TextStyle(letterSpacing: 1.15),
          ),
        ),
        endDrawer: DrawerMenu(),
        body: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          DayPickerPage(
              firstDate: DateTime.parse(DateFormat('y-MM-dd').format(firstDate!) + ' 00:00:00'),
              departureDate: DateTime.parse(DateFormat('y-MM-dd').format(departureDate!) + ' 00:00:00'),
              lastDate: DateTime.parse(DateFormat('y-MM-dd').format(lastDate!) + ' 00:00:00'),
              //firstDate: firstDate,
              // departureDate: departureDate,
              //lastDate: lastDate,
              onChanged: _handleDateChanged),
        ]),
        floatingActionButton: Padding(
            padding: EdgeInsets.only(left: 35.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new FloatingActionButton.extended(
                    elevation: 0.0,
                    isExtended: true,
                    label: TrText('Done',style: TextStyle(color: gblSystemColors.primaryButtonTextColor),),
                    icon: Icon(Icons.check, color: gblSystemColors.primaryButtonTextColor,),
                    backgroundColor: gblSystemColors.primaryButtonColor,
                    onPressed: () {
                      mmbBooking.journeyToChange = widget.journeyToChange;
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ChangeFlightPage(
                                    pnr: widget.pnr, //journey: widget.journey,
                                    departureDate:
                                        departureDate!, // journeys: widget.journeys,
                                    mmbBooking: mmbBooking,
                                  )));
                    }),
              ],
            )));
  }
}
