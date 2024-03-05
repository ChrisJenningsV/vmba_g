

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vmba/components/vidButtons.dart';
import 'package:vmba/v3pages/cards/typogrify.dart';

import '../../Helpers/stringHelpers.dart';
import '../../calendar/flightPageUtils.dart';
import '../../calendar/outboundFlightPage.dart';
import '../../components/showDialog.dart';
import '../../components/trText.dart';
import '../../data/globals.dart';
import '../../data/models/models.dart';
import '../../data/repository.dart';
import '../../flightSearch/widgets/citylist.dart';
import '../../flightSearch/widgets/type.dart';
import '../../utilities/helper.dart';
import '../v3Constants.dart';

List<String> destinationCities = [];
class FlightSearchBox extends StatefulWidget {
  FlightSearchBox();

  @override
  State<StatefulWidget> createState() => new FlightSearchBoxState();
}

class FlightSearchBoxState extends State<FlightSearchBox> {

  @override void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> list = [];

    if(gblSearchParams.gotAirports()) {
      list.add( Padding(padding: EdgeInsets.only(bottom: 5),
          child: JourneyTypeWidget(
          isReturn: gblSearchParams.isReturn,
          onChanged: _handleReturnToggleChanged)));
    }

    // airports
    list.add(fromToWidgets(context));

    // dates
    if(gblSearchParams.gotAirports()){
      list.add(dateWidgets(context));
    }

    // passengers
    if( gblSearchParams.gotDates()){
      list.add(paxWidgets(context));
      list.add(searchButton(context));
    }

