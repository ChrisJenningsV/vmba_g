import 'package:flutter/material.dart';
import 'package:vmba/datePickers/widgets/dayPicker.dart';
import 'package:vmba/datePickers/models/flightDatesModel.dart';
import 'package:intl/intl.dart';
import 'package:vmba/components/trText.dart';
import '../components/vidButtons.dart';

class DatePickerWidget extends StatefulWidget {
  DatePickerWidget({Key key, this.departureDate}) : super(key: key);
  final DateTime departureDate;

  @override
  _DatePickerWidgetState createState() => _DatePickerWidgetState();
}

class _DatePickerWidgetState extends State<DatePickerWidget>
    with TickerProviderStateMixin {
  DateTime departureDate;
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
        body: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            DayPickerPage(
                firstDate: DateTime.now(),
                departureDate: widget.departureDate,
                lastDate: DateTime.now().add(new Duration(days: 365)),
                onChanged: _handleDateChanged),
          ],
        ),
        floatingActionButton: vidWideActionButton(context,'Done', onPressed, icon: Icons.check, offset: 35.0 ) );
/*
        Padding(
            padding: EdgeInsets.only(left: 35.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new FloatingActionButton.extended(
                    elevation: 0.0,
                    isExtended: true,
                    label: TrText('Done', style: TextStyle(color: gblSystemColors
                              .primaryButtonTextColor),),
                    icon: Icon(Icons.check, color: gblSystemColors
                              .primaryButtonTextColor,),
                    backgroundColor: gblSystemColors
                              .primaryButtonColor,//new Color(0xFF000000),
                    onPressed: () {
                      Navigator.pop(
                          context,
                          FlightDates(
                              DateTime.parse(
                                  DateFormat('y-MM-dd').format(departureDate) +
                                      ' 00:00:00'),
                              null));
                    }),
              ],
            )));
*/
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
