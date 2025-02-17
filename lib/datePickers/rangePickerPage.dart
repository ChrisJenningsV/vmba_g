
import 'package:flutter/material.dart';
import 'package:vmba/datePickers/widgets/dayBuilder.dart';
import 'package:vmba/datePickers/widgets/rangePicker.dart';
import 'package:vmba/datePickers/models/flightDatesModel.dart';
import 'package:intl/intl.dart';
import 'package:vmba/components/trText.dart';
import '../components/vidButtons.dart';
import '../data/globals.dart';
import '../v3pages/controls/V3AppBar.dart';
import '../v3pages/controls/V3Constants.dart';


class RangePickerWidget extends StatefulWidget {
  RangePickerWidget({Key key= const Key("ranpik_key"), required this.departureDate,required  this.returnDate})
      : super(key: key);

  final DateTime departureDate;
  final DateTime returnDate;

  @override
  _RangePickerWidgetState createState() => _RangePickerWidgetState();
}

class _RangePickerWidgetState extends State<RangePickerWidget>
    with TickerProviderStateMixin {
  DateTime startOfPeriod = DateTime.now();
  DateTime endOfPeriod = DateTime.now();
  DateTime firstDate = DateTime.now();
  DateTime lastDate = DateTime.now();

  @override
  void initState() {
    super.initState();

    DateTime now = DateTime.now();

    firstDate = now;
    lastDate = now.add(Duration(days: 364));

    startOfPeriod = widget.departureDate; 
    endOfPeriod = widget.returnDate;
    gblDepartDate = startOfPeriod;
    gblReturnDate = endOfPeriod;

  }

  void _handleDateChanged(FlightDates newValue) {
    startOfPeriod = newValue.departureDate;
    gblDepartDate = newValue.departureDate;
    endOfPeriod = newValue.returnDate!;
    gblReturnDate = newValue.returnDate!;
    setState(() {
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: V3AppBar(
          PageEnum.travelDates,
         // backgroundColor: gblSystemColors.primaryHeaderColor,
          automaticallyImplyLeading: false,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            )
          ],
          title: TrText(
            'Travel Dates',
            style: TextStyle(letterSpacing: 1.15),
          ),
        ),
        body:
    gblSettings. wantNewCalendar || gblSettings.wantPriceCalendar ?
    wrapCal(
        RangePickerPage(
            departureDate: widget.departureDate,
            returnDate: widget.returnDate,
            onChanged: _handleDateChanged,
          ),
            (){ setState(() { });},
            true, startOfPeriod, endOfPeriod)
        :         RangePickerPage(
        departureDate: widget.departureDate,
        returnDate: widget.returnDate,
        onChanged: _handleDateChanged,
      ),

        floatingActionButton: vidWideActionButton(context,'Done', onPressed, icon: Icons.check, offset: 35.0 ) );

  }
  void onPressed( BuildContext context, dynamic p) {
    Navigator.pop(
        context,
        FlightDates(
            DateTime.parse(
                DateFormat('y-MM-dd').format(startOfPeriod) +
                    ' 00:00:00'),
            DateTime.parse(
                DateFormat('y-MM-dd').format(endOfPeriod) +
                    ' 00:00:00')));

  }
}
