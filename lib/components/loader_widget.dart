import 'package:flutter/material.dart';
import 'package:frezka/main.dart';
import 'package:nb_utils/nb_utils.dart';

class LoaderWidget extends StatelessWidget {
  final double? height;
  final double? width;
  final Color? color;

  LoaderWidget({this.height, this.width, this.color});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/frezka_loader.gif',
      height: 0,
      width: 0,
      // height: height ?? 150,
      // width: width ?? 150,
      color: color ?? Colors.red,
    ).center();
  }
}
