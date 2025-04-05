import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';

import '../components/loader_widget.dart';
import '../main.dart';
import '../utils/images.dart';

class Body extends StatelessWidget {
  final Widget child;

  const Body({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: context.width(),
      height: context.height(),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage(background),fit: BoxFit.cover)
      ),child: child),
          Observer(builder: (_) => LoaderWidget().visible(appStore.isLoading)),
        ],
      ),
    );
  }
}
