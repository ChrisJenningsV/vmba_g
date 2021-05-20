import 'package:flutter/material.dart';
import 'package:vmba/data/models/availability.dart';
import 'package:intl/intl.dart';
import 'package:vmba/data/globals.dart';
import 'package:vmba/components/trText.dart';

class ChooseFlight extends StatelessWidget {
  ChooseFlight(
      {Key key, this.classband, this.flts, this.cabin, this.cb, this.seats})
      : super(key: key);
  final Band classband;
  final List<Flt> flts;
  final String cabin;
  final int cb;
  final seats;

  //ChooseFlight(Band classband);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          brightness: gbl_SystemColors.statusBar,
          backgroundColor:
          gbl_SystemColors.primaryHeaderColor,
          iconTheme: IconThemeData(
              color: gbl_SystemColors.headerTextColor),
          title: TrText("Choose Flight",
              style: TextStyle(
                  color:
                  gbl_SystemColors.headerTextColor)),
          automaticallyImplyLeading: false,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            )
          ],
        ),
        body: classBands(context),
        floatingActionButton: Padding(
            padding: EdgeInsets.only(left: 35.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new FloatingActionButton.extended(
                    elevation: 0.0,
                    isExtended: true,
                    label: TrText('CHOOSE FLIGHT',
                        style: TextStyle(
                            color: gbl_SystemColors
                                .primaryButtonTextColor)),
                    icon: Icon(
                      Icons.check,
                      color: gbl_SystemColors
                          .primaryButtonTextColor,
                    ),
                    backgroundColor: gbl_SystemColors
                        .primaryButtonColor, //new Color(0xFF000000),
                    onPressed: () {
                      Navigator.of(context).pop(buildfltRequestMsg(
                          flts,
                          classband.cbname,
                          classband.cabin,
                          int.parse(classband.cb)));
                      //_handleBookSeats(paxlist);
                    }),
              ],
            )));
  }

  Widget classBands(context) {
    // Pass the text down to another widget
    return ListView(
        padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 55),
        children: [
          new Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TrText(
                  //this.classband.cbdisplayname.toUpperCase()
                  this.classband.cbdisplayname == 'Fly Flex Plus'
                      ? 'Fly Flex +'
                      : this.classband.cbdisplayname,
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.w700))
            ],
          ),
          new Padding(
            padding: EdgeInsets.only(bottom: 15.0),
          ),
          classbandText(),
          // Padding()
        ]);
    //  padding: EdgeInsets.all(10.0),
  }

  List<String> buildfltRequestMsg(
      List<Flt> flts, String classBandName, String cabin, int cb) {
    List<String> msg = []; // List<String>();

//0LM0571Q18DEC18NWIMANQQ1/06550800(CAB=Y)[CB=FLY]^
//0LM0592L18DEC18MANINVQQ1/08401005(CAB=Y)[CB=FLY]^
//0LM0591L23DEC18INVMANQQ1/14301545(CAB=Y)[CB=FLY]^
//0LM0578L23DEC18MANNWIQQ1/18552000(CAB=Y)[CB=FLY]^
//0LM0032 14Dec12ABZKOINN1/08550950(CAB=Y)[CB=Fly]]
    for (var f in flts) {
      String _date =
          DateFormat('ddMMMyy').format(DateTime.parse(f.time.ddaygmt));
      String _dTime = f.time.dtimlcl.substring(0, 5).replaceAll(':', '');
      String _aTime = f.time.atimlcl.substring(0, 5).replaceAll(':', '');
      msg.add(
          '0${f.fltdet.airid + f.fltdet.fltno + f.fltav.id[cb - 1] + _date + f.dep + f.arr}NN${seats.toString()}/${_dTime + _aTime}(CAB=$cabin)[CB=$classBandName]');
    }
    return msg;
  }

  Widget classbandText() {
    if (classband.cbtextrecords != null) {
      return Column(
          children: classband.cbtextrecords.cbtext
              .map((item) => Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          new Column(
                            //crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[iconWidget(item.id)],
                          ),
                          new Padding(
                            padding: EdgeInsets.only(left: 15),
                          ),
                          new Flexible(
                            child: TrText(item.text
                                .replaceAll(
                                    "&lt;img src=\"https://customertest.videcom.com/airswift/airswiftgraphics/citi-logo.jpg\" alt=\"citilogo\" height=\"18\" width=\"28\"&gt;",
                                    "")
                                .replaceAll(
                                    "&lt;img src=\"https://booking.air-swift.com/airswiftgraphics/citi-logo.jpg\" alt=\"citilogo\" height=\"18\" width=\"28\"&gt;",
                                    "")),
                          ),
                        ],
                      ),
                      new Padding(
                        padding: EdgeInsets.only(bottom: 15.0),
                      )
                    ],
                  ))
              .toList());
    } else {
      return Column();
    }
  }

  Icon iconWidget(String id) {
    switch (id) {
      case '90':
        return Icon(null);
        break;
      case '61':
        return Icon(null);
        break;
      case '94':
        return Icon(null);
        break;
      case '91':
        return Icon(null);
        break;
      default:
        return Icon(Icons.done);
        break;
    }
  }
}