    return Column(
      children: list,
    );
  }

  Widget paxWidgets(BuildContext context){
    String otherPax = 'Select';
    if( gblSearchParams.children > 0 ){
    }
    if( gblSearchParams.youths > 0 ){
    }

    return Wrap(
        alignment: WrapAlignment.spaceEvenly,
        children: [
          SizedBox(
              width: selectAirportCardWidth,
              child: InkWell(
                  onTap: () async {
                    showSlideUpDialog(context, 'Adults', onComplete);
                  },
                  child: Card(
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(10, 5, 5, 10),
                      child: Column(
                        children: [
                          labelText(' ' + translate('Adults 16+')),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              new IconButton(
                                icon: Icon(
                                  gblSearchParams.adults <= 1 ? Icons.remove_circle_outline : Icons.remove_circle_outlined,
                                ),
                                onPressed: gblSearchParams.adults == 1 ? null : () {
                                  gblSearchParams.adults -= 1;
                                  setState(() {

                                  });
                                  },
                              ),
                              new Text(translateNo(gblSearchParams.adults.toString()), style: TextStyle(fontSize: 20)),
                              new IconButton(
                                icon: Icon(
                                  gblSearchParams.adults < gblSettings.maxNumberOfPax ?
                                  Icons.add_circle_outlined : Icons.add_circle_outline,
                                ),
                                onPressed: gblSearchParams.adults < gblSettings.maxNumberOfPax ? () {
                                  setState(() {
                                    gblSearchParams.adults+=1;
                                  });
                                }: null ,
                              ),
                            ],
                          ),

                        ],
                      ),
                    ),
                  )
              )),
          SizedBox(
              width: selectAirportCardWidth,
              child: InkWell(
                  onTap: () async {
                    showSlideUpDialog(context, '', onComplete);
                  },
                  child: Card(
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(10, 5, 5, 10),
                      child: Column(
                        children: [
                          labelText('Other Passengers'),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(otherPax, textScaler: TextScaler.linear(1.0),),
                          )

                        ],
                      ),
                    ),
                  )
              ))
        ]
    );

  }

  Widget searchButton(BuildContext context){
    NewBooking newBooking = NewBooking();
    return Padding(
        padding: EdgeInsets.only(left: 10, right: 10),
        child: vidWideActionButton(context, 'Search',
            (p0, p1) {
      newBooking.clear();
      newBooking.populate(gblSearchParams);
      hasDataConnection().then((result) async {
        if (result == true) {
          await Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (context) =>
                      FlightSeletionPage(
                          newBooking: newBooking)));
        }
             });
      }));
    }



  Widget dateWidgets(BuildContext context){
    String departDate = 'Select date';
    String returningDate = 'Select date';
    if( gblSearchParams.departDate != null ){
      departDate = getIntlDate('dd MMM yyyy', gblSearchParams.departDate as DateTime);
    }
    if( gblSearchParams.returnDate != null ){
      returningDate = getIntlDate('dd MMM yyyy', gblSearchParams.returnDate as DateTime);
    }

    return Padding(padding: EdgeInsets.only(left: 4),
          child: Wrap(
        alignment: WrapAlignment.start,
        children: [
          SizedBox(
        width: selectAirportCardWidth,
        child: InkWell(
        onTap: () async {
          showSlideUpDialog(context, 'Departing', onComplete);
    },
    child: Card(
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 5, 5, 10),
        child: Column(
          children: [
            labelText('Departing'),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(departDate, textScaler: TextScaler.linear(1.0),),
            )

          ],
        ),
      ),
    )
    )),
          gblSearchParams.isReturn == true ?
          SizedBox(
              width: selectAirportCardWidth,
              child: InkWell(
                  onTap: () async {
                    showSlideUpDialog(context, 'Returning', onComplete);
                  },
                  child: Card(
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(10, 5, 5, 10),
                      child: Column(
                        children: [
                          labelText('Returning'),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(returningDate, textScaler: TextScaler.linear(1.0),),
                          )

                        ],
                      ),
                    ),
                  )
              )) :
              Container()
    ]
    ));

  }


  Widget fromToWidgets(BuildContext context)  {
    String originCode = 'Select';
    String originName = '';
    String destCode = 'Select';
    String destName = '';

    if (gblSearchParams.searchOrigin != '') {
      originCode = gblSearchParams.searchOrigin.split('|')[0];
      originName =
          gblSearchParams.searchOrigin.split('|')[1].replaceAll('($originCode)', '');
      getDestinations(originCode);

    }
    if (gblSearchParams.searchDestination != '') {
      destCode = gblSearchParams.searchDestination.split('|')[0];
      destName =gblSearchParams.searchDestination.split('|')[1].replaceAll('($originCode)', '');
    }

    return Wrap(
      alignment: WrapAlignment.spaceEvenly,
      children: [
        SizedBox(
            width: selectAirportCardWidth,
            child: InkWell(
              onTap: () async {
                showSlideUpDialog(context, 'Origin', onComplete);
              },
              child: Card(
                //color: Colors.white54,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(10, 5, 5, 10),
                  child: Column(
                    children: [
                      labelText('From'),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          originCode, textScaler: TextScaler.linear(2.0),),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          originName, textScaler: TextScaler.linear(1.0),),
                      )


                    ],
                  ),
                ),
              ),
            )
        ),

        SizedBox(
            width: selectAirportCardWidth,
            child: InkWell(
              onTap: () async {
                if( destinationCities.length > 0) {
                  showSlideUpDialog(context, 'Destination', onComplete);
                }
              },
              child: Card(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(10, 5, 5, 10),
                  child: Column(
                    children: [
                      labelText('To'),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(destCode, textScaler: TextScaler.linear(2.0),),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(destName, textScaler: TextScaler.linear(1.0),),
                      )

                    ],
                  ),
                ),
              ),
            )
        ),
      ],
    );
  }

  getDestinations(String code) async {
    destinationCities = await Repository.get().getDestinations(code);
  }
  void  onComplete() {
    setState(() {

    });
  }
  void _handleReturnToggleChanged(bool newValue) {
    setState(() {
      gblSearchParams.isReturn = newValue;
    });

  }
}
showSlideUpDialog(BuildContext context, String label, void Function()? onComplete){

  Widget child;
  if( label == 'Departing' || label == 'Returning') {
    child = CupertinoDatePicker(
     // backgroundColor: bgColour,
      //initialDateTime: _initialDateTime,
      onDateTimeChanged: (DateTime newValue) {
        if( label == 'Departing') {
          gblSearchParams.departDate = newValue;
        } else {
          gblSearchParams.returnDate = newValue;
        }
        onComplete!();
      },
      use24hFormat: true,
/*
      maximumDate: _maximumDate,
      minimumYear: _minimumYear,
      maximumYear: _maximumYear,
      minimumDate: _minimumDate,
*/
      mode: CupertinoDatePickerMode.date,
    );
  } else {
    child = cityListView(context, label, onComplete!);
  }

  showGeneralDialog(
    barrierLabel: label,
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: Duration(milliseconds: 1000),
    context: context,
    pageBuilder: (context, anim1, anim2) {
      return Align(
        alignment: Alignment.bottomCenter,
        child: Container(

          height: 600,
          child: SizedBox.expand(
              child: AlertDialog(
                title: Text(translate(label)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(dialogBorderRadius))),

                insetPadding: EdgeInsets.zero,
                //contentPadding: EdgeInsets.zero,
                content: Container(
                  width: 500,
                  height: 1000,

                  child: child
                ),
                actions: [
                  MaterialButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                    child: Text('OK', style: TextStyle(color: Colors.white),),
                  color: Colors.lightBlue.shade400),

                  MaterialButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  } ,
                  child: Text('Cancel', style: TextStyle(color: Colors.white),),
                  color: Colors.grey),

                ],)
          ),
          margin: EdgeInsets.only(bottom: 10, left: 12, right: 12),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(dialogBorderRadius),
          ),
        ),
      );
    },
    transitionBuilder: (context, anim1, anim2, child) {
      return SlideTransition(
        position: Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(anim1),
        child: child,
      );
    },
  );
}
Widget cityListView(BuildContext context, String label,void Function() onComplete){

    List<Widget> widgets = [];
    List<String> cityList =destinationCities;
    Map sorted = Map();
    if (label == 'Origin') {
      sorted = Map.fromEntries(gblAirportCache!.entries.toList()
        ..sort((e1, e2) => e1.value.compareTo(e2.value)));
    } else {
      destinationCities.forEach((element) {
        String key = element.split('|')[0];
        String value = element.split('|')[1].replaceAll('(' + key + ')', '');
        sorted[key] = value;
      });
    }

    //new List<Widget>();

    if( sorted != null ) {
      sorted.forEach((code, name) {
        if( code !='####' && code != 'TAX') {
          widgets.add(
              ListTile(
                  minVerticalPadding: 0,
                  minLeadingWidth: 0,
                  // dense: true,
                  visualDensity: VisualDensity(vertical: -3),
                  contentPadding: EdgeInsets.all(0),
                  title: TrText(name + ' (' + code + ')'),
                  onTap: () {
                    logit('on tap $code');
                    if (label == 'Origin') {
                      gblSearchParams.searchOrigin = code + '|' + name;
                    } else {
                      gblSearchParams.searchDestination = code + '|' + name;
                    }
                    onComplete();
                    Navigator.pop(context, code + '|' + name);
                    //_updateTitle(title);
                  })
          );
        }
      }
      );
    }
    return new CupertinoScrollbar(child:  ListView(
      padding: EdgeInsets.all(0),
      shrinkWrap: true,
      children: widgets,
    ));
  }
