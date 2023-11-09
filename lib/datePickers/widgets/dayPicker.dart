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
                  SizedBox( height: 15, width: 15,
                      child: DataLoaderWidget(dataType: LoadDataType.calprices,
                  newBooking: null,
                  pnrModel: PnrModel(),
                  onComplete: (PnrModel pnrModel) {
                    setState(() {

                    });
                  },
                  )),

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
    if(isToday != null && isToday == true ){
/*
      decoration = BoxDecoration( border: Border.all(width: 1),
              borderRadius: BorderRadius.circular(5.0));
*/
    }
    if( gblFlightPrices != null ) {
      // check for this date
      gblFlightPrices!.flightPrices.forEach((flightPrice) {
 //       logit( ' match ${flightPrice.FlightDate} to ${date.toString().substring(0,10)}');
        if( flightPrice.FlightDate != '' && flightPrice.FlightDate== date.toString().substring(0,10)){
          if( flightPrice.Selectable == false){
            logit( ' match no sel  ${flightPrice.FlightDate}');
        //    if ( textStyle != null ) {
              textStyle = TextStyle( color: Colors.red);
          //  }
          }
          if( flightPrice.CssClass.contains('not-available')){
            isDisabled = true;
            textStyle = TextStyle( color: Colors.blue);
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
                child: (isDisabled == null || isDisabled== true)?Text(''): Text('£129', textScaleFactor: 0.75,),
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
}