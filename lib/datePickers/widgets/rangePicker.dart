
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_date_pickers/flutter_date_pickers.dart';
import 'package:intl/intl.dart';
import 'package:vmba/Helpers/settingsHelper.dart';
import 'package:vmba/data/globals.dart';
import 'package:vmba/datePickers/models/flightDatesModel.dart';
import 'package:vmba/components/trText.dart';
import 'package:vmba/calendar/flightPageUtils.dart';

import '../../calendar/fareCalendar/fareDatePicker.dart';
import '../../calendar/fareCalendar/widgets/FareCalendarDatePicker_config.dart';
import '../../utilities/helper.dart';
import '../../utilities/widgets/dataLoader.dart';
import 'dayBuilder.dart';

class RangePickerPage extends StatefulWidget {
  RangePickerPage(
      {Key key= const Key("rangepi_key"), required this.departureDate, required this.returnDate, required this.onChanged,})
      : super(key: key);

  final DateTime departureDate;
  final DateTime returnDate;
  final ValueChanged<FlightDates> onChanged;
/*
  final void Function() onSelectChanged;
*/

  @override
  State<StatefulWidget> createState() => _RangePickerPageState();
}

class _RangePickerPageState extends State<RangePickerPage> {
  DateTime _firstDate = DateTime.now();
  DateTime _lastDate = DateTime.now();
  late DateTime _selectedDate;
  late DateTime? _selectedDate2;
  late DatePeriod _selectedPeriod ;

  late Color selectedPeriodStartColor ;
  late Color selectedPeriodLastColor;
  late Color selectedPeriodMiddleColor;
  late List<DateTime?> _rangeDatePickerValueWithDefaultValue ;

  @override
  void initState() {
    super.initState();

    _firstDate = DateTime.parse(
        DateFormat('y-MM-dd').format(DateTime.now()) + ' 00:00:00');

    _lastDate = DateTime.now().add(Duration(days: 364));

    DateTime selectedPeriodStart =
        widget.departureDate; //DateTime.now().add(Duration(days: 4));
    DateTime selectedPeriodEnd =
        widget.returnDate; //DateTime.now().add(Duration(days: 8));
    _selectedPeriod = DatePeriod(selectedPeriodStart, selectedPeriodEnd);
    _selectedDate = _firstDate;
    _selectedDate2 = _selectedDate.add(Duration(days: 7));
    _rangeDatePickerValueWithDefaultValue = [_selectedDate,_selectedDate2 ];
    LoadCalendarData(context, widget.departureDate, onCompleteLoad);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();


    // defaults for styles
    selectedPeriodLastColor = gblSystemColors.accentColor; //  Theme.of(context).accentColor;
    selectedPeriodMiddleColor = Colors.black26; //Theme.of(context).accentColor;
    selectedPeriodStartColor = gblSystemColors.accentColor; //  Theme.of(context).accentColor;
  }

