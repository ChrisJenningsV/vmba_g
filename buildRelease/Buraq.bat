rem build release version of Buraq for android
@ECHO OFF
cls
ECHO =================
ECHO Build Buraq
ECHO =================
ECHO copy key
copy android\app\BuraqKey\*.jks android\app\
ECHO copy bg
copy lib\assets\Buraq\images\bg.png lib\assets\images
ECHO build store images
call flutter pub run --no-sound-null-safety flutter_launcher_icons:main -f launch_icons_Buraq.yaml
ECHO build bundle
call flutter build appbundle -t lib/main.dart --flavor Buraq





