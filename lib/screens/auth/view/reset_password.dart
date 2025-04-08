import 'package:flutter/material.dart';
import 'package:frezka/screens/auth/view/sign_in_screen.dart';
import 'package:frezka/utils/extensions/string_extensions.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/app_scaffold.dart';
import '../../../main.dart';
import '../../../utils/app_common.dart';
import '../../../utils/colors.dart';
import '../../../utils/common_base.dart';
import '../../../utils/constants.dart';
import '../../../utils/images.dart';
import '../../../utils/model_keys.dart';
import '../auth_repository.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key, required this.phoneNumber, required this.otp});

  final String phoneNumber;
  final String otp;

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController newPasswordCont = TextEditingController();
  TextEditingController reenterPasswordCont = TextEditingController();

  FocusNode newPasswordFocus = FocusNode();
  FocusNode reenterPasswordFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBarWidget: commonAppBarWidget(
        context,
        title: locale.changePassword,
        appBarHeight: 70,
        showLeadingIcon: true,
        roundCornerShape: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(locale.newPasswordsMustBeDifferent,
                  style: secondaryTextStyle()),
              24.height,
              AppTextField(
                textFieldType: TextFieldType.PASSWORD,
                controller: newPasswordCont,
                focus: newPasswordFocus,
                nextFocus: reenterPasswordFocus,
                errorThisFieldRequired: locale.thisFieldIsRequired,
                suffixPasswordVisibleWidget:
                    ic_show.iconImage(size: 10).paddingAll(14),
                suffixPasswordInvisibleWidget:
                    ic_hide.iconImage(size: 10).paddingAll(14),
                validator: (value) {
                  if (value!.isEmpty) {
                    return locale.thisFieldIsRequired;
                  }
                  return null;
                },
                decoration: inputDecoration(context, label: locale.newPassword),
              ),
              16.height,
              AppTextField(
                textFieldType: TextFieldType.PASSWORD,
                controller: reenterPasswordCont,
                focus: reenterPasswordFocus,
                errorThisFieldRequired: locale.thisFieldIsRequired,
                suffixPasswordVisibleWidget:
                    ic_show.iconImage(size: 10).paddingAll(14),
                suffixPasswordInvisibleWidget:
                    ic_hide.iconImage(size: 10).paddingAll(14),
                validator: (value) {
                  if (value!.isEmpty) {
                    return locale.thisFieldIsRequired;
                  } else if (value != newPasswordCont.text) {
                    return locale.thePasswordDoesNotMatch;
                  }
                  return null;
                },
                onFieldSubmitted: (s) {
                  changePassword();
                },
                decoration:
                    inputDecoration(context, label: locale.reEnterPassword),
              ),
              24.height,
              AppButton(
                text: locale.confirm,
                color: secondaryColor,
                textColor: Colors.white,
                width: context.width() - context.navigationBarHeight,
                onTap: () {
                  ifNotTester(() {
                    changePassword();
                  });
                },
              ),
              24.height,
            ],
          ),
        ),
      ),
    );
  }

  void changePassword() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();

      hideKeyboard(context);

      var request = {
        UserKeys.mobile: widget.phoneNumber,
        UserKeys.otp: widget.otp,
        UserKeys.password: newPasswordCont.text,
      };

      appStore.setLoading(true);

      await changeResetPasswordAPI(request).then((res) async {
        await setValue(
            SharedPreferenceConst.USER_PASSWORD, newPasswordCont.text);
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SignInScreen(),
            ));
      }).catchError((e) {
        toast(e.toString(), print: true);
      });
      appStore.setLoading(false);
    }
  }
}
