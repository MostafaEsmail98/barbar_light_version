import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frezka/screens/auth/view/sign_in_screen.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../main.dart';
import '../../../utils/common_base.dart';
import '../../../utils/constants.dart';
import '../../branch/view/select_branch_screen.dart';
import '../../product/view/product_dashboard_screen.dart';
import '../fragment/booking_fragment.dart';
import '../fragment/home_fragment.dart';
import '../fragment/profile_fragment.dart';

class DashboardScreen extends StatefulWidget {
  final int pageIndex;

  const DashboardScreen({super.key, this.pageIndex = 1});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with WidgetsBindingObserver {
  int currentPosition = 1;

  List<Widget> fragmentList = [
    BookingFragment(),
    HomeFragment(),
    // Observer(builder: (context) => appStore.isLoggedIn ? BookingFragment() : SignInScreen(isFromDashboard: true)),
    // Observer(builder: (context) => appStore.isLoggedIn ? OrderListScreen(showBack: false) : SignInScreen(isFromDashboard: true)),
    ProfileFragment(),
  ];

  @override
  void initState() {
    currentPosition = widget.pageIndex;
    if (getIntAsync(THEME_MODE_INDEX) == ThemeConst.THEME_MODE_SYSTEM) {
      WidgetsBinding.instance.addObserver(this);
    }
    super.initState();
    init();

    LiveStream().on("Hello", (value) {
      if (value == 1) {
        SignInScreen().launch(context, isNewTask: true);
        // setState(() {});
      }
    });
  }

  void init() async {
    afterBuildCreated(() async {
      /// Changes System theme when changed
      if (getIntAsync(THEME_MODE_INDEX) == ThemeConst.THEME_MODE_SYSTEM) {
        appStore.setDarkMode(context.platformBrightness() == Brightness.dark);
      }

      /*View.of(context).platformDispatcher.onPlatformBrightnessChanged = () async {
        if (getIntAsync(THEME_MODE_INDEX) == ThemeConst.THEME_MODE_SYSTEM) {
          appStore.setDarkMode(MediaQuery.of(context).platformBrightness == Brightness.light);
        }
      };*/

      //WidgetsBinding.instance.handlePlatformBrightnessChanged();
    });

    /// ForceUpdate Dialog
    await 3.seconds.delay;
    showForceUpdateDialog(context);

    // if (!appStore.isBranchSelected) {
    //   SelectBranchScreen().launch(context, isNewTask: true);
    // }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void didChangePlatformBrightness() {
    if (getIntAsync(THEME_MODE_INDEX) == ThemeConst.THEME_MODE_SYSTEM) {
      appStore.setDarkMode(
          MediaQuery.of(context).platformBrightness == Brightness.light);
    }
    super.didChangePlatformBrightness();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DoublePressBackWidget(
      message: locale.pressBackAgainToExitApp,
      child: Scaffold(
        extendBody: true,
        body: fragmentList[currentPosition],
        bottomNavigationBar: CurvedNavigationBar(
          index: currentPosition,
          color: Color(0xffDDBF5D),
          backgroundColor: Colors.transparent,
          items: [
            CurvedNavigationBarItem(
              child: FaIcon(
                FontAwesomeIcons.calendar,
                color: currentPosition == 0 ? Colors.white : null,
              ),
              labelStyle: TextStyle(color: Colors.white),
              label: currentPosition == 0 ? locale.booking : null,
            ),
            CurvedNavigationBarItem(
              child: FaIcon(
                FontAwesomeIcons.house,
                color: currentPosition == 1 ? Colors.white : null,
              ),
              labelStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
              label: currentPosition == 1 ? locale.home : null,
            ),
            CurvedNavigationBarItem(
              child: FaIcon(
                FontAwesomeIcons.person,
                color: currentPosition == 2 ? Colors.white : null,
              ),
              labelStyle: TextStyle(color: Colors.white),
              label: currentPosition == 2 ? locale.profile : null,
            ),
          ],
          onTap: (index) {
            setState(() {
              currentPosition = index;
            });
          },
        ),
      ),
    );
  }
}
