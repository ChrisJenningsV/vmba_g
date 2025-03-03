import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:vmba/v3pages/v3Theme.dart';

import '../Helpers/settingsHelper.dart';
import '../components/trText.dart';
import '../data/globals.dart';
import '../menu/menu.dart';


class FlyingPlanePage extends StatefulWidget {
  FlyingPlanePage({Key key = const Key("tab_key")})
      : super(key: key);

  @override
  FlyingPlanePageState createState() => new FlyingPlanePageState();
}

class FlyingPlanePageState extends State<FlyingPlanePage> {
  String origin = 'Abredeen';
  String destination = 'Kirkwall';
  int skyImage = 1;
  int planeImage = 1;
  String page = 'A';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    late Widget body;
    switch (page) {
      case 'A':
        body = getPageA();
        break;
      case 'B':
        body = getPageB();
        break;
      default:
        body = getPageC();
    }

    return Scaffold(
        endDrawer: DrawerMenu(),
        appBar: new AppBar(
          backgroundColor:gblSystemColors.primaryHeaderColor,
          actions: [
            getPageButton(() {
                  setState(() {
                    page = 'A';
                  });
                },text: 'A'
            ),
            getPageButton(() {
                  setState(() {
                    page = 'B';
                  });
                },text: 'B'
            ),
            getPageButton(() {
              setState(() {
                page = 'C';
              });
            },text: 'C'
            ),
          ],
          iconTheme: IconThemeData(
              color: gblSystemColors.headerTextColor),
          title: new TrText('Demo Page',
              style: TextStyle(
                  color:
                  gblSystemColors.headerTextColor)),
        ),
      body: body
    );
  }

  Widget getPageA() {
    return Stack(
        children: [
          LoopAnimationBuilder<double>(
            //tween: Tween(begin: 0.0, end: MediaQuery.of(context).size.width),
            tween: Tween(begin: MediaQuery.of(context).size.width, end: 0),
            duration: const Duration(seconds: 10),
            builder: (context, offset,child) {
              return Transform.translate(offset: Offset(offset, 0),
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          fit: BoxFit.cover,
                          image:  skyImage == 0 ?
                          NetworkImage('${gblSettings.gblServerFiles}/pageImages/skyx.png') :
                          AssetImage('lib/assets/images/sky${skyImage.toString()}.png')
                      ),
                    ),
                  )
              );
            },
          ),
          LoopAnimationBuilder<double>(
            //tween: Tween(begin: -MediaQuery.of(context).size.width, end: 0),
            tween: Tween(begin: 0, end:-MediaQuery.of(context).size.width),
            duration: const Duration(seconds: 10),
            builder: (context, offset,child) {
              return Transform.translate(offset: Offset(offset, 0),
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          fit: BoxFit.cover,
                          image:  skyImage == 0 ?
                          NetworkImage('${gblSettings.gblServerFiles}/pageImages/skyx.png') :
                          AssetImage('lib/assets/images/sky${skyImage.toString()}.png')
                      ),
                    ),
                  )
              );
            },
          ),
          MirrorAnimationBuilder<double>(
              tween: Tween(begin: 200.0, end: 230.0), // value for offset x-coordinate
              duration: const Duration(seconds: 2),
              curve: Curves.easeInOutSine, // non-linear animation
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(70, value), // use animated value for x-coordinate
                  child: child,
                );
              },
              child:Container(
                  height: 240.0,
                  width: 240.0,
                  decoration: BoxDecoration(
                    image: DecorationImage(image: AssetImage('lib/assets/images/plane${planeImage.toString()}.png')
                    ),
                  ))
          ),
          Positioned(
              top: MediaQuery.of(context).size.height - 40,
              left: 0,
              child: Container(
                height: 120.0,
                width: 120.0,
                child: Text(origin, textScaler: TextScaler.linear(1.4),style: TextStyle(fontWeight: FontWeight.bold),),
              )),
          Positioned(
              top: MediaQuery.of(context).size.height - 40,
              left: MediaQuery.of(context).size.width - 100,
              child: Container(
                height: 120.0,
                width: 120.0,
                child: Text(destination, textScaler: TextScaler.linear(1.4),style: TextStyle(fontWeight: FontWeight.bold),),
              )),

          getIconButton( MediaQuery.of(context).size.width/2 - 80, MediaQuery.of(context).size.height - 140,
                  () {
                setState(() {
                  skyImage += 1;
                  if( skyImage > 4) skyImage = 0;
                });
              },
              icon: Icons.cloud_done_outlined
          ),

          getIconButton( MediaQuery.of(context).size.width/2 + 10, MediaQuery.of(context).size.height - 140,
                () {
              setState(() {
                planeImage += 1;
                if (planeImage > 6) planeImage = 1;
              });
            },
            icon: Icons.airplanemode_active,
          ),
