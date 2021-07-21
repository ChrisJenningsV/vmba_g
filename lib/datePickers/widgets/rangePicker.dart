import 'package:flutter/material.dart';
import 'package:flutter_date_pickers/flutter_date_pickers.dart';
import 'package:intl/intl.dart';
import 'package:vmba/datePickers/models/flightDatesModel.dart';
import 'package:vmba/components/trText.dart';
import 'package:vmba/calendar/flightPageUtils.dart';

class RangePickerPage extends StatefulWidget {
  RangePickerPage(
      {Key key, this.departureDate, this.returnDate, this.onChanged})
      : super(key: key);

  final DateTime departureDate;
  final DateTime returnDate;
  final ValueChanged<FlightDates> onChanged;

  @override
  State<StatefulWidget> createState() => _RangePickerPageState();
}

class _RangePickerPageState extends State<RangePickerPage> {
  DateTime _firstDate;
  DateTime _lastDate;
  DatePeriod _selectedPeriod;

  Color selectedPeriodStartColor;
  Color selectedPeriodLastColor;
  Color selectedPeriodMiddleColor;

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
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // defaults for styles
    selectedPeriodLastColor = Theme.of(context).accentColor;
    selectedPeriodMiddleColor = Colors.black26; //Theme.of(context).accentColor;
    selectedPeriodStartColor = Theme.of(context).accentColor;
  }

  @override
  Widget build(BuildContext context) {
    // add selected colors to default settings
    DatePickerRangeStyles styles = DatePickerRangeStyles(
      selectedPeriodLastDecoration: BoxDecoration(
          color: selectedPeriodLastColor,
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(20.0),
              bottomRight: Radius.circular(20.0))),
      selectedPeriodStartDecoration: BoxDecoration(
        color: selectedPeriodStartColor,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0), bottomLeft: Radius.circular(20.0)),
      ),
      selectedPeriodMiddleDecoration: BoxDecoration(
          color: selectedPeriodMiddleColor, shape: BoxShape.rectangle),
    );

    return Flex(
      direction: MediaQuery.of(context).orientation == Orientation.portrait
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

  void _onSelectedDateChanged(DatePeriod newPeriod) {
    setState(() {
      _selectedPeriod = newPeriod;
      widget.onChanged(FlightDates(newPeriod.start, newPeriod.end));
    });
  }
}
