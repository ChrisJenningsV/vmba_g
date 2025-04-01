
import 'package:flutter/material.dart';
import '../data/globals.dart';
import '../data/models/seatplan.dart';
import '../utilities/helper.dart';
import 'plan.dart';

// seat layouts / seat plans found at https://www.aerolopa.com/lm-e45


double seatHeight = 40;
double seatWidth = 40;
double vertSpace = 5;
double horzSpace = 5;
double aSpace = 10;
double seatsTop = 40;
double seatsLeft = 80;
double pricingHeight = 30;
double pricingOffset = 0;
double cabinWidth = 200;

String currentSeatPrice = '';
String currentSeatPriceLabel = '';
String currencyCode = '';
String previousSeatPrice = '';
bool layoutMode = false;

List<Widget> AddSeats(BuildContext context, Widget Function(Seat? , bool, bool,SeatSize) hookUpSeat ){

  logit( 'AddSeats w: ${MediaQuery.of(context).size.width}');
  int rows = gblSeatplan!.seats.seat.last.sRow;
  int minCol = gblSeatplan!.getMinCol();
  int maxCol = gblSeatplan!.getMaxCol();
  currentSeatPrice = '';
  currentSeatPriceLabel = '';
  currencyCode = '';
  previousSeatPrice = '';
  pricingOffset = 0;

  List<Widget> list = [];
  List<Seat> seats = [];


  if( gblSettings.wantSeatPlanImages && gblSeatPlanConfig != null  ) {
    // we have json definition file for this aircraft
    seatsTop = gblSeatPlanConfig!.top;
    seatsLeft = gblSeatPlanConfig!.left;
    seatHeight = gblSeatPlanConfig!.seatHeight;
    seatWidth = gblSeatPlanConfig!.seatWidth;

    gblSeatPlanDef!.seatWidth = seatWidth;
    gblSeatPlanDef!.seatHeight = seatHeight;

    horzSpace = gblSeatPlanConfig!.seatHorzSpace;
    vertSpace = gblSeatPlanConfig!.seatVertSpace;
    cabinWidth = gblSeatPlanConfig!.cabinWidth;

    logit('set custom seat plan config [$seatsTop]' );
  } else {
    // need to calc layout
    gblSeatPlanDef = gblSeatplan!.getPlanDataTable();
    int seatsPlusSpace = gblSeatPlanDef!.maxSeatsPerRow ;
    double width = MediaQuery.sizeOf(context).width;
    seatsTop = 30;
    seatHeight = 60;
    seatWidth = 50;

    if( seatsPlusSpace < 6) {
      // narrow body
      //  space as
      //  x |side| space seat(x) space seat(x) Aisel seat(x) space seat(x) space |side| x
      // calc seat width
      double swidth = (width - horzSpace * (gblSeatPlanDef!.maxSeatsPerRow +1)) /
          (gblSeatPlanDef!.maxSeatsPerRow + 3);
      seatWidth = swidth;
      seatsLeft = swidth;
      cabinWidth = (gblSeatPlanDef!.maxSeatsPerRow + 1) * swidth +
            gblSeatPlanDef!.maxSeatsPerRow * horzSpace;

      seatsLeft = (width - cabinWidth) /2;

    } else {
    }
    gblSeatPlanDef!.seatWidth = seatWidth;
    gblSeatPlanDef!.seatHeight = seatHeight;
  }

  // Existing Image Block
  if(gblSettings.wantSeatPlanImages) {
    Image? floorImg = getNetFloorPlan(
        '${gblSettings.gblServerFiles}/SeatPlans/${gblSeatplan!.seats.seatsFlt
            .sRef}.png');
    if (netImgLoaded == false) {
      // get default image
      floorImg = Image.asset('lib/assets/images/floor2.png');
    }
    list.add(floorImg);

    if (layoutMode) {
      floorImg.image.resolve(ImageConfiguration()).addListener(
        ImageStreamListener(
              (ImageInfo image, bool synchronousCall) {
            var myImage = image.image;
            Size size = Size(
                myImage.width.toDouble(), myImage.height.toDouble());
            logit('img: w: ${size.width} h: ${size.height}');
            //completer.complete(size);
          },
        ),
      );
      // add grid
      list.add(CustomPaint(
        painter: GridPainter(MediaQuery.sizeOf(context)),
      ));
    }
  } else {
    // dummy floor
    Image floorImg = Image.asset('lib/assets/images/dummyfloor.png');
    list.add(floorImg);
  }
  // dump
  if( gblSeatPlanDef != null ){
    gblSeatPlanDef!.dump(true);
    rows = gblSeatPlanDef!.maxRow;
  }

  logit('last row $rows min col $minCol');

  for (var indexRow = gblSeatPlanDef!.minRow; indexRow <= rows; indexRow++) {
    if( layoutMode) {
      list.add(Positioned(
          left: 10,
          //seatsLeft + (indexColumn-minCol) * (seatWidth + horzSpace) + aSpace,
          top: getTopOffset(indexRow),
          // seatsTop + (indexRow-3) * (seatHeight + vertSpace),
          child: Text('R $indexRow')
      ));
    }
      seats = gblSeatplan!.getSeatsForRow(indexRow);
      // logit('ROW: $indexRow');
      for (var indexColumn = minCol; indexColumn <= maxCol; indexColumn++) {
        Seat? seat;
        seats.forEach((element) {
          if (element.sCol == indexColumn) {
            seat = element;
          }
        });

        // get price for row
        currentSeatPrice = '0';
        bool rowHasSeats = false;
        seats.forEach((element) {
            if (double.parse(element.sScprice) >
                double.parse(currentSeatPrice)) {
              currentSeatPrice = element.sScprice;
              currentSeatPriceLabel = element.sScinfo;
              currencyCode = element.sCur;

              rowHasSeats = true;
            }
        });

        if (rowHasSeats &&  currentSeatPrice != '' && currentSeatPrice != "0") {
          //add row price
          if (previousSeatPrice != currentSeatPrice) {
            getPricing(list, indexRow);
          }
          previousSeatPrice = currentSeatPrice;
        }

        if (seat != null && (seat!.isSeat())) {
          //logit('s ${seat!.sCode} t:${seatsTop + (indexRow-3) * seatHeight + vertSpace}');
          bool selected = false;
          bool selectableSeat = true;
          if (gblSelectedSeats.contains(seat!.sCode)) {
            selectableSeat = false;
          }
          if (seat != null && seat!.sCode != '' &&
              gblSelectedSeats.contains(seat!.sCode)) {
            selected = true;
          }

          double x = getLeftOffset(indexColumn);
          double y = getTopOffset(indexRow);
          //logit('seat ${seat!.sCode} R:$indexRow C:$indexColumn  x:$x y:$y');

          if( seat!.sCode == '3A') {
            logit('3A');
          }

          list.add(Positioned(
              left: x, //seatsLeft + (indexColumn-minCol) * (seatWidth + horzSpace) + aSpace,
              top: y, // seatsTop + (indexRow-3) * (seatHeight + vertSpace),
              child: hookUpSeat( seat, selected, selectableSeat, SeatSize.medium)
          ));
        }
      }
    }
  return list;
}

