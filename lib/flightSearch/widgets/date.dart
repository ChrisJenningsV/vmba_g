import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:vmba/data/globals.dart';
import 'package:vmba/datePickers/rangePickerPage.dart';
import 'package:vmba/datePickers/datePickerPage.dart';
import 'package:vmba/datePickers/models/flightDatesModel.dart';
import 'package:vmba/components/trText.dart';
import 'package:vmba/calendar/flightPageUtils.dart';

import '../../Helpers/settingsHelper.dart';
import '../../components/pageStyleV2.dart';


class JourneyDateWidget extends StatefulWidget {
  JourneyDateWidget({Key key= const Key("jdate_key"), this.isReturn: false, required this.onChanged})
      : super(key: key);

  final bool isReturn;
  final ValueChanged<FlightDates> onChanged;

  _JourneyDateWidgetState createState() => _JourneyDateWidgetState();
}

class _JourneyDateWidgetState extends State<JourneyDateWidget> {
  DateTime _departingingDate =
      new DateTime.now().add(new Duration(days: gblSettings.searchDateOut)); //new DateTime.now();
  DateTime? _returningDate =
      new DateTime.now().add(new Duration(days: gblSettings.searchDateBack)); //new DateTime.now();
  bool dateSelected = false;
  String _returningText ='';
  String _displayText = '';

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

    _displayText =
        widget.isReturn ? translate('Choose travel dates') : translate('Choose travel date');
     _returningText = widget.isReturn ? 'Returning' : '';

    return Row(children: [
      new Expanded(
          child: new Container(
        child: InkWell(
          onTap: () async {
            FlightDates? _flightDates = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => widget.isReturn
                    ? RangePickerWidget(
                        departureDate: _departingingDate,
                        returnDate: _returningDate!)
                    : DatePickerWidget(
                        departureDate: _departingingDate,
                      ),
              ),
            );
            if( _flightDates != null )_selectedDate(_flightDates);
          },
          child: Column(
            children: _getDates(),
          ),
        ),
      ))
    ]);
  }
  List <Widget> _getDates() {
    List <Widget> list = [];

    if( wantPageV2()) {
      List <Widget> list2 = [];
      if (dateSelected) {
        list2.add(
            Expanded(
              flex: 1,
               child: v2BorderBox(context, ' ' + translate('Departing'),
            Row(
              children: [
                Icon(PhosphorIcons.calendar, color:  gblSystemColors.textEditIconColor, ),
                Text(getIntlDate('dd MMM yyyy', _departingingDate), textScaleFactor: 1.25,style: TextStyle(fontWeight: FontWeight.bold),),
              ],
            )))
            );
        list2.add(Padding(padding: EdgeInsets.all(5)));
        list2.add(
          Expanded(
              flex: 1,
              child:
                  widget.isReturn ?  v2BorderBox(context, ' ' + translate(_returningText), Row(
          children: [
             Icon(PhosphorIcons.calendar, color:  gblSystemColors.textEditIconColor, ) ,
            Text(getIntlDate('dd MMM yyyy', _returningDate as DateTime), textScaleFactor: 1.25,style: TextStyle(fontWeight: FontWeight.bold),),
          ],
        )): Container(),
              )

        );
      } else {

          list2.add(
              Expanded(
                  flex: 1,
                  child:v2BorderBox(context, ' ' + translate('Departing'),
              Row(
                children: [
                  Icon(PhosphorIcons.calendar, color:  gblSystemColors.textEditIconColor, ),
                  Text(_displayText),
                ],
              ))));
          list2.add(Padding(padding: EdgeInsets.all(5)));
          list2.add(
            Expanded(
                flex: 1,
                child: widget.isReturn ? v2BorderBox(context, ' ' + translate(_returningText),
              Row(
                children: [
                  Icon(PhosphorIcons.calendar, color:  gblSystemColors.textEditIconColor, ) ,
                  Text(''),
                ],
              ))
                    : Container())
          );

      }
      list.add(Row(children: list2,));
    } else {
      list.add(Row(children: <Widget>[
        Expanded(
            child: TrText('Departing',
                style: new TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 15.0))),
        Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: TrText(_returningText,
                  style: new TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15.0)),
            ))
      ]));

      if (dateSelected) {
        list.add(Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(getIntlDate('E d', _departingingDate),
                        //DateFormat('E d').format(_departingingDate).toString(), //'Wed 3',
                        style: new TextStyle(
                          fontWeight: FontWeight.w300,
                          fontSize: 18.0,
                          //color: Colors.grey,
                        )),
                    Text(getIntlDate('MMMM yyyy', _departingingDate),
                        //DateFormat('MMMM yyyy').format(_departingingDate).toString(), //'July 2019',
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
                    widget.isReturn ? [Text(getIntlDate('E d', _returningDate as DateTime),
                        //DateFormat('E d').format(_returningDate).toString(), //'Sun 7',
                        style: new TextStyle(
                          fontWeight: FontWeight.w300,
                          fontSize: 18.0,
                          //color: Colors.grey,
                        )),
                      Text(getIntlDate('MMMM yyyy', _returningDate as DateTime),
                          //DateFormat('MMMM yyyy').format(_returningDate).toString(), //'July 2019',
                          style: new TextStyle(
                            fontWeight: FontWeight.w300,
                            fontSize: 18.0,
                            //color: Colors.grey,
                          ))
                    ] :
                    [Text('')],
                    //],
                  ),
                ))
          ],
        )
        );
      } else {
        list.add(Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: TrText(_displayText,
                  style: new TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w300,
                    color: Colors.grey,
                  )),
            ),
          ],
        ));
      }
    }
    return list;
  }

}
