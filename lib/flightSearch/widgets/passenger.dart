import 'package:flutter/material.dart';
import 'package:vmba/components/showDialog.dart';
import 'package:vmba/data/SystemColors.dart';
import 'package:vmba/data/models/models.dart';
import 'package:vmba/data/globals.dart';
import 'package:vmba/components/trText.dart';

class PassengerWidget extends StatefulWidget {
  PassengerWidget({Key key, this.systemColors, this.passengers, this.onChanged})
      : super(key: key);

  final SystemColors systemColors;
  final Passengers passengers;
  final ValueChanged<Passengers> onChanged;

  _PassengerWidgetState createState() => _PassengerWidgetState();
}

class _PassengerWidgetState extends State<PassengerWidget> {
  int adults = 1;
  int children = 0;
  int infants = 0;
  int youths = 0;
  int students = 0;
  int seniors = 0;
  int teachers = 0;

  @override
  initState() {
    super.initState();
    if (widget.passengers != null) {
      adults = widget.passengers.adults;
      children = widget.passengers.children;
      infants = widget.passengers.infants;
      youths = widget.passengers.youths;
      students = widget.passengers.students;
      seniors = widget.passengers.seniors;
      teachers = widget.passengers.teachers;
    }
  }

  void _removeAdult() {
    if( widget.passengers.adults == 1 && gblSettings.wantUmnr == false) {
     return;
    }
    if( widget.passengers.adults == 0) {
      return;
    }

    widget.passengers.adults -= 1;
    setState(() {
      adults -= 1;
    });
  }

  void _addAdult() {
    widget.passengers.adults += 1;
    setState(() {
      adults += 1;
    });
  }

  // void _removeChild() {
  //   setState(() {
  //     children -= 1;
  //   });
  // }

  // void _addChild() {
  //   setState(() {
  //     children += 1;
  //   });
  // }

  // void _removeInfant() {
  //   setState(() {
  //     infants -= 1;
  //   });
  // }

  // void _addInfant() {
  //   setState(() {
  //     infants += 1;
  //   });
  // }

  void _updateAll(Passengers value) {
    if (value != null) {
      setState(() {
        adults = value.adults;
        children = value.children;
        infants = value.infants;
        youths = value.youths;
        students = value.students;
        seniors = value.seniors;
        teachers = value.teachers;
        widget.passengers.adults = value.adults;
        widget.passengers.children = value.children;
        widget.passengers.infants = value.infants;
        widget.passengers.youths = value.youths;
        widget.passengers.students = value.students;
        widget.passengers.seniors = value.seniors;
        widget.passengers.teachers = value.teachers;
      });
    }
    widget.onChanged(widget.passengers);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        new Expanded(
          child: new Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                new TrText("Adults (16+)",
                    style: new TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15.0)),
                new Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    new IconButton(
                      icon: Icon(
                        Icons
                            .remove_circle_outline, // color: widget.systemColors.accentButtonColor,
                      ),
                      onPressed: adults == 1 ? null : _removeAdult,
                    ),
                    new Text(adults.toString(), style: TextStyle(fontSize: 20)),
                    new IconButton(
                      icon: Icon(
                        Icons
                            .add_circle_outline, //color: widget.systemColors.accentButtonColor
                      ),
                      onPressed: _addAdult,
                    ),
                  ],
                ),
              ],
            ),
          ),
          flex: 1,
        ),
        Container(
            padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
            height: 60,
            child: new VerticalDivider(
              color: Colors.black26,
              width: 4,
            )),
        new Expanded(
          child: new Container(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              new TrText("Other Passengers", //"Children & Infants",
                  style: new TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15.0)),
              new GestureDetector(
                onTap: () {
                  //  _selectedDate(context);
                  _navigateToNewScreen(context);
                },
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 12, 0, 0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Expanded(
                        child: (infants + children + youths + seniors + students + teachers) == 0
                            ? TrText("Select",
                                style: new TextStyle(
                                    fontWeight: FontWeight.w300,
                                    fontSize: 20.0,
                                    color: Colors.grey))
                            : Text((infants + children + youths + seniors + students + teachers ).toString(),
                                style: new TextStyle(
                                  //fontWeight: FontWeight.w300,
                                  fontSize: 20.0,
                                  //color: Colors.grey
                                )),
                      ),
                    ],
                  ),
                ),
              ),
            ]),
          ),
          flex: 1,
        ),
      ],
    );
  }

  _navigateToNewScreen(BuildContext context) async {
    Passengers pax = new Passengers(adults, children, infants, youths, seniors, students, teachers);
    Passengers results = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => PassengerSelectionPage(
              systemColors: widget.systemColors, passengers: pax)),
    );
    _updateAll(results);
  }
}

