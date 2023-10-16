import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:vmba/data/globals.dart';
//import 'package:flutter_date_pickers/flutter_date_pickers.dart' ;
import 'package:vmba/datePickers/models/flightDatesModel.dart';

class DayPickerPage extends StatefulWidget {
  DayPickerPage(
      {Key key= const Key("daypicker_key"),
      required this.departureDate,
      required this.lastDate,
      required this.firstDate,
      required this.onChanged})
      : super(key: key);

  final DateTime departureDate;
  final DateTime lastDate;
  final DateTime firstDate;
  final ValueChanged<FlightDates> onChanged;
  @override
  State<StatefulWidget> createState() => _DayPickerPageState();
}

class _DayPickerPageState extends State<DayPickerPage> {
  late DateTime _selectedDate;
  late DateTime _firstDate;
  late DateTime _lastDate;

  String _selectedDateString = '';
  String _dateCount = '';
  String _range = '';
  String _rangeCount = '';

//  Color selectedDateStyleColor;
//  Color selectedSingleDateDecorationColor;

  @override
  void initState() {
    super.initState();

    _selectedDate = widget.departureDate;

    if (widget.firstDate != null) {
      _firstDate = widget.firstDate;
    } else {
      _lastDate = DateTime.now().add(Duration(days: 364));
    }

    if (widget.lastDate != null) {
      _lastDate = widget.lastDate;
    } else {
      _lastDate = DateTime.now().add(Duration(days: 364));
    }

  }



  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // defaults for styles
//    selectedDateStyleColor = Theme.of(context).accentTextTheme.bodyText2.color;
//    selectedSingleDateDecorationColor = Theme.of(context).accentColor;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    if( gblSettings.wantPriceCalendar == true ){
      return Container(
        // margin: const EdgeInsets.symmetric(vertical: 50.0, horizontal: 60),
          width: width - 50,
          height: 400,
          child:SfDateRangePicker(
            onSelectionChanged: _onSelectionChanged,
            selectionMode: DateRangePickerSelectionMode.single,
            selectionTextStyle: TextStyle(color: Colors.grey),
            initialSelectedDate: _selectedDate,
            minDate: _firstDate,
            maxDate: _lastDate,
            selectionColor: Colors.lightBlue,
 //           cellBuilder: cellBuilder,
  /*          initialSelectedRange: PickerDateRange(
                DateTime.now().subtract(const Duration(days: 4)),
                DateTime.now().add(const Duration(days: 3))),*/
          )
      );
    } else {
      return
        Container(
          // margin: const EdgeInsets.symmetric(vertical: 50.0, horizontal: 60),
            width: width - 50,
            height: 400,
            child: CalendarDatePicker(
              initialDate: _selectedDate,
              firstDate: _firstDate,
              lastDate: _lastDate,
              onDateChanged: _onSelectedDateChanged,
            ));
    }
  }

  Widget cellBuilder(BuildContext context, DateRangePickerCellDetails details) {
    DateTime _visibleDates = details.date;
    if( details.visibleDates.length == 12) {
      int i = 1;
      // month mode
      return Container(
        child: Text(
            DateFormat("MMM").format(details.date),
          textAlign: TextAlign.center,
        ),
      );
    }
//    if (isSpecialDate(_visibleDates)) {
      return
        Container(

          margin: EdgeInsets.all(2),
 /*         decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            color: Colors.white,
            boxShadow: [
              BoxShadow(color: Colors.grey.shade200, spreadRadius: 2),
            ],
          ),*/
          child:
          Column(

        children: [
            Text(
              details.date.day.toString(),
              textAlign: TextAlign.start,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          Padding(padding: EdgeInsets.all(4)),
/*
          Divider(
            color: Colors.white,
            height: 5,
          ),
*/
          Text(
            gblSettings.wantPriceCalendarRounding ? '£199': '£199.99',
            textAlign: TextAlign.center,
            textScaleFactor: 0.75,
          ),
          /*Icon(
            Icons.celebration,
            size: 13,
            color: Colors.red,
          ),*/
        ],
          )
      );
 /*   } else {
      return Container(
        child: Text(
          details.date.day.toString(),
          textAlign: TextAlign.center,
        ),
      );
    }*/
  }
  void _onSelectedDateChanged(DateTime newDate) {
    setState(() {
      _selectedDate = newDate;
      widget.onChanged(FlightDates(_selectedDate, null));
    });
  }
  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    /// The argument value will return the changed date as [DateTime] when the
    /// widget [SfDateRangeSelectionMode] set as single.
    ///
    /// The argument value will return the changed dates as [List<DateTime>]
    /// when the widget [SfDateRangeSelectionMode] set as multiple.
    ///
    /// The argument value will return the changed range as [PickerDateRange]
    /// when the widget [SfDateRangeSelectionMode] set as range.
    ///
    /// The argument value will return the changed ranges as
    /// [List<PickerDateRange] when the widget [SfDateRangeSelectionMode] set as
    /// multi range.
    setState(() {
      if (args.value is PickerDateRange) {
        _range = '${DateFormat('dd/MM/yyyy').format(args.value.startDate)} -'
        // ignore: lines_longer_than_80_chars
            ' ${DateFormat('dd/MM/yyyy').format(args.value.endDate ?? args.value.startDate)}';
      } else if (args.value is DateTime) {
        _selectedDateString = args.value.toString();
        _selectedDate = DateTime.parse(_selectedDateString);
      } else if (args.value is List<DateTime>) {
        _dateCount = args.value.length.toString();
      } else {
        _rangeCount = args.value.length.toString();
      }
    });
  }
}