/*
          getIconButton( MediaQuery.of(context).size.width- 100, 20,
                  () {
                setState(() {
                  page = 'A';
                });
              },
              text: 'A'
          ),
          getIconButton( MediaQuery.of(context).size.width - 50, 20,
                  () {
                setState(() {
                  page = 'B';
                });
              },
              text: 'B'
          ),
*/
/*
          Positioned(
              top: MediaQuery.of(context).size.height - 40,
              left: MediaQuery.of(context).size.width/2 + 10,
              child: IconButton(onPressed: () {
                setState(() {
                  planeImage += 1;
                  if( planeImage > 6) planeImage = 1;
                });
              }, icon: Icon(Icons.airplanemode_active))),
*/
        ]
    );
  }
  Widget getPageB() {
    return
    Column(
      children: [
        Padding(padding: EdgeInsets.all(15)),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
            children: [
        ]),
    Padding(padding: EdgeInsets.all(20)),
      Column(children: [
        GestureDetector(
        onTap: () {},
        child: Container(
        width: 335,
       // height: 200,
        child: Card(
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: Column(
          children: [
            SizedBox(
            width: 335,
            height: 110,
            child: Image.network('${gblSettings.gblServerFiles}/pageImages/flightpath.png',
            fit: BoxFit.fill,
            ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                VHeadlineText('11:40',size: TextSize.small,),
                VHeadlineText('13:10',size: TextSize.small),
            ],),
            SizedBox(height: 16,),
            Column(children:[
/*
            Text('Title'),
            Text('Subtitle')
*/
          ])
      ],
      ),
      shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 5,
      margin: EdgeInsets.all(10),
      ),
      ),
      ),

        RoataingImage(wantButtons: true),
    ])
        ]
    );
  }

  Widget getPageC() {
    return
      Column(
          children: [
            /*Padding(padding: EdgeInsets.all(15)),
            Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [

                ]),
            Padding(padding: EdgeInsets.all(20)),
            Column(children: [*/
            /*  GestureDetector(
                onTap: () {},
                child: Container(
                  width: 335,
                  // height: 200,
                  child: Card(
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            VHeadlineText('11:40',size: TextSize.small,),
                            VHeadlineText('13:10',size: TextSize.small),
                          ],),
                        SizedBox(height: 16,),
                        Column(children:[
                          Text('Title'),
                          Text('Subtitle'),
                        ])
                      ],
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    elevation: 5,
                    margin: EdgeInsets.all(10),
                  ),
                ),
              ),
*/
              Text('plan'),
              testSeatPlan()
//           ])
          ]
      );
  }

  Widget testSeatPlan(){
    return Expanded(
        child: SingleChildScrollView(
        child: Stack(
        children:
          AddSeats(),
        )
    )
    );
  }
  double seatHeight = 40;
  double seatWidth = 40;
  double vertSpace = 5;
  double horzSpace = 5;
  double aSpace = 20;
  double seatsTop = 220;

  List<Widget> AddSeats(){

    List<Widget> list = [];

    // Existing Image Block
    list.add(Image.network('${gblSettings.gblServerFiles}/pageImages/floor2.png',
      fit: BoxFit.fill,
    ));

    for( var i = 1 ; i < 5; i++ ) {
      list.add(Positioned(
        left: 100,
        top: seatsTop + i * seatHeight + vertSpace,
        child: dummySeat('${i}A', Colors.teal),
      ));
      list.add(Positioned(
        left: 100 + seatWidth + horzSpace,
        top: seatsTop + i * seatHeight + vertSpace,
        child: dummySeat('${i}B', Colors.grey),
      ));
      list.add(Positioned(
        left: 100+ 2* (seatWidth + horzSpace) + aSpace,
        top: seatsTop + i * seatHeight + vertSpace,
        child: dummySeat('${i}C', Colors.red),
      ));

      list.add(Positioned(
        left: 100 + 3* (seatWidth + horzSpace) + aSpace,
        top: seatsTop + i * seatHeight + vertSpace,
        child: dummySeat('${i}D', Colors.grey),
      ));
    }

    return list;
  }


  Widget dummySeat( String id, Color clr){
    return Container(
      alignment: Alignment.center,
      width: seatWidth,
      height: seatHeight,
      decoration: BoxDecoration(
        border: Border.all(color: v2BorderColor(), width: v2BorderWidth()),
        borderRadius: BorderRadius.all(
            Radius.circular(3.0)),
        color: clr,
      ),
      child: Text(id),
    );
  }

  Widget getIconButton( double x, double y,  void Function() onClick,{ IconData? icon, String text = ''}){
    return Positioned(
        top: y,
        left: x,
        child: ElevatedButton(onPressed: () {
          onClick();
            },
            style: ElevatedButton.styleFrom(
                shape: CircleBorder(),
                backgroundColor: Colors.grey,
                padding: EdgeInsets.only(left: 0, right: 0)
            ),
            child: text == '' ? Icon(icon) : Text(text)));
  }
}
Widget getPageButton(void Function() onClick, { IconData? icon, String text = ''}){
  return Padding(padding: EdgeInsets.fromLTRB(10, 15, 0, 15),
  child:  ElevatedButton(onPressed: () {
    onClick();
    },
    style: ElevatedButton.styleFrom(
       minimumSize: Size(25.0,5),

    //shape: CircleBorder(),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0),
      ),
      backgroundColor: Colors.grey,
      padding: EdgeInsets.only(left: 0, right: 0)
      ),
      child: text == '' ? Icon(icon) : Text(text)
      )
    );
}