double getLeftOffset(int indexColumn, { bool inclueOffset = true}) {
  return seatsLeft + (indexColumn-gblSeatplan!.getMinCol()) * (seatWidth + horzSpace) + (inclueOffset ? aSpace : 0);
}
double getTopOffset(int indexRow) {
  return seatsTop + (indexRow-gblSeatPlanDef!.minRow) * (seatHeight + vertSpace) + pricingOffset;
}

getPricing(List <Widget> list, int indexRow ){
double y= getTopOffset(indexRow);
//logit( ' pricing w: $cabinWidth o: $pricingOffset y: $y');

      double x = getLeftOffset(gblSeatplan!.getMinCol(), inclueOffset: false) +15;
      list.add(Positioned(
      left: x,
      top: y, // seatsTop + (indexRow-3) * (seatHeight + vertSpace),
      width: cabinWidth,
      child: SeatPricing(currentSeatPriceLabel, currentSeatPrice)));

    pricingOffset += pricingHeight;


  /*
      Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(child: Container(
                color: gblSettings.seatPlanStyle.contains('I')
                    ? gblSystemColors.seatPlanBackColor
                    : null,
                child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Padding(padding: EdgeInsets.all(5)),
                      Container(
                        margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
                        padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                        decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(width: 2.0,
                                  color: gblSystemColors
                                      .seatPriceColor as Color),
                              left: BorderSide(width: 2.0,
                                  color: gblSystemColors
                                      .seatPriceColor as Color),
                              right: BorderSide(width: 2.0,
                                  color: gblSystemColors
                                      .seatPriceColor as Color),
                            )),
                        child: Center(
                          child: Text(
                            formatPrice(currencyCode,
                                double.parse(currentSeatPrice)) +
                                '\n ' + currentSeatPriceLabel,
                            style: TextStyle(color: gblSystemColors
                                .seatPriceColor as Color),
                          ),
                          //' Seat Charge'),
                        ),
                      ),
                    ]))),
          ]
      )
  );*/
}

