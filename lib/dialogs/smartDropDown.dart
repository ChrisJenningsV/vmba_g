

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vmba/utilities/helper.dart';

class SmartDropDownMenu extends StatefulWidget {
  late List<Icon> icons;
  final List<String> options;
  final BorderRadius borderRadius;
  final Color backgroundColor;
  final Color iconColor;
  double textLen = 100;
  final String initialValue;
  final TextEditingController? controller;
  final ValueChanged<int> onChange;

  SmartDropDownMenu({
    Key? key,
    this.borderRadius = const BorderRadius.all(Radius.circular(5.0)),
    this.backgroundColor = const Color(0xFFF67C0B9),
    this.iconColor = Colors.black,
    required this.onChange,
    required this.options,
    this.controller,
    this.initialValue = ''
  }): super(key: key);
  @override
  _SmartDropDownMenuState createState() => _SmartDropDownMenuState();
}

class _SmartDropDownMenuState extends State<SmartDropDownMenu>
    with SingleTickerProviderStateMixin {
  late GlobalKey _key;
  bool isMenuOpen = false;
  late Offset buttonPosition;
  late Size buttonSize;
  OverlayEntry? _overlayEntry;
  BorderRadius? _borderRadius;
  AnimationController? _animationController;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 250),
    );
    _borderRadius = widget.borderRadius ?? BorderRadius.circular(4);
    _key = LabeledGlobalKey("button_icon");
    widget.icons = getIcons(widget.options);
    super.initState();
  }

  @override
  void dispose() {
    _animationController!.dispose();
    super.dispose();
  }

  findButton() {
    RenderBox? renderBox = _key.currentContext!.findRenderObject() as RenderBox?;
    buttonSize = renderBox!.size;
    buttonPosition = renderBox.localToGlobal(Offset.zero);
  }

  void closeMenu() {
    _overlayEntry!.remove();
    _animationController!.reverse();
    isMenuOpen = !isMenuOpen;
  }

  void openMenu() {
    findButton();
    _animationController!.forward();
    _overlayEntry = _overlayEntryBuilder();
    Overlay.of(context).insert(_overlayEntry!);
    isMenuOpen = !isMenuOpen;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(padding: EdgeInsets.all(5),
      child:
       Container(
        padding: EdgeInsets.only(right: 10,bottom: 10),
        //alignment: Alignment.topLeft,
      key: _key,
      width: 90,
      height: 30,
      decoration: BoxDecoration(
        //color: Colors.grey,
        borderRadius: _borderRadius,
      ),
      child: Row(
        children: [
        getIcon(widget.controller!.text),
           IconButton.outlined(
        icon: AnimatedIcon(
          icon: AnimatedIcons.menu_close,
         // size: 15,
          progress: _animationController as AnimationController,
        ),
        color: Colors.grey,
        onPressed: () {
          if (isMenuOpen) {
            closeMenu();
          } else {
            openMenu();
          }
        },
        )
           ]),
      )
    );
  }

  OverlayEntry _overlayEntryBuilder() {
    if( widget.icons == null ){
      logit('Icons null ');
    }
    return OverlayEntry(
      builder: (context) {
        return Positioned(
          top: buttonPosition.dy + buttonSize.height,
          left: buttonPosition.dx,
          width: buttonSize.width + widget.textLen,
          child: Material(
            color: Colors.transparent,
            child: Stack(
              children: <Widget>[
                Align(
                  alignment: Alignment.topCenter,
                  child: ClipPath(
                    clipper: ArrowClipper(),
                    child: Container(
                      width: 17,
                      height: 17,
                      color: widget.backgroundColor ?? Color(0xFFF),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: Container(
                    height: widget.icons!.length * buttonSize.height,
                    decoration: BoxDecoration(
                      color: widget.backgroundColor,
                      borderRadius: _borderRadius,
                    ),
                    child: Theme(
                      data: ThemeData(
                        iconTheme: IconThemeData(
                          color: widget.iconColor,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(widget.icons!.length, (index) {
                          return GestureDetector(
                            onTap: () {
                              widget.onChange(index);
                              closeMenu();
                            },
                            child: Container(
                              width: buttonSize.width,
                              height: buttonSize.height,
                              child: widget.icons![index],
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
class ArrowClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(0, size.height);
    path.lineTo(size.width / 2, size.height / 2);
    path.lineTo(size.width, size.height);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}


List<Icon> getIcons(List<String> options){
  List<Icon> list = [];
  options.forEach((name) {
    list.add(getIcon(name));
  });

  return list;
}
Icon getIcon(String option){
      switch(option.toUpperCase()){
      case 'PERSON':
        return Icon(Icons.person);
      case 'SETTINGS':
        return Icon(Icons.settings);
      case 'CARD':
        return Icon(Icons.credit_card);
      case 'FILL':
        return Icon(Icons.event_seat);
      case 'LINE':
        return Icon(Icons.event_seat_outlined);
      case 'OVAL':
        return Icon(CupertinoIcons.arrowtriangle_down);
      case 'SQUARE':
        return Icon(CupertinoIcons.app);
      case 'ROUND':
        return Icon(CupertinoIcons.circle);
      case 'OVALFILL':
        return Icon(CupertinoIcons.arrowtriangle_down_fill);
      case 'SQUAREFILL':
        return Icon(CupertinoIcons.app_fill);
      case 'ROUNDFILL':
        return Icon(CupertinoIcons.circle_fill);
    }
  return Icon(Icons.question_mark);
}