import 'package:flutter/material.dart';
import 'package:vmba/components/showDialog.dart';
import 'package:vmba/components/vidButtons.dart';
import 'package:vmba/data/SystemColors.dart';
import 'package:vmba/data/models/models.dart';
import 'package:vmba/data/globals.dart';
import 'package:vmba/components/trText.dart';
import 'package:vmba/menu/icons.dart';
import 'package:vmba/v3pages/v3Theme.dart';

import '../../Helpers/settingsHelper.dart';
import '../../Helpers/stringHelpers.dart';
import '../../components/pageStyleV2.dart';
import '../../functions/text.dart';

class PassengerWidget extends StatefulWidget {
  PassengerWidget({Key key= const Key("paxwi_key"), this.systemColors, this.passengers, this.onChanged})
      : super(key: key);

  final SystemColors? systemColors;
  final Passengers? passengers;
  final ValueChanged<Passengers>? onChanged;


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
  late bool expanded;

  @override
  initState() {
    super.initState();
    expanded = false;
    if (widget.passengers != null) {
      adults = widget.passengers!.adults;
      children = widget.passengers!.children;
      infants = widget.passengers!.infants;
      youths = widget.passengers!.youths;
      students = widget.passengers!.students;
      seniors = widget.passengers!.seniors;
      teachers = widget.passengers!.teachers;
    }
  }

  void _removeAdult() {
    if( widget.passengers!.adults == 1 && gblSettings.wantUmnr == false) {
     return;
    }
    if( widget.passengers!.adults == 0) {
      return;
    }

    widget.passengers!.adults -= 1;
    setState(() {
      adults -= 1;
    });
  }

  void _addAdult() {
    widget.passengers!.adults += 1;
    setState(() {
      adults += 1;
    });
  }

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
        widget.passengers!.adults = value.adults;
        widget.passengers!.children = value.children;
        widget.passengers!.infants = value.infants;
        widget.passengers!.youths = value.youths;
        widget.passengers!.students = value.students;
        widget.passengers!.seniors = value.seniors;
        widget.passengers!.teachers = value.teachers;
      });
    }
    widget.onChanged!(widget.passengers as Passengers);
  }

  @override
  Widget build(BuildContext context) {

    if( wantHomePageV3()) {

      List<Widget> list = [];
//        list.add(_getAdults(),);
        PaxRowInfo pri = PaxRowInfo(min: 1, max: gblSettings.maxNumberOfPax,
            iconName: 'adult', typeName: 'Adult', description: '16 years and above', count: widget.passengers!.adults);
        list.add(getPaxRow(pri, (PaxRowInfo priOut){
          widget.passengers!.adults = priOut.count;
          setState(() {             });
        } ));
        if( expanded) {
          if(gblSettings.passengerTypes.youths) {
            PaxRowInfo pri = PaxRowInfo(min: 0, max: gblSettings.maxNumberOfPax,
              iconName: 'youth', typeName: 'Youths', description: '12 to 15 years', count: widget.passengers!.youths);
            list.add(getPaxRow(pri, (PaxRowInfo priOut){
              widget.passengers!.youths = priOut.count;
              setState(() {             });
            } ));
          }
          if(gblSettings.passengerTypes.child) {
            PaxRowInfo pri = PaxRowInfo(min: 0, max: gblSettings.maxNumberOfPax,
                iconName: 'child', typeName: 'Child', description: 'between 2 and 11 years', count: widget.passengers!.children);
            list.add(getPaxRow(pri, (priOut){
              widget.passengers!.children = priOut.count;
              setState(() {             });
            }));
          }
          if(gblSettings.passengerTypes.infant) {
            PaxRowInfo pri = PaxRowInfo(min: 0, max: gblSettings.maxNumberOfPax,
                iconName: 'infant', typeName: 'Infant', description: 'Under 2 years', count: widget.passengers!.infants);
            list.add(getPaxRow(pri, (priOut){
              widget.passengers!.infants = priOut.count;
              setState(() {             });
            }));
          }
          if( gblSettings.passengerTypes.senior){

          }
          if( gblSettings.passengerTypes.student ){

          }
          return Column(
                children: list,);
        } else {
          PaxRowInfo pri = PaxRowInfo(min: 0, max: gblSettings.maxNumberOfPax,
              iconName: 'people', typeName: 'Other Passengers', description: '', isMoreButton: true);
          list.add(getPaxRow(pri, (priOut){
            expanded = !expanded;
            setState(() {             });
          }));
/*
          list.add(
              Row(
                children: [
                  Expanded(flex: 1, child: Icon(Icons.people, size: 30,)),
                  Expanded(flex: 6, child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        v2SeatchValueText('Other Passengers'),
                        Text('select')
                      ])),
                  Expanded(flex: 2, child: Icon(Icons.chevron_right, size: 30,))
                ],

              )
          );
*/
          return GestureDetector(
              onTap: () {
                expanded = !expanded;
                setState(() {

                });
              },
              child: Column(
                children: list,));
        }

    } else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          new Expanded(

            child: _getAdults(),

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
            child: _getOtherPax(),

            flex: 1,
          ),
        ],
      );
    }
  }

  Widget getPaxRow(PaxRowInfo pri, void Function(PaxRowInfo priOut) onChange) {
    return Row(
      children: [
        Expanded(flex: 1, child: getNamedIcon(pri.iconName)),
        Expanded(flex: 6, child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              v2SearchValueText(pri.typeName),
              Text(pri.description)
            ])),
        //Expanded(flex: 2, child: Icon(Icons.chevron_right, size: 30,))
        Expanded(flex: 1, child: v2SearchValueText(pri.isMoreButton ? '' : pri.count.toString())),
        pri.isMoreButton ?
          Expanded(flex: 2, child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
            IconButton(onPressed: (){
            onChange(pri);
            }, icon: Icon(Icons.chevron_right))]))
        : Expanded(flex: 2, child: upDownButton(pri.count, pri.min, pri.max, (int newVal){
          pri.count = newVal;
          onChange(pri);
            } )),
      ],

    );
  }



  Widget _getOtherPax() {
      return  Container(
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
      );
  }

  Widget _getAdults() {
    if( wantHomePageV3()) {
         return Row(
           mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded( flex: 1, child: Icon(Icons.person, size: 30,)),
              Expanded( flex: 6, child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                v2SearchValueText('Adult'),
                Text('16 years and above')
              ],)),
              Expanded( flex: 1, child: v2SearchValueText(adults.toString())),
              Row(
                mainAxisSize: MainAxisSize.min,
                  children: [
                  new IconButton(
                  icon: Icon(
                    adults <= 1 ? Icons.remove_circle_outline : Icons.remove_circle_outlined,
                  ),
                  onPressed: adults == 1 ? null : _removeAdult,
                ),
  //              new Text(translateNo(adults.toString()), style: TextStyle(fontSize: 20)),
                new IconButton(
                  icon: Icon(
                    adults < gblSettings.maxNumberOfPax ?
                    Icons.add_circle_outlined : Icons.add_circle_outline,
                  ),
                  onPressed: adults < gblSettings.maxNumberOfPax ? _addAdult : null ,
                ),
                ])
            ],
          );

    } else {
      return Container(
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
                    adults <= 1 ? Icons.remove_circle_outline : Icons.remove_circle_outlined,
                  ),
                  onPressed: adults == 1 ? null : _removeAdult,
                ),
                new Text(adults.toString(), style: TextStyle(fontSize: 20)),
                new IconButton(

                    icon: Icon(
                      adults < gblSettings.maxNumberOfPax ?
                      Icons.add_circle_outlined : Icons.add_circle_outline,
                    ),
                    onPressed: adults < gblSettings.maxNumberOfPax ? _addAdult : null ,

                ),
              ],
            ),
          ],
        ),
      );
    }
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
  PassengerSelectionPage({Key key= const Key("paxsel_key"), this.passengers, this.systemColors})
      : super(key: key);

  //final ValueChanged<Passengers> onChanged;
  final Passengers? passengers;
  final SystemColors? systemColors;
  @override
  _PassengerSelectionPageState createState() => _PassengerSelectionPageState();
}

