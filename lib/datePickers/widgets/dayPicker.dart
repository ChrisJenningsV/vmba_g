import 'package:flutter/material.dart';
//import 'package:flutter_date_pickers/flutter_date_pickers.dart' ;
import 'package:vmba/datePickers/models/flightDatesModel.dart';

class DayPickerPage extends StatefulWidget {
  DayPickerPage(
      {Key key,
      this.departureDate,
      this.lastDate,
      this.firstDate,
      this.onChanged})
      : super(key: key);

  final DateTime departureDate;
  final DateTime lastDate;
  final DateTime firstDate;
  final ValueChanged<FlightDates> onChanged;
  @override
  State<StatefulWidget> createState() => _DayPickerPageState();
}

class _DayPickerPageState extends State<DayPickerPage> {
  DateTime _selectedDate;
  DateTime _firstDate;
  DateTime _lastDate;

  Color selectedDateStyleColor;
  Color selectedSingleDateDecorationColor;

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

 /*
    try {
      initializeDateFormatting(gblLanguage, null);
    } catch(e) {
      print(e);
    }

  */
  }



  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // defaults for styles
    selectedDateStyleColor = Theme.of(context).accentTextTheme.bodyText2.color;
    selectedSingleDateDecorationColor = Theme.of(context).accentColor;
  }

  @override
  Widget build(BuildContext context) {
   // Provider.of<LocaleModel>(context,listen:false).changelocale(Locale(gblLanguage));
    // add selected colors to default settings

 /*   DatePickerStyles styles = DatePickerStyles(
        selectedDateStyle: Theme.of(context)
            .accentTextTheme
            .bodyText2
            .copyWith(color: selectedDateStyleColor),
        selectedSingleDateDecoration: BoxDecoration(
            color: selectedSingleDateDecorationColor, shape: BoxShape.circle));
*/
    /*
    return Flex(
      direction: MediaQuery.of(context).orientation == Orientation.portrait
          ? Axis.vertical
          : Axis.horizontal,
      children: <Widget>[
        Expanded(
          child: CalendarDatePicker(
            //selectedDate: _selectedDate,
            initialDate: _selectedDate,
            //onChanged: _onSelectedDateChanged,
            onDateChanged: _onSelectedDateChanged,
            firstDate: _firstDate,
            lastDate: _lastDate,
            //datePickerStyles: styles,
          ),
        ),
      ],
    );

     */
    double width = MediaQuery.of(context).size.width;
    return
         Container(
          // margin: const EdgeInsets.symmetric(vertical: 50.0, horizontal: 60),
            width: width - 50,
            height: 400,
            /*
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.orangeAccent, width: 2),
                borderRadius: BorderRadius.all(Radius.circular(40)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ]),

             */
            child: CalendarDatePicker(
              initialDate: _selectedDate,
              firstDate: _firstDate,
              lastDate: _lastDate,
              onDateChanged: _onSelectedDateChanged,
            ));

  }

  void _onSelectedDateChanged(DateTime newDate) {
    setState(() {
      _selectedDate = newDate;
      widget.onChanged(FlightDates(_selectedDate, null));
    });
  }
}

