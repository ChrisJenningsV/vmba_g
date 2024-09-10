
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vmba/data/globals.dart';
import 'package:vmba/datePickers/widgets/dayBuilder.dart';
import 'package:vmba/datePickers/widgets/dayPicker.dart';
import 'package:vmba/datePickers/models/flightDatesModel.dart';
import 'package:intl/intl.dart';
import 'package:vmba/components/trText.dart';
import '../components/vidButtons.dart';
import '../v3pages/controls/V3AppBar.dart';
import '../v3pages/controls/V3Constants.dart';
import '../v3pages/v3Theme.dart';

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
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: V3AppBar(PageEnum.dayPicker,
        /*  systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: gblSystemColors.primaryHeaderColor,
          ),*/
          //backgroundColor: gblSystemColors.primaryHeaderColor,
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
            wrapCal(
           DayPickerPage(
                firstDate: DateTime.now(),
                departureDate: widget.departureDate,
                lastDate: DateTime.now().add(new Duration(days: 51 * 7)),
                onChanged: _handleDateChanged,
              ),
                (){ setState(() {},);},
                false, departureDate, null)
        : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
          DayPickerPage(
              firstDate: DateTime.now(),
              departureDate: widget.departureDate,
              lastDate: DateTime.now().add(new Duration(days: 51 * 7)),
              onChanged: _handleDateChanged,
          ),
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
