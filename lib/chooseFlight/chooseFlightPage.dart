
import 'package:flutter/material.dart';
import 'package:vmba/data/models/availability.dart';
import 'package:intl/intl.dart';
import 'package:vmba/data/globals.dart';
import 'package:vmba/components/trText.dart';
import 'package:vmba/v3pages/v3Theme.dart';

import '../Helpers/settingsHelper.dart';
import '../calendar/widgets/langConstants.dart';
import '../components/vidButtons.dart';
import '../utilities/helper.dart';
import '../utilities/messagePages.dart';
import '../v3pages/cards/typogrify.dart';
import '../v3pages/controls/V3AppBar.dart';
import '../v3pages/controls/V3Constants.dart';

class ChooseFlight extends StatelessWidget {
  ChooseFlight(
      {Key key = const Key("chflt_key"), this.classband, this.flts, this.cabin, this.cb, this.seats, this.price = 0.0, this.currency})
      : super(key: key);
  final Band? classband;
  final List<Flt>? flts;
  final String? cabin;
  final String? currency;
  final int? cb;
  final double price;
  final seats;

  //ChooseFlight(Band classband);
  @override
  Widget build(BuildContext context) {
    gblCurPage = 'CHOOSEFLIGHT';
    return Scaffold(
        appBar: V3AppBar(
          PageEnum.chooseFare,
          //brightness: gblSystemColors.statusBar,
          centerTitle: true,
          // backgroundColor:          gblSystemColors.primaryHeaderColor,
          iconTheme: IconThemeData(
              color: gblSystemColors.headerTextColor),
          title: TrText("Choose Flight",
              style: TextStyle(
                  color:
                  gblSystemColors.headerTextColor)),
          automaticallyImplyLeading: false,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                    //endProgressMessage();
                    Navigator.pop(context);
                }
              ),

          ],
        ),
        body: classBands(context),
        floatingActionButton: vidWideActionButton(context,'CHOOSE FLIGHT', _onPressed, icon: Icons.check, offset: 35 ),
    );

  }
  void _onPressed(BuildContext context, dynamic p) {
    if( !gblActionBtnDisabled) {
      gblActionBtnDisabled = true;
      Navigator.of(context).pop(buildfltRequestMsg(
          flts as List<Flt>,
          classband?.cbname,
          classband?.cabin,
          int.parse(classband?.cb as String)));
    }
  }

  Widget classBands(context) {
    List <Widget> list = [];

 /*   if( wantPageV2()) {
      String _currencySymbol = '';
      if( gblSettings.wantCurrencySymbols == true ) {
        _currencySymbol = (simpleCurrencySymbols[currency] ?? currency as String);
      }

      list.add(new Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          TrText(
            //this.classband.cbdisplayname.toUpperCase()
              this.classband?.cbdisplayname == 'Fly Flex Plus'
                  ? 'Fly Flex +'
                  : (this.classband?.cbdisplayname as String),
              style: TextStyle(fontSize: 18,color: Colors.black,fontWeight: FontWeight.w700)),
          Padding(padding: EdgeInsets.all(5)),
          Text(_currencySymbol + price.toStringAsFixed(2),
              style: TextStyle(fontSize: 18,color: Colors.black,fontWeight: FontWeight.w700)
          ),

        ],
      ),);
      list.add(new Row(children: [Padding(padding: EdgeInsets.all(5))]));
    } else {*/
      list.add(inPageTitleText(this.classband?.cbdisplayname == 'Fly Flex Plus'
          ? 'Fly Flex +'
          : this.classband?.cbdisplayname as String));

/*
      list.add(new Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          TrText(
            //this.classband.cbdisplayname.toUpperCase()
              (this.classband?.cbdisplayname == 'Fly Flex Plus'
                  ? 'Fly Flex +'
                  : this.classband?.cbdisplayname as String),
              style: TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                  fontWeight: FontWeight.w700))
        ],
      ),);
   // }
    list.add(V3Divider());
*/

    if( gblSettings.wantClassBandImages) {
      //list.add( Image( image: NetworkImage('${gblSettings.gblServerFiles}/pageImages/${this.classband?.cbdisplayname}.png')));
      list.add(Image.network(
          '${gblSettings.gblServerFiles}/pageImages/${this.classband?.cbdisplayname}.png',
          errorBuilder: (BuildContext context,Object obj,  StackTrace? stackTrace) {
            return Text('', style: TextStyle(color: Colors.red),); // Image Error.
          })
      );
    }

    list.add( new Padding(padding: EdgeInsets.only(bottom: 15.0),    ));
    list.add(classbandText(classband!));

    if( wantPageV2()){
      return Container(

        decoration: BoxDecoration(
            border: Border.all(color: v2BorderColor(), width: v2BorderWidth()),
            borderRadius: BorderRadius.all(
                Radius.circular(15.0)),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 3,
                blurRadius: 3,
                offset: Offset(0, 4), // changes position of shadow
              ),]

        ),

        margin: EdgeInsets.only(top: 10, bottom: 10.0, left: 10, right: 10),
        padding: EdgeInsets.only(
            left: 5, right: 5, bottom: 8.0, top: 8.0),
        child: Column(
            children: [ Flexible(child: ListView(
              padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 55),
              children: list,)
            )]
        ),
      );
    }
    // Pass the text down to another widget
    return ListView(
        padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 55),
        children: list,);
    //  padding: EdgeInsets.all(10.0),
  }

  List<String> buildfltRequestMsg(
      List<Flt> flts, String? classBandName, String? cabin, int cb ) {
    List<String> msg = []; // List<String>();

//0LM0571Q18DEC18NWIMANQQ1/06550800(CAB=Y)[CB=FLY]^
//0LM0592L18DEC18MANINVQQ1/08401005(CAB=Y)[CB=FLY]^
//0LM0591L23DEC18INVMANQQ1/14301545(CAB=Y)[CB=FLY]^
//0LM0578L23DEC18MANNWIQQ1/18552000(CAB=Y)[CB=FLY]^
//0LM0032 14Dec12ABZKOINN1/08550950(CAB=Y)[CB=Fly]]
    for (var f in flts) {
      String _date =
          DateFormat('ddMMMyy').format(DateTime.parse(f.time.ddaylcl));
//      DateFormat('ddMMMyy').format(DateTime.parse(f.time.ddaygmt));
      String _dTime = f.time.dtimlcl.substring(0, 5).replaceAll(':', '');
      String _aTime = f.time.atimlcl.substring(0, 5).replaceAll(':', '');

      if( f.fltav.id![cb - 1] == ''){
        logit('not class ID');
      }

      msg.add(
          '0${f.fltdet.airid + f.fltdet.fltno + f.fltav.id![cb - 1] + _date + f.dep + f.arr}NN${seats.toString()}/${_dTime + _aTime}(CAB=$cabin)[CB=$classBandName]');
    }
    return msg;
  }
}
  Widget classbandText(Band classband) {
    if (classband?.cbtextrecords != null) {
      Cbtextrecords cbt = classband?.cbtextrecords as Cbtextrecords;

      return Column(
        mainAxisSize: MainAxisSize.min,
          children: cbt.cbtext
              .map((item) => Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          new Column(
                            //crossAxisAlignment: CrossAxisAlignment.start,
                            children: (item.icon == '') ? <Widget>[Container()] : <Widget>[iconWidget(item.icon )],
                          ),
                          new Padding(
                            padding: (item.icon == '') ? EdgeInsets.only(left: 1) : EdgeInsets.only(left: 15),
                          ),
                          new Flexible(
                            child: TrText(cleanText(item.text),
                                style: item.text.toLowerCase().contains('<b>') ? TextStyle(fontWeight: FontWeight.bold) : null,),
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

  String cleanText(String txtIn) {
    String str = txtIn.replaceAll(
    "&lt;img src=\"https://customertest.videcom.com/airswift/airswiftgraphics/citi-logo.jpg\" alt=\"citilogo\" height=\"18\" width=\"28\"&gt;",
    "")
        .replaceAll(
    "&lt;img src=\"https://booking.air-swift.com/airswiftgraphics/citi-logo.jpg\" alt=\"citilogo\" height=\"18\" width=\"28\"&gt;",
    "");

  // strip HTML
    str = str.replaceAll('&lt;', '<');
    str = str.replaceAll('&gt;', '>');
    str = str.replaceAll('<b>', '');
    str = str.replaceAll('<B>', '');
    str = str.replaceAll('</b>', '');
    str = str.replaceAll('</B>', '');
    str = str.replaceAll('<ul>', '');
    str = str.replaceAll('<UL>', '');
    str = str.replaceAll('</ul>', '');
    str = str.replaceAll('</UL>', '');
    str = str.replaceAll('<li>', '');
    str = str.replaceAll('<LI>', '');
    str = str.replaceAll('</li>', ''); //'''\n');
    str = str.replaceAll('</LI>', '');


    str = str.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), ' ');


return str;

  }

  Icon iconWidget(String? icon) {
    Color iconClr = Colors.green;
    if( gblSystemColors.classBandIconColor != null) {
      iconClr = gblSystemColors.classBandIconColor as Color;
    }
    if( icon == null ) icon = 'default';
    IconData iconData = Icons.check_circle;

    switch (icon) {
      case 'fa-adjust':
        iconData = Icons.adjust;
        break;
      case 'fa-money':
        iconData = Icons.money;
        break;
      case 'fa-binoculars':
        iconData = Icons.maps_ugc_rounded;
        break;
      case 'fa-camera-retro':
        iconData = Icons.camera_alt;
        break;
      case 'fa-certificate':
        iconData = Icons.document_scanner_outlined;
        break;
      case 'fa-diamond':
        iconData = Icons.diamond_outlined;
        break;
      case 'fa-fighter-jet':
        iconData = Icons.airplanemode_active;
        break;
      case 'fa-file':
        iconData = Icons.file_copy_outlined;
        break;
      case 'fa-fort-awesome':
        iconData = Icons.font_download;
        break;
      case 'fa-forward':
        iconData = Icons.forward;
        break;
      case 'fa-phone':
        iconData = Icons.phone_android;
        break;
      case 'fa-photo':
        iconData = Icons.photo;
        break;
      case 'fa-star':
        iconData = Icons.star;
        break;

      case 'fa-asterisk':
        iconData = Icons.star;
        break;
      case 'fa-ban':
        iconData = Icons.comment_bank;
        break;
      case 'fa-book':
        iconData = Icons.book;
        break;
      case 'fa-check-circle':
        iconData = Icons.check_circle_outline;
        break;
      case 'fa-flag':
        iconData = Icons.flag;
        break;
      case 'fa-flag-o':
        iconData = Icons.flag_outlined;
        break;
      case 'fa-flash':
        iconData = Icons.flash_on;
        break;
      case 'fa-gears':
        iconData = Icons.circle_outlined;
        break;

      case 'fa-backward':
        iconData = Icons.fast_rewind;
        break;
      case 'fa-clock-o':
        iconData = Icons.lock_clock;
        break;
      case 'fa-desktop':
        iconData = Icons.desktop_mac;
        break;
      case 'fa-leaf':
        iconData = Icons.energy_savings_leaf_outlined;
        break;
      case 'fa-shield':
        iconData = Icons.shield_outlined;
        break;
      case 'fa-skyatlas':
        iconData = Icons.cloud_done_outlined;
        break;

      case 'fa-anchor':
        iconData = Icons.anchor;
        break;
      case 'fa-coffee':
        iconData = Icons.coffee;
        break;
      case 'fa-exchange':
        iconData = Icons.swap_horiz;
        break;
      case 'fa-fast-forward':
        iconData = Icons.fast_forward;
        break;
      case 'fa-ticket':
        iconData = Icons.airplane_ticket_outlined;
        break;

      case 'fa-briefcase':
        iconData = Icons.card_travel;
        break;
      case 'fa-check':
        iconData = Icons.check;
        break;
      case 'fa-check-square':
        iconData = Icons.check_box;
        break;
      case 'fa-exchange':
        iconData = Icons.swap_horiz_outlined;
        break;
      case 'fa-exclamation':
        iconData = Icons.info_outline;
        break;
      case 'fa-hourglass':
        iconData = Icons.hourglass_full;
        break;
      case 'fa-hourglass-start':
        iconData = Icons.hourglass_bottom;
        break;
      case 'fa-paper-plane':
        iconData = Icons.airplane_ticket_outlined;
        break;
      case 'fa-plane':
        iconData = Icons.airplanemode_active;
        break;
      case 'fa-plus-square':
        iconData = Icons.add_box_outlined;
        break;
      case 'fa-suitcase':
        iconData = Icons.shopping_bag;
        break;
      case 'fa-thumbs-up':
      case 'fa-thumbs-o-up':
        iconData = Icons.thumb_up_alt_outlined;
        break;

      default:
        iconData = Icons.check_circle;
        break;
    }
    return Icon(iconData, color: iconClr,);
  }

