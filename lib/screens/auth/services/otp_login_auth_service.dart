import 'package:frezka/main.dart';
import 'package:frezka/screens/auth/auth_repository.dart';
import 'package:frezka/screens/auth/view/otp_verification_screen.dart';
import 'package:frezka/screens/auth/view/sign_up_screen.dart';
import 'package:frezka/screens/dashboard/view/dashboard_screen.dart';
import 'package:frezka/utils/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../utils/model_keys.dart';
import '../model/user_data_model.dart';

class OtpLoginAuthService {

  Future loginWithOTP(BuildContext context, {required String phoneNumber,required String countryCode,required String password,required String firstName,required String lastName,}) async {
    log("PHONE NUMBER VERIFIED $countryCode$phoneNumber");
    return await auth.verifyPhoneNumber(
      phoneNumber: "$countryCode$phoneNumber",
      verificationCompleted: (PhoneAuthCredential credential) {
        toast(locale.verified);
      },
      verificationFailed: (FirebaseAuthException e) {
        appStore.setLoading(false);
        if (e.code == 'invalid-phone-number') {
          toast(locale.otpInvalidMessage, print: true);
        } else {
          toast(e.toString(), print: true);
        }
      },
      codeSent: (String verificationId, int? resendToken) async {
        appStore.setLoading(false);

        /// Opens a dialog when the code is sent to the user successfully.
        await OtpVerificationScreen(
          phoneNumber: phoneNumber,
          onTap: (otpCode) async {
            if (otpCode != null) {
              AuthCredential credential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: otpCode);

              await auth.signInWithCredential(credential).then((credentials) async {
                UserData userResponse = UserData()
                  ..firstName = firstName
                  ..lastName = lastName
                  ..loginType = LoginTypeConst.LOGIN_TYPE_OTP
                  ..mobile = phoneNumber
                  ..userType = LoginTypeConst.LOGIN_TYPE_USER
                  ..password = password
                .. gender = "male";

                Map request = {
                  "mobile": phoneNumber,
                  CommonKey.password: password,
                };

                await createUser(userResponse.toJson()).then((register) async {
                  if(register.status == true){
                    loginUser(request).then((loginResponse)async{
                      toast(locale.loginSuccessfully);


                      if (loginResponse.userData != null) await saveUserData(loginResponse.userData!);

                      if (loginResponse.userData!.status == 0) {
                        toast(locale.pleaseContactWithAdmin);
                      } else {
                        DashboardScreen().launch(context, isNewTask: true, pageRouteAnimation: PageRouteAnimation.Fade);
                      }
                    },);
                  }
                });
              }).catchError((e) {
                if (e.code.toString() == 'invalid-verification-code') {
                  toast(locale.otpInvalidMessage, print: true);
                } else {
                  toast(e.message.toString(), print: true);
                }
                appStore.setLoading(false);
              });
            }
          },
        ).launch(context);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        //
      },
    );
  }
}