class RoataingImage extends StatefulWidget {
  String imageName = '';
  bool wantButtons = false;

  RoataingImage({this.imageName = '', this.wantButtons = false});

  @override
  _RoataingImageState createState() => _RoataingImageState();
}

class _RoataingImageState extends State<RoataingImage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 10000),
      vsync: this,
    );
    super.initState();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return //Center(        child:
      Container( height: 300, child:
       Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
        RotationTransition(
          turns: Tween(begin: 4.0, end: 0.0).animate(_controller),
          child:Container(
                  alignment: Alignment.bottomCenter,
                  height: 250,
                  width: 250,
                  color: Colors.transparent,
                child:
                smallPlane(5),
//                  Icon(Icons.stars, size: 40,),
    //            )
    )
            ),
/*
            widget.wantButtons ?
            ElevatedButton(
              child: Text("go"),
              onPressed: () {
                _controller.reset();
                _controller.forward();
              },
            ) : Container(),
*/
          ],
        ),
    );
  }

}
Widget smallPlane( int imgNo){
  String assetImg = 'lib/assets/images/plane${imgNo.toString()}.png';
  if(gblSettings.customProgressImage != '' ){
    assetImg = gblSettings.customProgressImage;
  }

  return Container(
    height: 100,
    width: 100,
    decoration: BoxDecoration(
      image: DecorationImage(
          fit: BoxFit.fitWidth,
          image:  imgNo == 0 ?
          NetworkImage('${gblSettings.gblServerFiles}/pageImages/planex.png') :
          AssetImage(assetImg)
      ),
    ),
  );
}