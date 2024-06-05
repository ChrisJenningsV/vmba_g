
import 'package:flutter/material.dart';
import 'package:vmba/data/globals.dart';
import 'package:vmba/datePickers/widgets/dayPicker.dart';
import 'package:vmba/datePickers/models/flightDatesModel.dart';
import 'package:intl/intl.dart';
import 'package:vmba/components/trText.dart';
import '../components/vidButtons.dart';

class DatePickerWidget extends StatefulWidget {
  DatePickerWidget({Key key= const Key("datepi_key"), required this.departureDate }) : super(key: key);
  final DateTime departureDate;

  @override
  _DatePickerWidgetState createState() => _DatePickerWidgetState();
}

class _DatePickerWidgetState extends State<DatePickerWidget>
    with TickerProviderStateMixin {
  late DateTime departureDate;
  @override
  void initState() {
    super.initState();

    departureDate = widget.departureDate;
  }

  void _handleDateChanged(FlightDates newValue) {
    departureDate = newValue.departureDate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            )
          ],
          title: TrText(
            'Travel Date',
            style: TextStyle(letterSpacing: 1.15),
          ),
        ),
        body: gblSettings.wantPriceCalendar ?
            Align(alignment: Alignment.topCenter,
            child:
            Padding(
              padding: EdgeInsets.fromLTRB(5, 25, 5, 5),
    child:
        Container(
           /* decoration: BoxDecoration(
              color: Colors.red, //grey.shade300,
              //shape: BoxShape.rectangle,
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
              border: Border.all(width: 5, color: Colors.white)
            ),*/
        //Row(
          //mainAxisAlignment: MainAxisAlignment.center,
          //children: <Widget>[
          child:
            DayPickerPage(
                firstDate: DateTime.now(),
                departureDate: widget.departureDate,
                lastDate: DateTime.now().add(new Duration(days: 365)),
                onChanged: _handleDateChanged),
          //],
        ))
            )
        : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
          DayPickerPage(
              firstDate: DateTime.now(),
              departureDate: widget.departureDate,
              lastDate: DateTime.now().add(new Duration(days: 365)),
              onChanged: _handleDateChanged),
          ],
        )
        ,
        floatingActionButton: vidWideActionButton(context,'Done', onPressed, icon: Icons.check, offset: 35.0 ) );

  }
  void onPressed(BuildContext context, dynamic p) {
    Navigator.pop(
        context,
        FlightDates(
            DateTime.parse(
                DateFormat('y-MM-dd').format(departureDate) +
                    ' 00:00:00'),
            null));
  }
}