class _PassengerSelectionPageState extends State<PassengerSelectionPage> {
  // int adults = 1;
  // int children = 0;
  // int infants = 0;
  late Passengers passengers ;
  @override
  initState() {
    super.initState();
    // adults = widget.passengers.adults;
    // children = widget.passengers.children;
    // infants = widget.passengers.infants;
    passengers = new Passengers(
        widget.passengers!.adults,
        widget.passengers!.children,
        widget.passengers!.infants,
        widget.passengers!.youths,
        widget.passengers!.seniors,
        widget.passengers!.students,
        widget.passengers!.teachers);
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
        floatingActionButton: doneButton(),
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
                                passengers.adults == 0 ? Icons.remove_circle_outline : Icons.remove_circle_outlined,
                              ),
                              onPressed: () {
                                if(passengers.adults > 0 ) _removeAdult();
                              },
                            ),
                            new Text(passengers.adults.toString()),
                            new IconButton(
                              icon: Icon( passengers.adults < gblSettings.maxNumberOfPax ? Icons.add_circle_outlined : Icons.add_circle_outline),
                              onPressed: passengers.adults < gblSettings.maxNumberOfPax ?  _addAdult : null ,
                            ),
                          ],
                        ),
                      ],
                    ),
                    wantHomePageV3() ? V3Divider(): Container(),

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
                                      passengers.youths == 0 ? Icons.remove_circle_outline : Icons.remove_circle_outlined,
                                    ),
                                    onPressed: passengers.youths == 0
                                        ? null
                                        : _removeYouth,
                                  ),
                                  new Text(passengers.youths.toString()),
                                  new IconButton(
                                    icon: Icon(
                                      passengers.youths < gblSettings.maxNumberOfPax ? Icons.add_circle_outlined : Icons.add_circle_outline),
                                    onPressed: passengers.youths < gblSettings.maxNumberOfPax ? _addYouth : null ,
                                  ),
                                ],
                              ),
                            ],
                          )
                        : Padding(
                            padding: EdgeInsets.all(0),
                          ),
                    (wantHomePageV3() && gblSettings.passengerTypes.youths) ? V3Divider(): Container(),

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
                                passengers.seniors == 0 ? Icons.remove_circle_outline : Icons.remove_circle_outlined,
                              ),
                              onPressed: passengers.seniors == 0
                                  ? null
                                  : _removeSenior,
                            ),
                            new Text(passengers.seniors.toString()),
                            new IconButton(
                              icon: Icon(passengers.seniors < gblSettings.maxNumberOfPax ? Icons.add_circle_outlined : Icons.add_circle_outline),
                              onPressed: passengers.seniors < gblSettings.maxNumberOfPax ? _addSenior : null ,
                            ),
                          ],
                        ),
                      ],
                    )
                        : Padding(
                      padding: EdgeInsets.all(0),
                    ),
                    (wantHomePageV3() && gblSettings.passengerTypes.senior) ? V3Divider(): Container(),

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
                                passengers.students == 0 ? Icons.remove_circle_outline : Icons.add_circle_outlined,
                              ),
                              onPressed: passengers.students == 0
                                  ? null
                                  : _removeStudent,
                            ),
                            new Text(passengers.students.toString()),
                            new IconButton(
                              icon: Icon(passengers.students < gblSettings.maxNumberOfPax ? Icons.add_circle_outlined : Icons.add_circle_outline),
                              onPressed: passengers.students < gblSettings.maxNumberOfPax ? _addStudent : null ,
                            ),
                          ],
                        ),
                      ],
                    )
                        : Padding(
                      padding: EdgeInsets.all(0),
                    ),
                    (wantHomePageV3() && gblSettings.passengerTypes.student) ? V3Divider(): Container(),

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
                                passengers.children == 0 ? Icons.remove_circle_outline : Icons.remove_circle_outlined,
                              ),
                              onPressed: passengers.children == 0
                                  ? null
                                  : _removeChild,
                            ),
                            new Text(passengers.children.toString()),
                            new IconButton(
                              icon: Icon(passengers.children < gblSettings.maxNumberOfPax ? Icons.add_circle_outlined : Icons.add_circle_outline),
                              onPressed: passengers.children < gblSettings.maxNumberOfPax ? _addChild : null,
                            ),
                          ],
                        ),
                      ],
                    ),
                    wantHomePageV3() ? V3Divider(): Container(),
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
                                passengers.infants == 0 ? Icons.remove_circle_outline : Icons.remove_circle_outlined,
                              ),
                              onPressed: passengers.infants == 0
                                  ? null
                                  : _removeInfant,
                            ),
                            new Text(passengers.infants.toString()),
                            new IconButton(
                              icon: Icon(passengers.infants < gblSettings.maxNumberOfInfants ? Icons.add_circle_outlined : Icons.add_circle_outline),
                              onPressed: passengers.infants < gblSettings.maxNumberOfInfants ? _addInfant : null,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ]),
            )));
  }
  Widget doneButton() {
    if( wantHomePageV3()){
      return vidWideActionButton(context, 'Done',
              (p0, p1) {
                if ( passengers.totalPassengers() > 0) {
                  Navigator.pop(context, passengers);
                } else {
                  showVidDialog(context, 'Alert', 'Please select who is travelling');
                }
              }, offset: 35);
    }
    return Padding(
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
                backgroundColor: widget.systemColors!
                    .primaryButtonColor, //new Color(0xFF000000),
                onPressed: () {
                  if ( passengers.totalPassengers() > 0) {
                    Navigator.pop(context, passengers);
                  } else {
                    showVidDialog(context, 'Alert', 'Please select who is travelling');
                  }
                }),
          ],
        ));
  }
}

