import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vmba/data/globals.dart';
import 'package:vmba/datePickers/rangePickerPage.dart';
import 'package:vmba/datePickers/datePickerPage.dart';
import 'package:vmba/datePickers/models/flightDatesModel.dart';

class JourneyDateWidget extends StatefulWidget {
  JourneyDateWidget({Key key, this.isReturn: false, this.onChanged})
      : super(key: key);

  final bool isReturn;
  final ValueChanged<FlightDates> onChanged;

  _JourneyDateWidgetState createState() => _JourneyDateWidgetState();
}

class _JourneyDateWidgetState extends State<JourneyDateWidget> {
  DateTime _departingingDate =
      new DateTime.now().add(new Duration(days: gblSettings.searchDateOut)); //new DateTime.now();
  DateTime _returningDate =
      new DateTime.now().add(new Duration(days: gblSettings.searchDateBack)); //new DateTime.now();
  bool dateSelected = false;

  void _selectedDate(FlightDates _flightDates) {

     if (_flightDates != null)  {
      widget.onChanged(_flightDates);
      setState(() {
        _departingingDate = _flightDates.departureDate;
        _returningDate = _flightDates.returnDate;
        dateSelected = true;
      }); 
     }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isReturn) {
      if (_returningDate == null) {
        _departingingDate = new DateTime.now().add(new Duration(days: gblSettings.searchDateOut));
        _returningDate = new DateTime.now().add(new Duration(days: gblSettings.searchDateBack));
        dateSelected = false;
      }
    } else {
      _returningDate = null;
    }

    String _displayText =
        widget.isReturn ? 'Choose travel dates' : 'Choose travel date';
    String _returningText = widget.isReturn ? 'Returning' : '';

    return Row(children: [
      new Expanded(
          child: new Container(
        child: InkWell(
          onTap: () async {
            FlightDates _flightDates = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => widget.isReturn
                    ? RangePickerWidget(
                        departureDate: _departingingDate,
                        returnDate: _returningDate)
                    : DatePickerWidget(
                        departureDate: _departingingDate,
                      ),
              ),
            );
            _selectedDate(_flightDates);
          },
          child: Column(
            children: <Widget>[
              Row(children: <Widget>[
                Expanded(
                    child: Text('Departing',
                        style: new TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15.0))),
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(_returningText,
                      style: new TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15.0)),
                ))
              ]),
              dateSelected
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                                DateFormat('E d')
                                    .format(_departingingDate)
                                    .toString(), //'Wed 3',
                                style: new TextStyle(
                                    fontWeight: FontWeight.w300,
                                    fontSize: 18.0,
                                    //color: Colors.grey,
                                    )),
                            Text(
                                DateFormat('MMMM yyyy')
                                    .format(_departingingDate)
                                    .toString(), //'July 2019',
                                style: new TextStyle(
                                    fontWeight: FontWeight.w300,
                                    fontSize: 18.0,
                                   // color: Colors.grey,
                                    ))
                          ],
                        )),
                        Expanded(
                            child: Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: //<Widget>[
                             widget.isReturn ? [Text(
                                  DateFormat('E d')
                                      .format(_returningDate)
                                      .toString(), //'Sun 7',
                                  style: new TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: 18.0,
                                      //color: Colors.grey,
                                      )),
                              Text(
                                  DateFormat('MMMM yyyy')
                                      .format(_returningDate)
                                      .toString(), //'July 2019',
                                  style: new TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: 18.0,
                                      //color: Colors.grey,
                                      ))] :
                                      [Text('')],
                            //],
                          ),
                        ))
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(_displayText,
                              style: new TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.w300,
                                color: Colors.grey,
                              )),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ))
    ]);
  }
}
