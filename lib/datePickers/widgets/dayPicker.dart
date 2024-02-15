import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vmba/data/globals.dart';
//import 'package:flutter_date_pickers/flutter_date_pickers.dart' ;
import 'package:vmba/datePickers/models/flightDatesModel.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';

import '../../data/models/pnr.dart';
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

    //_selectedDate = widget.departureDate;
    _selectedDate = DateTime.now().subtract(Duration(days: 31));
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

    if (gblSettings.wantPriceCalendar == true) {
      CalendarDatePicker2Config config = CalendarDatePicker2Config(
        firstDate: _firstDate,
        lastDate: _lastDate,
        dayBuilder: _dayBuilder,
      );


      List<DateTime?> _singleDatePickerValueWithDefaultValue = [
        _selectedDate,
      ];
      return
        Container(
          // margin: const EdgeInsets.symmetric(vertical: 50.0, horizontal: 60),
            width: width - 50,
            height: 400,
            child:
                Column( children: [
                  CalendarDatePicker2(
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
         /*         SizedBox( height: 15, width: 15,
                      child: DataLoaderWidget(dataType: LoadDataType.calprices,
                  newBooking: null,
                  selectedDate: _selectedDate,
                  pnrModel: PnrModel(),
                  onComplete: (PnrModel pnrModel) {
                    Timer(Duration(seconds : 1), ()
                    {
                      setState(() {

                      });
                    });
                  },
                  )),*/

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
    BoxDecoration? decoration,
    bool? isSelected ,
    bool? isDisabled ,
    bool? isToday,}) {

    Widget lineTwo = Text('');
    //(isDisabled == null || isDisabled== true)?Text(''): Text('£129', textScaleFactor: 0.75,)

    if(isToday != null && isToday == true ){
      textStyle = TextStyle( color: Colors.red);
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
              textStyle = TextStyle( color: Colors.red);
          //  }
          }
          //logit('${flightPrice.FlightDate} ${flightPrice.CssClass}');
          if( flightPrice.CssClass.contains('flight-has-price' )) {
            lineTwo = RotatedBox(
                quarterTurns: 1,
                child: new Icon(
                  Icons.airplanemode_active,
                  color: isToday == true ? Colors.red : Colors.black,
                  size: 15.0,
                ));
          } else if( flightPrice.CssClass.contains('not-available')){
            isDisabled = true;
            textStyle = TextStyle( color: Colors.grey.shade400);
            lineTwo =  Text('-');
          } else if( flightPrice.CssClass.contains('no-price')){
            isDisabled = true;
            textStyle = TextStyle( color: Colors.grey.shade400);
            lineTwo =  Text('-');
          }
        }
      });
    }
    return Container(
      decoration: decoration,
      child: Center(
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: [
            Text(
              MaterialLocalizations.of(context).formatDecimal(date.day),
              style: textStyle,
              textScaleFactor: 1.25,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 27.5),
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