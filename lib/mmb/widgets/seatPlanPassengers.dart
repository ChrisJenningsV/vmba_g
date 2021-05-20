import 'package:flutter/material.dart';
import 'package:vmba/data/SystemColors.dart';
import 'package:vmba/data/models/pax.dart';

class SeatPlanPassengersWidget extends StatefulWidget {
  SeatPlanPassengersWidget(
      {Key key, this.onChanged, this.paxList, this.systemColors})
      : super(key: key);
  final List<Pax> paxList;
  final SystemColors systemColors;
  final ValueChanged<List<Pax>> onChanged;

  _SeatPlanPassengersWidgetState createState() =>
      _SeatPlanPassengersWidgetState();
}

class _SeatPlanPassengersWidgetState extends State<SeatPlanPassengersWidget> {
  static Color selectedBackground = Colors.black;
  static Color selectedText = Colors.green;
  static Color unselectedBackground = Colors.white;
  static Color unselectedText = Colors.black;

  List<Pax> paxlist;

  @override
  initState() {
    super.initState();
    paxlist = widget.paxList;
    selectedBackground = widget.systemColors.primaryButtonColor;
    selectedText = widget.systemColors.primaryButtonTextColor;
  }

  void _toggleSelectedPax(int _id) {
    setState(() {
      paxlist.forEach((element) => element.selected = false);
      paxlist[_id - 1].selected = true;
    });
    widget.onChanged(paxlist);
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: renderPax(),
    );
  }

  List<Widget> renderPax() {
    List<Widget> paxWidgets = [];
    // List<Widget>();
    for (var pax = 0; pax < paxlist.length; pax++) {
      paxWidgets.add(new GestureDetector(
        child: new Container(
          color: paxlist[pax].selected == true
              ? selectedBackground
              : unselectedBackground,
          width: MediaQuery.of(context).size.width * 0.5,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Text(
                paxlist[pax].name,
                style: TextStyle(
                    color: paxlist[pax].selected == true
                        ? selectedText
                        : unselectedText),
              ),
              Text(
                paxlist[pax].seat == null || paxlist[pax].seat == ''
                    ? 'Select Seat'
                    : paxlist[pax].seat,
                style: TextStyle(
                    color: paxlist[pax].selected == true
                        ? selectedText
                        : unselectedText),
              ),
            ],
          ),
        ),
        onTap: () => _toggleSelectedPax(paxlist[pax].id),
      ));
    }
    if (!paxlist.length.isEven) {
      //add blank pax box
      paxWidgets.add(Container(
          color: unselectedBackground,
          width: MediaQuery.of(context).size.width * 0.5,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Text(''),
              Text(''),
            ],
          )));
    }

    return paxWidgets;
  }
}