bool netImgLoaded = true;
Image getNetFloorPlan(String file ){
  netImgLoaded = true;
  return Image.network('${gblSettings.gblServerFiles}/SeatPlans/${gblSeatplan!.seats.seatsFlt.sRef}.png',
    errorBuilder: (BuildContext context, Object obj,
        StackTrace? stackTrace) {
      logit('Cannot load image ${gblSeatplan!.seats.seatsFlt.sRef}.png');
      netImgLoaded = false;
      return  Image.asset('lib/assets/images/floor2.png');
      //return Text(msg, style: TextStyle(color: Colors.red));
    },// floor2.png',
    fit: BoxFit.fill,
  );

}
class GridPainter extends CustomPainter {

  final Size cansize;
  GridPainter(this.cansize);

  @override
  void paint(Canvas canvas, Size size) {

    final paint1 = Paint()
      ..color = Colors.blue
      ..strokeJoin
      ..strokeWidth = 1;
    final paint2 = Paint()
      ..color = Colors.blue
      ..strokeJoin
      ..strokeWidth = 1;

    for( double y = 50; y < cansize.height ; y+= 50) {
      Offset p1 = Offset(0, y);
      Offset p2 = Offset(cansize.width, y);
      //logit( 'line w: $cabinWidth o: $pricingOffset');
      canvas.drawLine(p1, p2, paint1);
      drawMsg(canvas, y.round().toString(), cansize.width - 50, y-10);
    }

    for( double x = 50; x < cansize.height ; x+= 50) {
      Offset p1 = Offset(x, 0);
      Offset p2 = Offset(x, cansize.height);
      //logit( 'line w: $cabinWidth o: $pricingOffset');
      canvas.drawLine(p1, p2, paint2);
      drawMsg(canvas, x.round().toString(), x, 10);
    }


//    const p2 = Offset(165, 135);
/*
    const p3 = Offset(165, 135);
    const p4 = Offset(490, 135);
    canvas.drawLine(p1, p2, paint1);
    canvas.drawLine(p3, p4, paint2);
    canvas.drawLine(p5, p6, paint3);
*/
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
  void drawMsg(Canvas canvas, String msg, double x, double y) {
    final textPainter = TextPainter(
        text: TextSpan(
          text: msg,
          style: TextStyle(
            color: Colors.blue,
            fontSize: 16,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center
    );
    textPainter.layout();

    textPainter.paint(canvas, Offset(x, y));
  }
}

class SeatPricing extends StatefulWidget {
  String msg ='';
  String price ='';

  SeatPricing(this.msg, this.price);

  @override  SeatPricingState createState() => SeatPricingState();

}
class SeatPricingState extends State<SeatPricing> {

  @override
  initState() {
    super.initState();
    commonPageInit('OPTIONS');
  }

  @override
  Widget build(BuildContext context) {
    Color fillColor = Colors.white;
    Color textColor = gblSystemColors.seatPriceColor as Color;

    if(gblSettings.seatPriceStyle.contains('fill')) {
      fillColor = gblSystemColors.seatPriceColor as Color;
      textColor = Colors.white;
    }


    Widget priceBox = Stack(
    children: [
      Container(
        margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
        padding: EdgeInsets.fromLTRB(2, 0, 2, 0),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(width: 3.0, color: gblSystemColors.seatPriceColor as Color),
            left: BorderSide(width: 3.0, color: gblSystemColors.seatPriceColor as Color),
            right: BorderSide(width: 3.0, color: gblSystemColors.seatPriceColor as Color),
          ),
          color: Colors.transparent,
        ),
        width: cabinWidth, // 200
        height: pricingHeight,

        ),
        Container(
          width: MediaQuery.sizeOf(context).width,
          //color: Colors.red,
          height: pricingHeight,
          child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children:[ Container(
            padding: EdgeInsets.fromLTRB(5, 2, 5, 2),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(width: 3.0, color: Colors.lightBlue.shade600),
              borderRadius: BorderRadius.all(gblSettings.seatPriceStyle.contains('round')? Radius.circular(pricingHeight/2) :Radius.circular(5.0)),
              color: fillColor,
            ),
            child:   Text(
            widget.msg + ' ' +
                formatPrice(currencyCode, double.parse(widget.price)),
            style: TextStyle(color: textColor), // TextStyle(color: gblSystemColors.seatPriceColor as Color),
          ))]
        ),
        )
    ]
    );

      return priceBox;
  }
}