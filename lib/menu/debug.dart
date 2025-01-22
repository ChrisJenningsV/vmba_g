import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vmba/components/showDialog.dart';

import '../data/globals.dart';
import '../v3pages/cards/v3CustomPage.dart';
import '../v3pages/homePageHelper.dart';
import '../v3pages/v3BottomNav.dart';
import 'menu.dart';

const rowDivider = SizedBox(width: 20);
const colDivider = SizedBox(height: 10);
const tinySpacing = 3.0;
const smallSpacing = 10.0;
const double cardWidth = 115;
const double widthConstraint = 450;

class DebugPage extends StatefulWidget {
  DebugPage({this.name='', this.mainBackGroundImage });

  final String name;
  AssetImage?  mainBackGroundImage;

  @override
  DebugPageState createState()  => new DebugPageState();


}

class DebugPageState extends State<DebugPage> {
  int _selectedPageIndex = 1;
  String curPage = 'DEFAULT';
  bool isFiltered = true;
  final bool isDisabled = false;
  final bool useMaterial3 = true;
  bool showMediumSizeLayout = false;
  bool showLargeSizeLayout = false;
  int navDrawerIndex = 0;
  CustomPage? homePage;




  List<VNavButton> pageNav = [
    // label, icon, action
    VNavButton('Db Home', 'Home', 'LoadDbHome'),
    VNavButton('Buttons', 'Buttons', 'ButtonPage'),
    VNavButton('Menus', 'Menus', 'MenuPage'),
    VNavButton('More', 'More', 'MoreMenu'),
  ];



  @override void initState() {
    // TODO: implement initState
    initData();
    super.initState();
  }
  void doCallback() {
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {


    Widget body = Text('Loading...');
    if( homePage != null ){
      body = getCustomPageBody(context, homePage as CustomPage , doCallback);
    }

    return Scaffold(
        extendBodyBehindAppBar: true,
        extendBody: true,
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0,
        ),
        endDrawer: new DrawerMenu(),
        bottomNavigationBar: getV3BottomNav(context),
        //drawer: DrawerMenu(),
        body: body
    );


  }
  Future<void> initData() async {
    String jsonString =  await rootBundle.loadString('lib/assets/json/developer.json');

    final Map<String, dynamic> map = json.decode(jsonString);
    PageListHolder?  list = new PageListHolder.fromJson(map);
    homePage = list!.pages!['developer'];

    try{
      setState(() {

      });
    } catch(e){

    }

  }

Widget getBottomNav() {
  List<BottomNavigationBarItem> list = [];

/*
  list.add(BottomNavigationBarItem(
    icon: Icon(Icons.home_filled,),
    backgroundColor: Colors.lightBlue,
    //activeIcon:    Icon(Icons.screen_search_desktop_outlined, color: Colors.green),
    label: 'Home',
  ));
*/


  // logout
  // index 0
  pageNav.forEach((b) {
    list.add(BottomNavigationBarItem(
      activeIcon: Icon(iconFromText(b), color: Colors.red),
      icon: Icon(iconFromText(b), color: Colors.black),
      label: b.label,));

  });


  return BottomNavigationBar(
      selectedItemColor: Colors.blue[800],
      onTap:(index) async {
          if( index < pageNav.length){
            _selectedPageIndex = index;
            VNavButton b = pageNav[index];
            curPage = b.action;

            switch (b.action.toUpperCase()){
              case 'MOREMENU':
                final result = await showMenu(
                  context: context,
                  position: RelativeRect.fromLTRB(1000.0, 1000.0, 0.0, 0.0),
                  items: [
                    PopupMenuItem(
                    child: TextButton.icon(
                    icon: Icon(Icons.delete_outline_rounded),
                    label: Text('Error Dialog'),
                    onPressed: () {
                      showVidDialog(context, 'Error', 'Test error dialog', type: DialogType.Error);
                    }
                    )),
                    PopupMenuItem(
                        child: TextButton.icon(
                            icon: Icon(Icons.delete_outline_rounded),
                            label: Text('Warning Dialog'),
                            onPressed: () {
                              showVidDialog(context, 'Warning', 'Test warning dialog', type: DialogType.Warning);
                            }
                        )),
                    PopupMenuItem(
                        child: TextButton.icon(
                            icon: Icon(Icons.delete_outline_rounded),
                            label: Text('Information Dialog'),
                            onPressed: () {
                              showVidDialog(context, 'Information', 'Test information dialog', type: DialogType.Information);
                            }
                        )),
                  ],
                );
                break;
              default:
                setState(() {

                });
                break;
            }
          }
      },
      currentIndex: _selectedPageIndex,
      type: BottomNavigationBarType.fixed,
      items: list
  );
}
 /* RelativeRect buttonMenuPosition(BuildContext c) {
    final RenderBoxt? bar = c.findRenderObject();
    final RenderObject? overlay = Overlay.of(c).context.findRenderObject();
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        bar!.localToGlobal(bar.size.bottomRight(Offset.zero), ancestor: overlay),
        bar!.localToGlobal(bar.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );
    return position;
  }*/
}
IconData iconFromText(VNavButton b){
  switch (b.icon.toUpperCase()){
    case 'HOME':
      return Icons.home_filled;
    case 'BUTTONS':
      return Icons.smart_button;
    case 'MENUS':
      return Icons.menu_open_outlined;
    case 'MORE':
      return Icons.more_horiz;

    default:
      return Icons.question_mark;
      break;
  }
}


class IconButtonAnchorExample extends StatelessWidget {
  const IconButtonAnchorExample({super.key});

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      builder: (context, controller, child) {
        return IconButton(
          onPressed: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
          icon: const Icon(Icons.more_vert),
        );
      },
      menuChildren: [
        MenuItemButton(
          child: const Text('Menu 1'),
          onPressed: () {},
        ),
        MenuItemButton(
          child: const Text('Menu 2'),
          onPressed: () {},
        ),
        SubmenuButton(
          menuChildren: <Widget>[
            MenuItemButton(
              onPressed: () {},
              child: const Text('Menu 3.1'),
            ),
            MenuItemButton(
              onPressed: () {},
              child: const Text('Menu 3.2'),
            ),
            MenuItemButton(
              onPressed: () {},
              child: const Text('Menu 3.3'),
            ),
          ],
          child: const Text('Menu 3'),
        ),
      ],
    );
  }
}

class VNavButton{
  String label = '';
  String action = '';
  String icon = '';

  VNavButton(this.label, this.icon, this.action);

  VNavButton.fromJson(Map<String, dynamic> json) {
    if( json['label'] != null ) label = json['label'];
    if( json['action'] != null ) action = json['action'];
    if( json['icon'] != null ) icon = json['icon'];
  }

}

