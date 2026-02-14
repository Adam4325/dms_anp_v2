import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 3000)
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.custom
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..progressColor = Colors.white
    ..backgroundColor = Colors.black
    ..indicatorColor = Colors.white
    ..textColor = Colors.yellow
    ..maskColor = Colors.blue.withOpacity(0.5)
    ..userInteractions = true
    ..customAnimation = CustomAnimation();
}

class CustomAnimation extends EasyLoadingAnimation {
  CustomAnimation();

  @override
  Widget buildWidget(
      Widget child,
      AnimationController controller,
      AlignmentGeometry alignment,
      ) {
    double opacity = controller.value;
    return Opacity(
      opacity: opacity,
      child: RotationTransition(
        turns: controller,
        child: child,
      ),
    );
  }
}

void FlushbarNotif(BuildContext context, {String title='No Data !', String message = 'Data is empty'}){
  Flushbar(
    title: title.toString(),
    message: message.toString(),
    icon: Icon(
      Icons.info_outline,
      color: Colors.white,
    ),
    backgroundGradient:
    LinearGradient(colors: [Colors.blue, Colors.teal]),
    backgroundColor: Colors.red,
    boxShadows: [
      BoxShadow(
        color: Colors.blue.shade800,
        offset: Offset(0.0, 2.0),
        blurRadius: 3.0,
      )
    ],
    duration: Duration(seconds: 3),
  )..show(context);
}