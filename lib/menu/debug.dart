import 'package:flutter/material.dart';
import 'package:vmba/components/showDialog.dart';

import '../data/globals.dart';

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
  ColorSelectionMethod colorSelectionMethod = ColorSelectionMethod.colorSeed;
  ColorSeed colorSelected = ColorSeed.baseColor;
  int navDrawerIndex = 0;




  List<VNavButton> pageNav = [
    // label, icon, action
    VNavButton('Db Home', 'Home', 'LoadDbHome'),
    VNavButton('Buttons', 'Buttons', 'ButtonPage'),
    VNavButton('Menus', 'Menus', 'MenuPage'),
    VNavButton('More', 'More', 'MoreMenu'),
  ];



  @override void initState() {
    // TODO: implement initState

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
        data: ThemeData(
          colorSchemeSeed: /*colorSelectionMethod == ColorSelectionMethod.colorSeed
              ?*/ colorSelected.color              /*: null*/,
/*
          colorScheme: colorSelectionMethod == ColorSelectionMethod.image
              ? imageColorScheme
              : null,
*/
        ),
        child: Builder(
            builder: (context) {
              return Scaffold(
                /*floatingActionButton: FloatingActionButton(
        onPressed: () {},
        elevation: 0.0,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation:
      FloatingActionButtonLocation.endContained,*/

/*
      AppBar(
        title: const Text('Debug page'),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            child: const Text('Close'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
*/

                appBar: createAppBar(),
                /*
      AppBar(

        bottom: TabBar(
//          controller: _tabController,
          tabs: const <Widget>[
            Tab(
              icon: Icon(Icons.videocam_outlined),
              text: 'Video',
              iconMargin: EdgeInsets.only(bottom: 0.0),
            ),
            Tab(
              icon: Icon(Icons.photo_outlined),
              text: 'Photos',
              iconMargin: EdgeInsets.only(bottom: 0.0),
            ),
            Tab(
              icon: Icon(Icons.audiotrack_sharp),
              text: 'Audio',
              iconMargin: EdgeInsets.only(bottom: 0.0),
            ),
          ],
        ),
        // TODO: Showcase secondary tab bar https://github.com/flutter/flutter/issues/111962
      ),
*/
                body: getBody(),
                bottomNavigationBar: getBottomNav(),
                /*BottomAppBar(
        child: Row(
          children: <Widget>[
            IconButtonAnchorExample(),
            BottomNavigationBarItem(
            icon: Icon(Icons.logout, color: Colors.red),
            activeIcon: Icon(Icons.logout, color: Colors.red),
            label: 'Logout',)),
            IconButton(
              tooltip: 'Search',
              icon: const Icon(Icons.search),
              onPressed: () {},
            ),
            IconButton(
              tooltip: 'Favorite',
              icon: const Icon(Icons.favorite),
              onPressed: () {},
            ),
          ],*/
              );
            }
       )
    );
  }

  PreferredSizeWidget createAppBar() {
    return AppBar(
      title: useMaterial3
          ? const Text('Material 3')
          : const Text('Material 2'),
      actions: /*!showMediumSizeLayout && !showLargeSizeLayout
          ?*/ [
/*
        _BrightnessButton(
          handleBrightnessChange: widget.handleBrightnessChange,
        ),
        _Material3Button(
          handleMaterialVersionChange: widget.handleMaterialVersionChange,
        ),
*/
        _ColorSeedButton(
          handleColorSelect: handleColorSelect,
          colorSelected: colorSelected,
          colorSelectionMethod: colorSelectionMethod,
        ),
/*
        _ColorImageButton(
          handleImageSelect: widget.handleImageSelect,
          imageSelected: widget.imageSelected,
          colorSelectionMethod: widget.colorSelectionMethod,
        )
*/
      ]
          /*: [Container()]*/,
    );
  }
  void handleColorSelect(int value) {
    setState(() {
      colorSelectionMethod = ColorSelectionMethod.colorSeed;
      colorSelected = ColorSeed.values[value];
    });
  }

  Widget getBody() {
    switch ( curPage){
      case 'BUTTONPAGE':
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          child: IntrinsicWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                ElevatedButton(
                  onPressed: isDisabled ? null : () {},
                  child: const Text('Elevated'),
                ),
                colDivider,
                FilledButton(
                  onPressed: isDisabled ? null : () {},
                  child: const Text('Filled'),
                ),
                colDivider,
                FilledButton.tonal(
                  onPressed: isDisabled ? null : () {},
                  child: const Text('Filled tonal'),
                ),
                colDivider,
                OutlinedButton(
                  onPressed: isDisabled ? null : () {},
                  child: const Text('Outlined'),
                ),
                colDivider,
                TextButton(
                  onPressed: isDisabled ? null : () {},
                  child: const Text('Text'),
                ),
              ],
            ),
          ),
        );
        break;
      case 'MenuPage':
      return NavigationDrawer(
    onDestinationSelected: (selectedIndex) {
    setState(() {
    navDrawerIndex = selectedIndex;
    });
    },
    selectedIndex: navDrawerIndex,
    children: <Widget>[
    Padding(
    padding: const EdgeInsets.fromLTRB(28, 16, 16, 10),
    child: Text(
    'Mail',
    style: Theme.of(context).textTheme.titleSmall,
    ),
    ),
    /*...destinations.map((destination) {
    return NavigationDrawerDestination(
    label: Text(destination.label),
    icon: destination.icon,
    selectedIcon: destination.selectedIcon,
    );*/
    ]
      );
        break;

      default:
        // default page
        return Row( children: [
          IntrinsicWidth(
    child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ElevatedButton(
              onPressed: isDisabled ? null : () {},
              child: const Text('Elevated'),
            ),
            colDivider,
            FilledButton(
              onPressed: isDisabled ? null : () {},
              child: const Text('Filled'),
            ),
            colDivider,
            FilledButton.tonal(
              onPressed: isDisabled ? null : () {},
              child: const Text('Filled tonal'),
            ),
            colDivider,
            OutlinedButton(
              onPressed: isDisabled ? null : () {},
              child: const Text('Outlined'),
            ),
            colDivider,
            TextButton(
              onPressed: isDisabled ? null : () {},
              child: const Text('Text'),
            ),
          ],
        )),
    IntrinsicWidth(
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: <Widget>[
    ElevatedButton.icon(
    onPressed: () {},
    icon: const Icon(Icons.add),
    label: const Text('Icon'),
    ),
    colDivider,
    FilledButton.icon(
    onPressed: () {},
    label: const Text('Icon'),
    icon: const Icon(Icons.add),
    ),
    colDivider,
    FilledButton.tonalIcon(
    onPressed: () {},
    label: const Text('Icon'),
    icon: const Icon(Icons.add),
    ),
    colDivider,
    OutlinedButton.icon(
    onPressed: () {},
    icon: const Icon(Icons.add),
    label: const Text('Icon'),
    ),
    colDivider,
    TextButton.icon(
    onPressed: () {},
    icon: const Icon(Icons.add),
    label: const Text('Icon'),
    )
    ],
    ),
    )
    ]);
        break;
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


