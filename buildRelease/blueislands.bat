rem build release version of fastjet for android
@ECHO OFF
cls
ECHO =================
ECHO Build Blue Islands
ECHO =================
ECHO copy key
copy android\app\blueislandsKey\*.jks android\app\
ECHO copy bg
copy lib\assets\blueislands\images\bg.png lib\assets\images
ECHO build store images
call flutter pub run flutter_launcher_icons:main -f launch_icons_blueislands.yaml
ECHO build bundle
call flutter build appbundle -t lib/main.dart --flavor blueislands





