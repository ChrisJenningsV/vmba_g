
import 'package:flutter/material.dart';
import 'package:vmba/datePickers/widgets/dayBuilder.dart';
import 'package:vmba/datePickers/widgets/rangePicker.dart';
import 'package:vmba/datePickers/models/flightDatesModel.dart';
import 'package:intl/intl.dart';
import '../Managers/imageManager.dart';
import '../components/vidAppBar.dart';
import '../components/vidButtons.dart';
import '../data/globals.dart';


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
        appBar: vidAppBar(
          //PageEnum.travelDates,
         // backgroundColor: gblSystemColors.primaryHeaderColor,
          automaticallyImplyLeading: false,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            )
          ],
          titleText: 'Travel Dates',
        ),
        body:
    gblSettings. wantNewCalendar || gblSettings.wantPriceCalendar ?
    ImageManager.getBodyWithBackground(context,'DATEPICKER', wrapCal(
        RangePickerPage(
            departureDate: widget.departureDate,
            returnDate: widget.returnDate,
            onChanged: _handleDateChanged,
          ),
            (){ setState(() { });},
            true, startOfPeriod, endOfPeriod), null)
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
