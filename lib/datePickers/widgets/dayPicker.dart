import 'dart:async';

import 'package:flutter/material.dart';
import 'package:vmba/Helpers/settingsHelper.dart';
import 'package:vmba/data/globals.dart';
import 'package:vmba/datePickers/models/flightDatesModel.dart';
//import 'package:calendar_date_picker2/calendar_date_picker2.dart';

//import '../../calendar/fareCalendar/fareDatePicker.dart';
import '../../calendar/fareCalendar/fareDatePicker.dart';
import '../../calendar/fareCalendar/widgets/FareCalendarDatePicker_config.dart';
import '../../utilities/helper.dart';
import '../../utilities/widgets/dataLoader.dart';
import './dayBuilder.dart';

class DayPickerPage extends StatefulWidget {
  DayPickerPage(
      {Key key= const Key("daypicker_key"),
      required this.departureDate,
      required this.lastDate,
      required this.firstDate,
      required this.onChanged,})
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
//    _selectedDate = DateTime.now().subtract(Duration(days: 31));
    if (widget.firstDate != null) {
      _firstDate = widget.firstDate;
    } else {
      _lastDate = DateTime.now().add(Duration(days: 51 * 7));
    }

    if (widget.lastDate != null) {
      _lastDate = widget.lastDate;
    } else {
      _lastDate = DateTime.now().add(Duration(days: 51 * 7));
    }
    _initData(widget.departureDate);
  }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // defaults for styles
//    selectedDateStyleColor = Theme.of(context).accentTextTheme.bodyText2.color;
//    selectedSingleDateDecorationColor = Theme.of(context).accentColor;
  }

  _initData(DateTime dt) {
    if( gblSettings.wantPriceCalendar) {
      LoadCalendarData(context, dt, onCompleteLoad);
    }
  }
  void onCompleteLoad()
  {
    Timer(Duration(seconds : 1), ()
    {
    setState(() {

    });
    });
  }



  @override
  Widget build(BuildContext context) {
    checkDataUpdate();
    double width = MediaQuery
        .of(context)
        .size
        .width;

    if (gblSettings.wantPriceCalendar == true && gblIsLive == false ) {
      FareCalendarDatePickerConfig config = FareCalendarDatePickerConfig(
        firstDate: _firstDate,
        lastDate: _lastDate,
        dayBuilder: _dayBuilder,
        monthChange: _monthChange,
        weekdayLabels: ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'],
        controlsTextStyle: TextStyle(fontWeight: FontWeight.bold),
        weekdayLabelTextStyle: TextStyle(fontWeight: FontWeight.bold),
          centerAlignModePicker: true,
      );


      List<DateTime?> _singleDatePickerValueWithDefaultValue = [
        _selectedDate,
      ];
      Color backColor = Colors.grey.shade300;
      if( gblV3Theme != null ) backColor = gblV3Theme!.calendar.backColor;
      return
        Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10) ,
            color: backColor),
            width:  width - 50,
            height: 400,
            child:
                Column( children: [
                  FareCalendarDatePicker(
                      config: config,
                      value: _singleDatePickerValueWithDefaultValue,
                      onValueChanged: (dates) {
                        setState(() {
                          _singleDatePickerValueWithDefaultValue = dates;
                          _selectedDate = dates[0] as DateTime;
                          widget.onChanged(FlightDates(_selectedDate, null));
                        }
                        );
                      }
                  ),
                  // loading

                ],)

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

  void _onSelectedDateChanged(DateTime newDate) {
    setState(() {
      _selectedDate = newDate;
      widget.onChanged(FlightDates(_selectedDate, null));
    });
  }

  void _monthChange(DateTime newMonth){
    logit('MonthChange event',verboseMsg: false);
    // load this months data
    LoadCalendarData(context, newMonth, onCompleteLoad);
  }

  Widget? _dayBuilder({required DateTime date,
    TextStyle? textStyle,
    BoxDecoration? decoration ,
    bool? isSelected ,
    bool? isDisabled ,
    bool? isToday,}) {
    return dayBuilder(context, date,textStyle,decoration ,isSelected ,isDisabled ,isToday,);
  }
    void checkDataUpdate(){
    if( gblFlightPrices == null ){
      // first load
//      _initData(widget.departureDate);
    }
  }
}