import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frezka/components/body_widget.dart';
import 'package:frezka/main.dart';
import 'package:frezka/screens/auth/auth_repository.dart';
import 'package:frezka/screens/auth/view/change_password_screen.dart';
import 'package:frezka/utils/app_common.dart';
import 'package:frezka/utils/colors.dart';
import 'package:nb_utils/nb_utils.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final Function(String? otpCode)? onTap;

  OtpVerificationScreen({this.onTap, required this.phoneNumber});

  @override
  _OtpVerificationScreenState createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final interval = const Duration(seconds: 1);
  final int timerMaxSeconds = 60;
  int currentSeconds = 0;

  String otpCode = '';
// resendOtp start
  resendOtp() {
    print({'mobile': widget.phoneNumber});
    ResendOtpRegisterAPI(widget.phoneNumber).then((resault) async {
      print('resendOtp resault');
      print(resault.toJson());
      toast(resault.message.validate());
      if (resault.status == true) {}
    }).catchError((e) {
      toast(e.toString());
    });
    ;
  }

// resendOtp end
  void submitOtp() {
    if (otpCode.validate().isNotEmpty) {
      if (otpCode.validate().length >= 6) {
        hideKeyboard(context);
        appStore.setLoading(true);
        widget.onTap!.call(otpCode);
      } else {
        toast(locale.pleaseEnterValidOtp);
      }
    } else {
      toast(locale.pleaseEnterValidOtp);
    }
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    startTimeout();
  }

  /// region Start Timer
  void startTimeout([int? milliseconds]) {
    var duration = interval;
    Timer.periodic(duration, (timer) {
      setState(() {
        currentSeconds = timer.tick;
        if (timer.tick >= timerMaxSeconds) {
          timer.cancel();
        }
      });
    });
  }

  /// endregion

  /// region FromWidget
  Widget _formWidget() {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          16.height,
          Directionality(
            textDirection: TextDirection.ltr,
            child: OTPTextField(
              boxDecoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              cursorColor: Colors.black,
              pinLength: 6,
              fieldWidth: 36,
              onChanged: (s) {
                otpCode = s;
                log(otpCode);
              },
              onCompleted: (pin) {
                otpCode = pin;
                submitOtp();
              },
            ).center(),
          ),
        ],
      ),
    );
  }

  /// endregion

  /// region OnVerify OTP
  Future<void> onVerify() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      ChangePasswordScreen().launch(context);
    }
  }

  /// endregion

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Body(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BackButton(
                  color: Colors.white,
                ),
                Text('${((timerMaxSeconds - currentSeconds) ~/ 60).toString().padLeft(2, '0')}: ${((timerMaxSeconds - currentSeconds) % 60).toString().padLeft(2, '0')}',
                        style: boldTextStyle(color: Colors.white, size: 35))
                    .center(),
                Text("${locale.sendCode} ${widget.phoneNumber ?? ""} ",
                        style: secondaryTextStyle(color: Colors.white),
                        textAlign: TextAlign.center)
                    .center(),
                16.height,
                _formWidget(),
                16.height,
                8.height,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(locale.didNotGetTheOtp, style: secondaryTextStyle()),
                    TextButton(
                      onPressed: () {
                        if (currentSeconds == timerMaxSeconds) {
                          resendOtp();
                        } else {
                          toast('انتظر حتى ينتهي العد');
                        }
                      },
                      child: Text(locale.resendOtp,
                          style: boldTextStyle(
                              color: currentSeconds == timerMaxSeconds
                                  ? Colors.white
                                  : Colors.grey,
                              decoration: TextDecoration.underline,
                              size: 14)),
                    ),
                  ],
                ),
                36.height,
                AppButton(
                  shapeBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20)),
                  child:
                      Text(locale.confirm, style: boldTextStyle(color: white)),
                  width: context.width(),
                  color: primaryColor,
                  onTap: () {
                    submitOtp();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