class PassengerSelectionPage extends StatefulWidget {
  PassengerSelectionPage({Key key, this.passengers, this.systemColors})
      : super(key: key);

  //final ValueChanged<Passengers> onChanged;
  final Passengers passengers;
  final SystemColors systemColors;
  @override
  _PassengerSelectionPageState createState() => _PassengerSelectionPageState();
}

class _PassengerSelectionPageState extends State<PassengerSelectionPage> {
  // int adults = 1;
  // int children = 0;
  // int infants = 0;
  Passengers passengers;
  @override
  initState() {
    super.initState();
    // adults = widget.passengers.adults;
    // children = widget.passengers.children;
    // infants = widget.passengers.infants;
    passengers = new Passengers(
        widget.passengers.adults,
        widget.passengers.children,
        widget.passengers.infants,
        widget.passengers.youths,
        widget.passengers.seniors,
        widget.passengers.students,
        widget.passengers.teachers);
  }


  void _removeAdult() {
    if( gblSettings.youthIsAdult) {
      if (passengers.adults == 1 && gblSettings.wantUmnr == false &&
        passengers.seniors == 0 && passengers.youths == 0) {
        return;
      }
    } else {
      if (passengers.adults == 1 && gblSettings.wantUmnr == false &&
        passengers.seniors == 0 ) {
        return;
      }
    }
    if( passengers.adults == 0) {
      return;
    }


    setState(() {
      passengers.adults -= 1;
      // passengers.adults -= 1;
      // widget.passengers.adults = adults;
    });
  }

  void _addAdult() {
    setState(() {
      passengers.adults += 1;
      //widget.passengers.adults = adults;
    });
  }

  void _removeYouth() {
    setState(() {
      passengers.youths -= 1;
    });
  }
  void _removeSenior() {
    setState(() {
      passengers.seniors -= 1;
    });
  }
  void _removeStudent() {
    setState(() {
      passengers.students -= 1;
    });
  }
  void _addYouth() {
    setState(() {
      passengers.youths += 1;
    });
  }
  void _addSenior() {
    setState(() {
      passengers.seniors += 1;
    });
  }
  void _addStudent() {
    setState(() {
      passengers.students += 1;
    });
  }


  void _removeChild() {
    setState(() {
      passengers.children -= 1;
    });
  }

  void _addChild() {
    setState(() {
      passengers.children += 1;
    });
  }

  void _removeInfant() {
    setState(() {
      passengers.infants -= 1;
    });
  }

