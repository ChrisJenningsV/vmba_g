import 'package:flutter/material.dart';
import 'package:vmba/data/globals.dart';


//
//  lineTo x,y
//  sets points on the path
//  top left is 0, 0
//


/*

class WingStartLeftPath extends CustomClipper<Path> {
  double width ;
  double height ;
  WingStartLeftPath({required this.width ,required  this.height});

  var radius=10.0;
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, height);
    path.lineTo(width,height/2);
    path.lineTo(width,height);
    path.lineTo(0, height);
    return path;
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
*/

/*class WingEndLeftPath extends CustomClipper<Path> {
  double width ;
  double height ;
  WingEndLeftPath({required this.width ,required  this.height});

  var radius=10.0;
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, height/2);
    path.lineTo(0,0);
    path.lineTo(width,0);
    path.lineTo(0, height/2);
    return path;
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}*/
/*

class WingStartRightPath extends CustomClipper<Path> {
  double width ;
  double height ;
  WingStartRightPath({required this.width ,required  this.height});

  var radius=10.0;
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, height/2);
    path.lineTo(width, height);
    path.lineTo(0, height);
    path.lineTo(0, height/2);
    return path;
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
*/

/*

class WingEndRightPath extends CustomClipper<Path> {
  double width ;
  double height ;
  WingEndRightPath({required this.width ,required  this.height});

  var radius=10.0;
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0,0);
    path.lineTo(width,0);
    path.lineTo(width, height/2);
    path.lineTo(0, 0);
    return path;
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

*/

class WingMiddlePath extends CustomClipper<Path> {
  double width ;
  double height ;
  WingMiddlePath({required this.width ,required  this.height});

  var radius=10.0;
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, 0);
    path.lineTo(0, height);
    path.lineTo(width, height);
    path.lineTo(width, 0);
    path.lineTo(0, 0);
    return path;
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}


class WingDoorPath extends CustomPainter {
  double width ;
  double height ;
  bool isLeftSide;
  WingDoorPath({required this.width ,required  this.height, required this.isLeftSide});

  @override
  void paint(Canvas canvas, Size size) {

    // fill
    canvas.drawRect(Rect.fromLTRB(isLeftSide ? 4 * width/5 + 2 : 2,
        0.0, isLeftSide ? width-2 : width/5-2 , height),
        new Paint()..color = gblSystemColors.seatPlanWallColor as Color);

    // outline
    canvas.drawRect(
      new Rect.fromLTRB(isLeftSide ? 4*width/5 : 0,
          0.0, isLeftSide ?  width : width/5, height),
      new Paint()..color = gblSystemColors.seatPlanFuselageColor as Color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // triangle out
    Path path = Path();
    if( isLeftSide) {
      path.lineTo(7 * width / 8, height / 2);
      path.lineTo(width, 3 * height / 8);
      path.lineTo(width, 5 * height / 8);
      path.lineTo(7 * width / 8, height / 2);
    } else {
      path.lineTo( width / 8, height / 2);
      path.lineTo(0, 3 * height / 8);
      path.lineTo(0, 5 * height / 8);
      path.lineTo(width / 8, height / 2);

    }

    canvas.drawPath(path, new Paint()..color = Colors.red as Color);
  }

  @override
  bool shouldRepaint(WingDoorPath oldDelegate) {
    return false;
  }
}

class WingStartLeftPath extends CustomPainter {
  double width ;
  double height ;
  WingStartLeftPath({required this.width ,required  this.height});

