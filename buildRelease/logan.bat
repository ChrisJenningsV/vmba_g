rem build release version of logan air for android
@ECHO OFF
cls
ECHO =================
ECHO Build logan air
ECHO =================
ECHO copy key
copy android\app\loganKey\*.jks android\app\
ECHO copy bg
copy lib\assets\loganair\images\bg.png lib\assets\images
ECHO build store images
rem call flutter pub run flutter_launcher_icons:main -f launch_icons_loganair.yaml
call flutter pub run flutter_launcher_icons -f launch_icons_loganair.yaml
ECHO build bundle
call flutter build appbundle -t lib/main.dart --flavor loganair





