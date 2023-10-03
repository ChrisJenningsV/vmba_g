rem build release version of Aurigny for android
@ECHO OFF
cls
ECHO =================
ECHO Build Aurigny
ECHO =================
ECHO copy key
copy android\app\AurignyKey\*.jks android\app\
ECHO copy bg
copy lib\assets\Aurigny\images\bg.png lib\assets\images
ECHO build store images
call flutter pub run  flutter_launcher_icons:main -f launch_icons_Aurigny.yaml
ECHO build bundle
call flutter build appbundle -t lib/main.dart --flavor Aurigny