/*
  // blue screen
  list.add(BottomNavigationBarItem(
    icon: Icon(Icons.calendar_month_outlined, color: Colors.blue),
    backgroundColor: Colors.lightBlue,
    //activeIcon:    Icon(Icons.screen_search_desktop_outlined, color: Colors.green),
    label: 'Bookings',
  ));

  // live / test
  list.add(BottomNavigationBarItem(
    icon: Icon(Icons.menu_sharp),
    label: 'more',
  ));

  logit( 'cc=${gblSettings.creditCardProvider} page=$gblCurPage');
  if( gblCurPage == 'CREDITCARDPAGE' && gblSettings.creditCardProvider.toLowerCase() == 'videcard' ) {
    logit('add');
    //_custom = widget.custom;
    // populate test CC
    list.add( BottomNavigationBarItem(
      icon: Icon(Icons.credit_card, color: Colors.blue),
      activeIcon: Icon(Icons.credit_card, color: Colors.green),
      label: 'add CC',
    ));
  }

*/

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
class _ColorSeedButton extends StatelessWidget {
  const _ColorSeedButton({
    required this.handleColorSelect,
    required this.colorSelected,
    required this.colorSelectionMethod,
  });

  final void Function(int) handleColorSelect;
  final ColorSeed colorSelected;
  final ColorSelectionMethod colorSelectionMethod;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      icon: Icon(
        Icons.palette_outlined,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      tooltip: 'Select a seed color',
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      itemBuilder: (context) {
        return List.generate(ColorSeed.values.length, (index) {
          ColorSeed currentColor = ColorSeed.values[index];

          return PopupMenuItem(
            value: index,
            enabled: currentColor != colorSelected ||
                colorSelectionMethod != ColorSelectionMethod.colorSeed,
            child: Wrap(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Icon(
                    currentColor == colorSelected &&
                        colorSelectionMethod != ColorSelectionMethod.image
                        ? Icons.color_lens
                        : Icons.color_lens_outlined,
                    color: currentColor.color,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Text(currentColor.label),
                ),
              ],
            ),
          );
        });
      },
      onSelected: handleColorSelect,
    );
  }
}
enum ColorSelectionMethod {
  colorSeed,
  image,
}

enum ColorSeed {
  baseColor('M3 Baseline', Color(0xff6750a4)),
  indigo('Indigo', Colors.indigo),
  blue('Blue', Colors.blue),
  teal('Teal', Colors.teal),
  green('Green', Colors.green),
  yellow('Yellow', Colors.yellow),
  orange('Orange', Colors.orange),
  deepOrange('Deep Orange', Colors.deepOrange),
  pink('Pink', Colors.pink);

  const ColorSeed(this.label, this.color);
  final String label;
  final Color color;
}