Widget upDownButton(int val, int min, int max, void Function(int val) onChange ){
  return Container(
      height: 30,
      //padding: EdgeInsets.all(1.5),
      width: 150,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 1),
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Row(
        children: <Widget>[  
          Expanded(
              child: InkWell(
                  onTap: () {
                    if( val > min) {
                      onChange(val - 1);
                    }
                  },
                  child: Container(
                    alignment: Alignment.center,
                    color: Colors.transparent,
                    child: Icon(Icons.remove, size: 20, weight: 300, color: val == min ? Colors.grey.shade400 : Colors.black,)),
                  )),
          Expanded(
              child: InkWell(
                  onTap: () {
                    if( val < (max)) {
                    onChange(val+1);
                    }
                  },
                  child: Container(
                    color: Colors.transparent,
                    alignment: Alignment.center,
                    child: Icon(Icons.add, size: 25, weight: 200, color: val < max ? Colors.black : Colors.grey.shade300))
                  )),
        ],
      ));

}



class PaxRowInfo {
  String typeName = '';
  String iconName = '';
  String description = '';
  int count = 0;
  int max = 9;
  int min = 0;
  bool isMoreButton;
  PaxRowInfo({required this.min, required this.max, required this.description, required this.iconName,
    this.count =0, required this.typeName, this.isMoreButton = false});
}



