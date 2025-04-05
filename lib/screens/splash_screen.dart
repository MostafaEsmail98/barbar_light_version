import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frezka/screens/auth/view/sign_in_screen.dart';
import 'package:frezka/screens/branch/view/select_branch_screen.dart';
import 'package:frezka/screens/dashboard/view/dashboard_screen.dart';
import 'package:frezka/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';

import '../components/no_branch_error_widget.dart';
import '../main.dart';
import '../network/rest_apis.dart';
import '../utils/constants.dart';
import 'auth/auth_repository.dart';
import 'branch/branch_repository.dart';
import 'walkThrough/view/walk_through_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    init();
    super.initState();
  }

  void init() async {
    int themeModeIndex = getIntAsync(THEME_MODE_INDEX); //TODO
    if (themeModeIndex == ThemeConst.THEME_MODE_LIGHT) {
      appStore.setDarkMode(false);
    } else if (themeModeIndex == ThemeConst.THEME_MODE_DARK) {
      appStore.setDarkMode(true);
    }

    ///Set app configurations
    getAppConfigurations();
    Future.delayed(Duration(seconds: 2), () {
      DashboardScreen().launch(context, isNewTask: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage(background), fit: BoxFit.cover)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(logo, fit: BoxFit.cover).center(),
            Image.asset(sinceTime, width: 100, fit: BoxFit.cover).center(),
          ],
        ),
      ),
    );
  }
}
