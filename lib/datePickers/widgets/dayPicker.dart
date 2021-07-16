import 'package:flutter/material.dart';
import 'package:flutter_date_pickers/flutter_date_pickers.dart' as dp;
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

    // _firstDate = DateTime.parse(
    //     DateFormat('y-MM-dd').format(DateTime.now()) + ' 00:00:00');
    if (widget.lastDate != null) {
      _lastDate = widget.lastDate;
    } else {
      _lastDate = DateTime.now().add(Duration(days: 364));
    }
    try {
//      initializeDateFormatting(gblLanguage, null);
//      Intl.defaultLocale =gblLanguage;

    } catch(e) {
      print(e);
    }
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
    // add selected colors to default settings
    dp.DatePickerStyles styles = dp.DatePickerStyles(
        selectedDateStyle: Theme.of(context)
            .accentTextTheme
            .bodyText2
            .copyWith(color: selectedDateStyleColor),
        selectedSingleDateDecoration: BoxDecoration(
            color: selectedSingleDateDecorationColor, shape: BoxShape.circle));

    return Flex(
      direction: MediaQuery.of(context).orientation == Orientation.portrait
          ? Axis.vertical
          : Axis.horizontal,
      children: <Widget>[
        Expanded(
          child: dp.DayPicker(
            selectedDate: _selectedDate,
            onChanged: _onSelectedDateChanged,
            firstDate: _firstDate,
            lastDate: _lastDate,
            datePickerStyles: styles,
          ),
        ),
      ],
    );
  }

  void _onSelectedDateChanged(DateTime newDate) {
    setState(() {
      _selectedDate = newDate;
      widget.onChanged(FlightDates(_selectedDate, null));
    });
  }
}