  void _addInfant() {
    setState(() {
      passengers.infants += 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          //brightness: gblSystemColors.statusBar,
          backgroundColor:
          gblSystemColors.primaryHeaderColor,
          iconTheme: IconThemeData(
              color: gblSystemColors.headerTextColor),
          title: new TrText('Add Passengers',
              style: TextStyle(
                  color:
                  gblSystemColors.headerTextColor)),
        ),
        floatingActionButton: Padding(
            padding: EdgeInsets.only(left: 35.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new FloatingActionButton.extended(
                    elevation: 0.0,
                    isExtended: true,
                    label: TrText(
                      'Done',
                      style: TextStyle(
                          color: gblSystemColors
                              .primaryButtonTextColor),
                    ),
                    icon: Icon(Icons.check,
                        color: gblSystemColors
                            .primaryButtonTextColor),
                    backgroundColor: widget.systemColors
                        .primaryButtonColor, //new Color(0xFF000000),
                    onPressed: () {
                      if ( passengers.totalPassengers() > 0) {
                        Navigator.pop(context, passengers);
                      } else {
                        showAlertDialog(context, 'Alert', 'Please select who is travelling');
                      }
                    }),
              ],
            )),
        body: new Container(
            padding: EdgeInsets.all(16.0),
            child: new Form(
              child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            TrText(
                              'Adults',
                              style: new TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                            TrText(
                              '16 years and above',
                              style: new TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w300),
                            )
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            new IconButton(
                              icon: Icon(
                                Icons.remove_circle_outline,
                              ),
                              onPressed: () {
                                _removeAdult();
                              },
                            ),
                            new Text(passengers.adults.toString()),
                            new IconButton(
                              icon: Icon(Icons.add_circle_outline),
                              onPressed: _addAdult,
                            ),
                          ],
                        ),
                      ],
                    ),
                    gblSettings.passengerTypes.youths
                        ? new Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  TrText(
                                    'Youths',
                                    style: new TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700),
                                  ),
                                  TrText(
                                    '12 to 15 years',
                                    style: new TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w300),
                                  ),
                                ],
                              ),
                              Row(
                                children: <Widget>[
                                  new IconButton(
                                    icon: Icon(
                                      Icons.remove_circle_outline,
                                    ),
                                    onPressed: passengers.youths == 0
                                        ? null
                                        : _removeYouth,
                                  ),
                                  new Text(passengers.youths.toString()),
                                  new IconButton(
                                    icon: Icon(Icons.add_circle_outline),
                                    onPressed: _addYouth,
                                  ),
                                ],
                              ),
                            ],
                          )
                        : Padding(
                            padding: EdgeInsets.all(0),
                          ),
                    gblSettings.passengerTypes.senior
                        ? new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            TrText(
                              'Seniors',
                              style: new TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700),
                            ),
                            TrText(
                              'over 65',
                              style: new TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w300),
                            ),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            new IconButton(
                              icon: Icon(
                                Icons.remove_circle_outline,
                              ),
                              onPressed: passengers.seniors == 0
                                  ? null
                                  : _removeSenior,
                            ),
                            new Text(passengers.seniors.toString()),
                            new IconButton(
                              icon: Icon(Icons.add_circle_outline),
                              onPressed: _addSenior,
                            ),
                          ],
                        ),
                      ],
                    )
                        : Padding(
                      padding: EdgeInsets.all(0),
                    ),

                    gblSettings.passengerTypes.student
                        ? new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            TrText(
                              'Students',
                              style: new TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700),
                            ),
                            TrText(
                              'in full time education',
                              style: new TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w300),
                            ),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            new IconButton(
                              icon: Icon(
                                Icons.remove_circle_outline,
                              ),
                              onPressed: passengers.students == 0
                                  ? null
                                  : _removeStudent,
                            ),
                            new Text(passengers.students.toString()),
                            new IconButton(
                              icon: Icon(Icons.add_circle_outline),
                              onPressed: _addStudent,
                            ),
                          ],
                        ),
                      ],
                    )
                        : Padding(
                      padding: EdgeInsets.all(0),
                    ),

                    new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            TrText(
                              'Children',
                              style: new TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                            TrText(
                              '2 to 11 years',
                              style: new TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w300),
                            ),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            new IconButton(
                              icon: Icon(
                                Icons.remove_circle_outline,
                              ),
                              onPressed: passengers.children == 0
                                  ? null
                                  : _removeChild,
                            ),
                            new Text(passengers.children.toString()),
                            new IconButton(
                              icon: Icon(Icons.add_circle_outline),
                              onPressed: _addChild,
                            ),
                          ],
                        ),
                      ],
                    ),
                    new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            TrText(
                              'Infants',
                              style: new TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                            TrText(
                              'Under 2 years',
                              style: new TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w300),
                            ),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            new IconButton(
                              icon: Icon(
                                Icons.remove_circle_outline,
                              ),
                              onPressed: passengers.infants == 0
                                  ? null
                                  : _removeInfant,
                            ),
                            new Text(passengers.infants.toString()),
                            new IconButton(
                              icon: Icon(Icons.add_circle_outline),
                              onPressed: _addInfant,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ]),
            )));
  }
}
