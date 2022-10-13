rem build release version of air swift for android
@ECHO OFF
cls
ECHO =================
ECHO Build Air Swift
ECHO =================
ECHO copy key
copy android\app\airSwiftKey\*.jks android\app\
ECHO copy bg
copy lib\assets\airswift\images\bg.png lib\assets\images
ECHO build store images
call flutter pub run --no-sound-null-safety flutter_launcher_icons:main -f launch_icons_airswift.yaml
ECHO build bundle
call flutter build appbundle -t lib/main.dart --flavor airswift





