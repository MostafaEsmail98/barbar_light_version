import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frezka/components/app_scaffold.dart';
import 'package:frezka/main.dart';
import 'package:frezka/screens/auth/auth_repository.dart';
import 'package:frezka/screens/auth/view/otp_verification_screen.dart';
import 'package:frezka/screens/auth/view/reset_password.dart';
import 'package:frezka/utils/colors.dart';
import 'package:frezka/utils/common_base.dart';
import 'package:frezka/utils/model_keys.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:nb_utils/nb_utils.dart';

import 'change_password_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController emailCont = TextEditingController();

  // FocusNode emailFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    //
  }

  TextEditingController phoneCont = TextEditingController();

  Future<void> forgotPwd() async {
    if (formKey.currentState!.validate()) {
      hideKeyboard(context);
      formKey.currentState!.save();
      appStore.setLoading(true);

      resetPasswordAPI(phoneCont.text.validate()).then((res) {
        appStore.setLoading(false);
        finish(context);
        toast(res.message.validate());
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OtpVerificationScreen(
                phoneNumber: phoneCont.text.validate(),
                onTap: checkOtp,
              ),
            ));
      }).catchError((e) {
        toast(e.toString(), print: true);
      }).whenComplete(() => appStore.setLoading(false));
    }
  }

// checkOtp start
  checkOtp(otp) {
    confirmPasswordAPI({'mobile': phoneCont.text.trim(), 'otp': otp})
        .then((resault) async {
      print('checkOtp resault');
      print(resault.toJson());
      toast(resault.message.validate());
      if (resault.status == true) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ResetPassword(
                      phoneNumber: phoneCont.text.trim(),
                      otp: otp,
                    )));
      }
    }).catchError((e) {
      toast(e.toString());
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AppScaffold(
        showAppBar: false,
        body: Form(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  width: context.width(),
                  decoration: boxDecorationDefault(
                    color: context.primaryColor,
                    borderRadius: radiusOnly(
                        topRight: defaultRadius, topLeft: defaultRadius),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(locale.forgotPassword,
                          style: boldTextStyle(color: Colors.white)),
                      IconButton(
                        onPressed: () {
                          finish(context);
                        },
                        icon: Icon(Icons.clear, color: Colors.white, size: 20),
                      )
                    ],
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(locale.enterYourNumber,
                        style: boldTextStyle(color: Colors.white)),
                    6.height,
                    Text(locale.aResetPasswordLink,
                        style: secondaryTextStyle(color: Colors.grey)),
                    24.height,
                    _buildPhoneField(
                      controller: phoneCont,
                      hintText: locale.phoneNumber,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return locale.phoneIsEmpty;
                        }
                        return null;
                      },
                    ),
                    24.height,
                    AppButton(
                      text: locale.next,
                      color: secondaryColor,
                      textColor: Colors.white,
                      width: context.width() - context.navigationBarHeight,
                      onTap: () {
                        forgotPwd();
                      },
                    ),
                  ],
                ).paddingAll(16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneField(
      {required String hintText,
      bool isPassword = false,
      TextEditingController? controller,
      String? Function(String?)? validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Directionality(
          textDirection: TextDirection.ltr,
          child: IntlPhoneField(
            disableAutoFillHints: true,
            showDropdownIcon: false,
            decoration: InputDecoration(
              errorStyle: TextStyle(
                  color: const Color.fromARGB(255, 244, 114, 105),
                  fontSize: 18,
                  fontWeight: FontWeight.w600),
              filled: true,
              isDense: true,
              fillColor: Colors.white,
              suffixIcon: isPassword
                  ? Padding(
                      padding: const EdgeInsets.all(10),
                      child: Image.asset(
                        "assets/icons/lock.png",
                        width: 33,
                        height: 33,
                      ),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(35),
                borderSide: BorderSide.none,
              ),
            ),
            style: TextStyle(color: Colors.black),
            initialCountryCode: 'JO',
            // controller: controller,
            onChanged: (phone) {
              print(phone.completeNumber);
              controller!.text = phone.completeNumber;
            },
          ),
        ),
      ],
    );
  }
}
