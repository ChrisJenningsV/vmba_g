
import 'package:flutter/material.dart';
import 'package:vmba/data/SystemColors.dart';
import 'package:vmba/data/settings.dart';

class AppConfig extends InheritedWidget {
  final String appTitle;
  final String buildFlavor;
  final Widget child;
  final SystemColors systemColors;
  final Settings settings;


  AppConfig(
      {required this.child,
      required this.appTitle,
      required this.buildFlavor ,
      required this.systemColors,
      required this.settings}) : super(child: child) ;

  static AppConfig? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType(aspect: AppConfig);
  }

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => false;
}
