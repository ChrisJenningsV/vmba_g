import 'dart:async';

import 'package:flutter/material.dart';
import 'package:vmba/data/globals.dart';
import 'package:vmba/datePickers/models/flightDatesModel.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';

//import '../../calendar/fareCalendar/fareDatePicker.dart';
import '../../calendar/fareCalendar/fareDatePicker.dart';
import '../../utilities/helper.dart';
import '../../utilities/widgets/dataLoader.dart';

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
//    _selectedDate = DateTime.now().subtract(Duration(days: 31));
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
    LoadCalendarData(dt, onCompleteLoad);
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
      CalendarDatePicker2Config config = CalendarDatePicker2Config(
        firstDate: _firstDate,
        lastDate: _lastDate,
        dayBuilder: _dayBuilder,
        weekdayLabels: ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'],
        controlsTextStyle: TextStyle(fontWeight: FontWeight.bold),
        weekdayLabelTextStyle: TextStyle(fontWeight: FontWeight.bold),
          centerAlignModePicker: true,
      );


      List<DateTime?> _singleDatePickerValueWithDefaultValue = [
        _selectedDate,
      ];
      return
        Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10) ,
            color: Colors.grey.shade300,),
          //  color: Colors.grey.shade200,
          // margin: const EdgeInsets.symmetric(vertical: 50.0, horizontal: 60),
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


  Widget? _dayBuilder({required DateTime date,
    TextStyle? textStyle,
    BoxDecoration? decoration ,
    bool? isSelected ,
    bool? isDisabled ,
    bool? isToday,}) {

    decoration = BoxDecoration(color: Colors.grey.shade500,
      borderRadius: BorderRadius.circular(1),
     // border: Border.fromBorderSide()
        );
    Widget lineTwo = Text('');
    //(isDisabled == null || isDisabled== true)?Text(''): Text('£129', textScaleFactor: 0.75,)
    Color textColor = Colors.black;
    if(isSelected != null && isSelected == true){
      textColor = Colors.white;
    }


    if(isToday != null && isToday == true ){
      textStyle = TextStyle( color: Colors.red, fontWeight: FontWeight.bold);
      decoration = BoxDecoration( );
     lineTwo = RotatedBox(
          quarterTurns: 1,
          child: new Icon(
            Icons.airplanemode_active,
            color: Colors.red,
            size: 15.0,
          ));
    } else if( isDisabled != null && isDisabled== false){
    /*  lineTwo = RotatedBox(
          quarterTurns: 1,
          child: new Icon(
            Icons.airplanemode_active,
            color: Colors.black,
            size: 15.0,
          ));*/

    }
    if( gblFlightPrices != null ) {
      // check for this date
      gblFlightPrices!.flightPrices.forEach((flightPrice) {
 //       logit( ' match ${flightPrice.FlightDate} to ${date.toString().substring(0,10)}');
        if( flightPrice.FlightDate != '' && flightPrice.FlightDate== date.toString().substring(0,10)){
          if( flightPrice.Selectable == false){
           // logit( ' match no sel  ${flightPrice.FlightDate}');
        //    if ( textStyle != null ) {
              textStyle = TextStyle( color: Colors.red, fontWeight: FontWeight.bold);
          //  }
          }
          //logit('${flightPrice.FlightDate} ${flightPrice.CssClass}');
          if( flightPrice.CssClass.contains('flight-has-price' )) {
            if(flightPrice.Price == '') {
              lineTwo = RotatedBox(
                  quarterTurns: 1,
                  child: new Icon(
                    Icons.airplanemode_active,
                    color: isToday == true ? Colors.red : Colors.black,
                    size: 15.0,
                  ));
            } else {
              lineTwo = Text(formatPrice(flightPrice.Currency, flightPrice.Price,places: 0),
                  textScaler: TextScaler.linear(0.8),
                   style: TextStyle(color: textColor),);
            }
            textStyle = TextStyle( color: Colors.black, fontWeight: FontWeight.bold);
          } else if( flightPrice.CssClass.contains('not-available')){
            isDisabled = true;
            textStyle = TextStyle( color: Colors.grey.shade400, fontWeight: FontWeight.bold);
            lineTwo =  Text('-', style: TextStyle(color: textColor),);
          } else if( flightPrice.CssClass.contains('no-price')){
            isDisabled = true;
            textStyle = TextStyle( color: Colors.grey.shade400, fontWeight: FontWeight.bold);
            lineTwo =  Text('-', style: TextStyle(color: textColor),);
          }

          if(isSelected != null && isSelected == true){
            textStyle = TextStyle( color: Colors.white, fontWeight: FontWeight.bold);
            decoration = BoxDecoration(color: Colors.red,
                borderRadius: BorderRadius.circular(1));
          }

        }
      });
    }
    return Container(
      margin:  EdgeInsets.fromLTRB(1, 0, 1, 0),
      //padding: EdgeInsets.fromLTRB(1, 0, 1, 0),
      decoration: decoration,
      child: Center(
        child: Stack(
          alignment: AlignmentDirectional.topCenter,
          children: [
            Text(
              MaterialLocalizations.of(context).formatDecimal(date.day),
              style: textStyle,
              textScaleFactor: 1,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 18),
              child: Container(
                child: lineTwo,
 /*               height: 4,
                width: 4,*/
/*
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: isSelected == true
                      ? Colors.white
                      : Colors.grey[500],
                ),
*/
              ),
            ),
          ],
        ),
      ),


    );
  }
  void checkDataUpdate(){
    if( gblFlightPrices == null ){
      // first load
      _initData(widget.departureDate);
    }
  }
}