import 'package:flutter/material.dart';
import 'package:frezka/screens/auth/view/change_password_screen.dart';
import 'package:frezka/utils/common_base.dart';
import 'package:frezka/utils/extensions/string_extensions.dart';
import 'package:frezka/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/app_scaffold.dart';
import '../../../main.dart';
import '../../../network/rest_apis.dart';
import '../../../utils/app_common.dart';
import '../../app_language_screen.dart';
import '../../auth/auth_repository.dart';
import '../../dashboard/view/dashboard_screen.dart';
import '../components/theme_selection_dialog.dart';

class SettingScreen extends StatefulWidget {
  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBarWidget: commonAppBarWidget(
        context,
        title: locale.setting,
        appBarHeight: 70,
        showLeadingIcon: true,
        roundCornerShape: true,
      ),
      body: AnimatedScrollView(
        padding: EdgeInsets.symmetric(vertical: 8),
        listAnimationType: ListAnimationType.None,
        children: [
          SettingItemWidget(
            leading: ic_app_language.iconImage(size: 16),
            title: locale.language,
            titleTextColor: Colors.white,
            trailing: ic_arrow_right.iconImage(size: 16,color: Colors.white),
            splashColor: Colors.transparent,
            onTap: () {
              AppLanguageScreen().launch(context).then((value) {
                setState(() {});
              });
            },
          ),
          SettingItemWidget(
            leading: ic_dark_mode.iconImage(size: 16),
            title: locale.appTheme,
            titleTextColor: Colors.white,
            trailing: ic_arrow_right.iconImage(size: 16,color: Colors.white),
            onTap: () async {
              await showInDialog(
                context,
                builder: (context) => ThemeSelectionDaiLog(),
                contentPadding: EdgeInsets.zero,
              );
            },
          ),
          if (!isSocialLoginType)
            SettingItemWidget(
              leading: ic_lock.iconImage(size: 16),
              title: locale.changePassword,
              titleTextColor: Colors.white,
              trailing: ic_arrow_right.iconImage(size: 16,color: Colors.white),
              splashColor: Colors.transparent,
              onTap: () {
                doIfLoggedIn(context, () {
                  setState(() {});
                  ChangePasswordScreen().launch(context);
                });
              },
            ),
          if (appStore.isLoggedIn)
            SettingItemWidget(
              titleTextColor: Colors.white,
              trailing: ic_arrow_right.iconImage(size: 16,color: Colors.white),
              paddingBeforeTrailing: 4,
              title: locale.deleteAccount,
              onTap: () {
                showConfirmDialogCustom(
                  context,
                  negativeText: locale.cancel,
                  positiveText: locale.delete,
                  onAccept: (_) {
                    ifNotTester(() {
                      appStore.setLoading(true);

                      deleteAccountCompletely().then((value) async {
                        await clearPreferences();
                        appStore.setLoading(false);

                        toast(value.message);

                        push(DashboardScreen(), isNewTask: true, pageRouteAnimation: PageRouteAnimation.Fade);
                      }).catchError((e) {
                        appStore.setLoading(false);
                        toast(e.toString());
                      });
                    });
                  },
                  dialogType: DialogType.DELETE,
                  title: locale.deleteAccountConfirmation,
                );
              },
            ),
        ],
      ),
    );
  }
}