  @override
  Widget build(BuildContext context) {
    BorderRadius startDecor = BorderRadius.only(
        topLeft: Radius.circular(20.0), bottomLeft: Radius.circular(20.0));
    BorderRadius lastDecor = BorderRadius.only(
        topRight: Radius.circular(20.0), bottomRight: Radius.circular(20.0));

    if (wantRtl()) {
      // swap them over
      lastDecor = BorderRadius.only(
          topLeft: Radius.circular(20.0), bottomLeft: Radius.circular(20.0));
      startDecor = BorderRadius.only(
          topRight: Radius.circular(20.0), bottomRight: Radius.circular(20.0));
    }

    if (gblSettings.wantPriceCalendar == true && gblIsLive == false) {
      FareCalendarDatePickerConfig config = FareCalendarDatePickerConfig(
        calendarType: FareCalendarDatePickerType.range,
        rangeBidirectional: true,
        firstDate: _firstDate,
        lastDate: _lastDate,
        dayBuilder: _dayBuilder,
        monthChange: _monthChange,
        weekdayLabels: ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'],
        controlsTextStyle: TextStyle(fontWeight: FontWeight.bold),
        selectedRangeDayTextStyle:TextStyle(color: Colors.pink),
        weekdayLabelTextStyle: TextStyle(fontWeight: FontWeight.bold),
        centerAlignModePicker: true,
      );

      double width = MediaQuery
          .of(context)
          .size
          .width;

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
                  value: _rangeDatePickerValueWithDefaultValue,
                  onValueChanged: (dates) {
                    setState(() {
                      logit('pick ${dates.length} dates');
                      _rangeDatePickerValueWithDefaultValue = dates;
                      _selectedDate = dates[0] as DateTime;
                      if( dates.length > 1) {
                        _selectedDate2= dates[1] as DateTime;
                      } else {
                        _selectedDate2 = _selectedDate;
                      }
                      //_rangeDatePickerValueWithDefaultValue  = [_selectedDate,_selectedDate2];
                      widget.onChanged(FlightDates(_selectedDate, _selectedDate2));
                    }
                    );
                  }
              ),
              // loading

            ],)

        );
    } else {
      // add selected colors to default settings
      DatePickerRangeStyles styles = DatePickerRangeStyles(
        selectedPeriodLastDecoration: BoxDecoration(
            color: selectedPeriodLastColor,
            borderRadius: lastDecor),
        selectedPeriodStartDecoration: BoxDecoration(
          color: selectedPeriodStartColor,
          borderRadius: startDecor,
        ),
        selectedPeriodMiddleDecoration: BoxDecoration(
            color: selectedPeriodMiddleColor, shape: BoxShape.rectangle),
      );

      return Flex(
        direction: MediaQuery
            .of(context)
            .orientation == Orientation.portrait
            ? Axis.vertical
            : Axis.horizontal,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black,
                    blurRadius: 5.0, // has the effect of softening the shadow
                  )
                ],
                border: Border(
                  right: BorderSide(color: Colors.black54, width: 0),
                  //bottom: BorderSide()
                )),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Container(
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Column(
                        children: <Widget>[
                          TrText('Departing',
                              style: TextStyle(
                                fontWeight: FontWeight.w300,
                              )),
                          Text(getIntlDate('dd MMM yyy', _selectedPeriod.start),
                            //DateFormat("dd MMM yyy").format(_selectedPeriod.start),
                            style: TextStyle(fontSize: 16),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                //Divider(height: 20, color: Colors.black),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border(
                            left: BorderSide(width: 1, color: Colors.black38))),
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Column(
                        children: <Widget>[
                          TrText('Returning',
                              style: TextStyle(
                                fontWeight: FontWeight.w300,
                              )),
                          Text(getIntlDate('dd MMM yyy', _selectedPeriod.end),
                              //DateFormat("dd MMM yyy").format(_selectedPeriod.end),
                              style: TextStyle(fontSize: 16))
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8),
          ),
          Expanded(
            child: RangePicker(
              selectedPeriod: _selectedPeriod,
              onChanged: _onSelectedDateChanged,
              firstDate: _firstDate,
              lastDate: _lastDate,
              datePickerStyles: styles,
            ),
          ),
        ],
      );
    }
  }

  void _onSelectedDateChanged(DatePeriod newPeriod) {
    setState(() {
      _selectedPeriod = newPeriod;
      widget.onChanged(FlightDates(newPeriod.start, newPeriod.end));
    });
  }

  void _monthChange(DateTime newMonth){
    logit('MonthChange event',verboseMsg: false);
    // load this months data
    LoadCalendarData(context, newMonth, onCompleteLoad);
  }
  void onCompleteLoad()
  {
    Timer(Duration(seconds : 1), ()
    {
      setState(() {

      });
    });
  }


  Widget? _dayBuilder({required DateTime date,
    TextStyle? textStyle,
    BoxDecoration? decoration ,
    bool? isSelected ,
    bool? isDisabled ,
    bool? isToday,}) {

    bool isInRange = false;
    isInRange = !(date.isBefore(_selectedDate) ||
        date.isAfter(_selectedDate2 as DateTime)) &&
        !DateUtils.isSameDay(_firstDate, _lastDate);

    return dayBuilder(context, date,textStyle,decoration ,isSelected ,isDisabled ,isToday, isInRange: isInRange);
  }

}
