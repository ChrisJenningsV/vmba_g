import 'package:flutter/material.dart';
import 'package:vmba/components/trText.dart';

class TabPage extends StatefulWidget {
  TabPage({Key key})
      : super(key: key);

  @override
  TabPageState createState() => new TabPageState();
}

class TabPageState extends State<TabPage>  with TickerProviderStateMixin {


  TabController _controller;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
           TabBar(
            indicatorColor: Colors.amberAccent,
            isScrollable: true,
            tabs: [
              Tab(icon: Icon(Icons.flight), text: 'class one',),
              Tab(icon: Icon(Icons.directions_transit), text: 'Eco',),
              Tab(icon: Icon(Icons.streetview), text: 'Super Green',),
              Tab(icon: Icon(Icons.directions_car), text: 'Plush',),
              Tab(icon: Icon(Icons.directions_car), text: 'Business',),
            ],
          ),
          ]),
          //title: Text('Tabs Demo'),
        ),
        body: TabBarView(
          children: [
            _getClassBand(context, 'Class one', '1'),
            _getClassBand(context, 'Eco', '2'),
            _getClassBand(context, 'Super green', '3'),
            _getClassBand(context, 'Plush', '4'),
            _getClassBand(context, 'Business', '5'),
          ],
        ),
      ),
    );
  }

  Widget _getClassBand(BuildContext context, String title,  String lineNo ) {
    return ListView(
        padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 55),
        children: [
          new Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TrText(
                  title,
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.w700))
            ],
          ),
          new Padding(
            padding: EdgeInsets.only(bottom: 15.0),
          ),
          classbandText(lineNo),
          // Padding()
        ]);

  }

  Widget classbandText(String addText) {
    return Column(
        children: [
          Row(children: [
            Icon(Icons.airline_seat_individual_suite),
            TrText(addText = ' Large Bed')
          ],),
          Row(children: [
            Icon(Icons.shopping_bag_outlined),
            TrText(addText = ' Bag')
          ],),
          Row(children: [
            Icon(Icons.set_meal),
            TrText(addText = ' Meal')
          ],),
          Row(children: [
            Icon(Icons.flight),
            TrText(addText = ' class')
          ],),
        ]

    );
  }
}