  var radius=10.0;
  @override
  void paint(Canvas canvas, Size size) {

    // fill
    canvas.drawRect(Rect.fromLTRB( 4 * width/5 + 2 ,
        0.0, width-2 , height),
        new Paint()..color = gblSystemColors.seatPlanWallColor as Color);

    canvas.drawLine(Offset(width, 0),
      Offset(width,height),
      new Paint()..color = gblSystemColors.seatPlanFuselageColor as Color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawLine(Offset(4 * width/5, 0),
      Offset(4*width/5,height),
      new Paint()..color = gblSystemColors.seatPlanFuselageColor as Color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    Path path = Path();
    path.lineTo(0, height);
    path.lineTo(width,height/2);
    path.lineTo(width,height);
    path.lineTo(0, height);
    canvas.drawPath(path,
        new Paint()..color = gblSystemColors.seatPlanWingColor as Color
    );


  }
  @override
  bool shouldRepaint(WingStartLeftPath oldDelegate) {
    return false;
  }
}

class WingStartRightPath extends CustomPainter {
  double width ;
  double height ;
  WingStartRightPath({required this.width ,required  this.height});

  var radius=10.0;
  @override
  void paint(Canvas canvas, Size size) {

    // fill
    canvas.drawRect(Rect.fromLTRB( 2,
        0.0, width/5-2 , height),
        new Paint()..color = gblSystemColors.seatPlanWallColor as Color);

      canvas.drawLine(Offset(0, 0),
      Offset(0,height),
      new Paint()..color = gblSystemColors.seatPlanFuselageColor as Color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawLine(Offset(width/5, 0),
      Offset(width/5,height),
      new Paint()..color = gblSystemColors.seatPlanFuselageColor as Color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    Path path = Path();
    path.lineTo(0, height/2);
    path.lineTo(width, height);
    path.lineTo(0, height);
    path.lineTo(0, height/2);
    canvas.drawPath(path,
        new Paint()..color = gblSystemColors.seatPlanWingColor as Color
    );



  }
  @override
  bool shouldRepaint(WingStartRightPath oldDelegate) {
    return false;
  }
}
class WingEndLeftPath extends CustomPainter {
  double width ;
  double height ;
  WingEndLeftPath({required this.width ,required  this.height});

  var radius=10.0;
  @override
  void paint(Canvas canvas, Size size) {
    // fill
    canvas.drawRect(Rect.fromLTRB(4 * width/5 + 2 ,
        0.0, width-2  , height),
        new Paint()..color = gblSystemColors.seatPlanWallColor as Color);

    canvas.drawLine(Offset(width, 0),
      Offset(width,height),
      new Paint()..color = gblSystemColors.seatPlanFuselageColor as Color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawLine(Offset(4 * width/5, 0),
      Offset(4*width/5,height),
      new Paint()..color = gblSystemColors.seatPlanFuselageColor as Color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    Path path = Path();
    path.lineTo(0, height/2);
    path.lineTo(0,0);
    path.lineTo(width,0);
    path.lineTo(0, height/2);
    canvas.drawPath(path,
        new Paint()..color = gblSystemColors.seatPlanWingColor as Color
    );

  }
  @override
  bool shouldRepaint(WingEndLeftPath oldDelegate) {
    return false;
  }
}

class WingEndRightPath extends CustomPainter {
  double width ;
  double height ;
  WingEndRightPath({required this.width ,required  this.height});

  var radius=10.0;
  @override
  void paint(Canvas canvas, Size size) {

    // fill
    canvas.drawRect(Rect.fromLTRB( 2,
        0.0, width/5-2 , height),
        new Paint()..color = gblSystemColors.seatPlanWallColor as Color);


    canvas.drawLine(Offset(0, 0),
      Offset(0,height),
      new Paint()..color = gblSystemColors.seatPlanFuselageColor as Color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawLine(Offset( width/5, 0),
      Offset(width/5,height),
      new Paint()..color = gblSystemColors.seatPlanFuselageColor as Color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    Path path = Path();
    path.lineTo(0,0);
    path.lineTo(width,0);
    path.lineTo(width, height/2);
    path.lineTo(0, 0);
    canvas.drawPath(path,
        new Paint()..color = gblSystemColors.seatPlanWingColor as Color
    );
  }
  @override
  bool shouldRepaint(WingEndRightPath oldDelegate) {
    return false;
  }
}

class FuselagePath extends CustomPainter {
  double width ;
  double height ;
  bool isLeft;
  FuselagePath({required this.width ,required  this.height, required this.isLeft});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawLine(Offset(isLeft ? width : 0, 0),
        Offset(isLeft ? width : 0,height),
      new Paint()..color = gblSystemColors.seatPlanFuselageColor as Color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // fill
    canvas.drawRect(Rect.fromLTRB(isLeft ? 4 * width/5 + 2 : 2,
        0.0, isLeft ? width-2 : width/5-2 , height),
        new Paint()..color = gblSystemColors.seatPlanWallColor as Color);

    canvas.drawLine(Offset(isLeft ? 4 * width/5 : width/5, 0),
      Offset(isLeft ? 4 * width/5 : width/5,height),
      new Paint()..color = gblSystemColors.seatPlanFuselageColor as Color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(FuselagePath oldDelegate) {
    return false;
  }
}

Widget getWingPath(BuildContext context, String part, double width, double height, bool isLeftSide ){

  CustomClipper<Path>? clipper;
  CustomPainter? painter;
  bool isPath = true;

  // temp
  gblSystemColors.seatPlanWallColor = Colors.lightBlueAccent;

  if( part == 's') {
    isPath = false;
    painter = WingStartLeftPath(width: width , height: height);

    if( isLeftSide == false ){
      painter = WingStartRightPath(width: width , height: height);
    }
  } else if( part == 'm') {
    clipper = WingMiddlePath(width: width , height: height);
  } else if( part == 'd') {
    isPath = false;
    painter = WingDoorPath(width: width , height: height, isLeftSide: isLeftSide);
  } else if( part == 'f') {
    isPath = false;
    painter = FuselagePath(width: width , height: height, isLeft: isLeftSide);
  } else if( part == 'e'){
    if( isLeftSide ) {
      isPath = false;
      painter = WingEndLeftPath(width: width , height: height);
    } else {
      isPath = false;
      painter = WingEndRightPath(width: width , height: height);
    }
  }

  if( isPath) {
    return Container(
        padding: EdgeInsets.all(0),
        margin: EdgeInsets.all(0),
        height: height,
        width: width,
        child: Stack(
            children: [
              Container(
                  color: gblSystemColors.seatPlanBackColor
              ),
              ClipPath(
                child: Container(
                  width: MediaQuery
                      .of(context)
                      .size
                      .width,
                  color: gblSystemColors.seatPlanWingColor,
                ),
                clipper: clipper,
              )
            ]
        )
    );
  } else {
    return Container(
        padding: EdgeInsets.all(0),
        margin: EdgeInsets.all(0),
        height: height,
        width: width,
        child: CustomPaint(
          painter: ( painter),
        ),
    );

  }
}
