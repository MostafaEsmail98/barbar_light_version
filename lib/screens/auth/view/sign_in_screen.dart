import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frezka/main.dart';
import 'package:frezka/screens/auth/auth_repository.dart';
import 'package:frezka/screens/auth/model/user_data_model.dart';
import 'package:frezka/screens/auth/view/forgot_password_screen.dart';
import 'package:frezka/screens/auth/view/otp_verification_screen.dart';

// import 'package:frezka/screens/auth/view/sign_up_screen.dart';
import 'package:frezka/screens/dashboard/view/dashboard_screen.dart';
import 'package:frezka/utils/cache_helper.dart';
import 'package:frezka/utils/colors.dart';
import 'package:frezka/utils/common_base.dart';
import 'package:frezka/utils/constants.dart';
import 'package:frezka/utils/images.dart';
import 'package:frezka/utils/model_keys.dart';
import 'package:frezka/utils/push_notification_service.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/app_scaffold.dart';
import '../../../components/back_widget.dart';
import '../../../network/network_utils.dart';
import '../../../utils/app_common.dart';
import '../../branch/view/select_branch_screen.dart';
import '../services/otp_login_auth_service.dart';

class SignInScreen extends StatefulWidget {
  final bool isRegeneratingToken;
  final bool? isFromDashboard;
  final bool? isFromServiceBooking;
  final bool returnExpected;

  const SignInScreen({
    Key? key,
    this.returnExpected = false,
    this.isRegeneratingToken = false,
    this.isFromDashboard,
    this.isFromServiceBooking,
  }) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final GlobalKey<FormState> signInFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> signUpFormKey = GlobalKey<FormState>();

  TextEditingController phoneCont = TextEditingController();
  TextEditingController passwordCont = TextEditingController();
  TextEditingController signUpFirstNameCont = TextEditingController();
  TextEditingController signUpLastNameCont = TextEditingController();
  TextEditingController signUpEmailCont = TextEditingController();
  TextEditingController signUpPasswordCont = TextEditingController();
  TextEditingController signUpMobileCont = TextEditingController();

  FocusNode emailFocus = FocusNode();

  // FocusNode passwordFocus = FocusNode();

  bool isRemember = true;
  bool isLogin = true;

  @override
  void initState() {
    init();
    super.initState();
  }

// checkOtp start
  checkOtp(otp) {
    VerifyOtpRegisterAPI({'mobile': signUpMobileCont.text.trim(), 'otp': otp})
        .then((resault) async {
      print('checkOtp resault');
      print(resault.toJson());
      toast(resault.message.validate());
      if (resault.status == true) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => SignInScreen()));
      }
    }).catchError((e) {
      toast(e.toString());
    });
  }

// checkOtp end
// resendOtp start
  resendOtp(phoneNumber) {
    print({'mobile': phoneNumber});
    ResendOtpRegisterAPI(phoneNumber).then((resault) async {
      print('resendOtp resault');
      print(resault.toJson());
      toast(resault.message.validate());
      if (resault.status == true) {}
    }).catchError((e) {
      toast(e.toString());
    });
    ;
  }

  /// region Register User
  void registerUser() async {
    hideKeyboard(context);

    //  if (appStore.isLoading) return;
    print(signUpPasswordCont.text.trim());
    if (signUpFormKey.currentState!.validate()) {
      signUpFormKey.currentState!.save();

      appStore.setLoading(true);

      /// Create a temporary request to send
      UserData tempRegisterData = UserData()
        // ..userType = LoginTypeConst.LOGIN_TYPE_USER
        ..firstName = signUpFirstNameCont.text.trim()
        ..lastName = signUpLastNameCont.text.trim()
        ..email = signUpEmailCont.text.trim()
        ..password = signUpPasswordCont.text.trim()
        ..mobile = signUpMobileCont.text.trim();
      print('tempRegisterData');
      print(tempRegisterData.toJson());
      await createUser(tempRegisterData.toJson())
          .then((registerResponse) async {
        print('registerResponse');
        print(registerResponse.toJson());
        appStore.setLoading(false);
        toast(registerResponse.message.validate());
        // finish(context); تم استخدام mobile من قبل.
        if (registerResponse.status == true ||
            registerResponse.message == "تم استخدام mobile من قبل.") {
          if (registerResponse.message == "تم استخدام mobile من قبل.") {
            resendOtp(signUpMobileCont.text.trim());
          }
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => OtpVerificationScreen(
                      onTap: checkOtp,
                      phoneNumber: signUpMobileCont.text.trim())));
        }
      }).catchError((e) {
        appStore.setLoading(false);

        toast(e.toString());
      });
    }
  }

  void init() async {
    // isRemember = getBoolAsync(SharedPreferenceConst.IS_REMEMBERED, defaultValue: true);
    // if (isRemember ) {
    //   phoneCont.text = getStringAsync(SharedPreferenceConst.USER_EMAIL, defaultValue: await isIqonicProduct ? DEFAULT_EMAIL : "");
    //   passwordCont.text = getStringAsync(SharedPreferenceConst.USER_PASSWORD, defaultValue: await isIqonicProduct ? DEFAULT_PASS : "");
    // }
  }

  /// region SignInTapped
  Future<void> onSignIn() async {
    hideKeyboard(context);
    if (signInFormKey.currentState!.validate()) {
      appStore.setLoading(true);

      Map request = {
        "fcm": CacheHelper.getData(key: 'fcmToken') ?? '',
        "mobile": phoneCont.text.validate(),
        CommonKey.password: passwordCont.text.validate(),
      };

      await loginUser(request).then((value) {
        if (isRemember) {
          setValue(SharedPreferenceConst.USER_EMAIL, phoneCont.text);
          setValue(SharedPreferenceConst.USER_PASSWORD, passwordCont.text);
        }

        ///This method called for update onesignal playerId to database
        reGenerateToken();

        onLoginSuccessRedirection();
      }).catchError((e) {
        appStore.setLoading(false);
        toast(e.toString(), print: true);
      });

      appStore.setLoading(false);
    }
  }

  void onLoginSuccessRedirection() {
    TextInput.finishAutofillContext();
    // Firebase Notification
    PushNotificationService().registerFCMAndTopics();
    if (widget.isFromServiceBooking.validate() ||
        widget.isFromDashboard.validate() ||
        widget.returnExpected.validate()) {
      finish(context, true);
    } else {
      DashboardScreen().launch(context,
          isNewTask: true, pageRouteAnimation: PageRouteAnimation.Fade);
    }
    appStore.setLoading(false);
  }

  void appleSign() async {
    appStore.setLoading(true);

    await authService.appleSignIn().then((value) async {
      appStore.setLoading(false);

      onLoginSuccessRedirection();
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString());
    });
  }

  void googleSignIn() async {
    appStore.setLoading(true);
    await googleSignInAuthService.signInWithGoogle(context).then((value) async {
      /// Social Login Api
      await loginUser(value.toJson(), isSocialLogin: true).then((value) {
        if (isRemember) {
          setValue(SharedPreferenceConst.USER_EMAIL, phoneCont.text);
          setValue(SharedPreferenceConst.USER_PASSWORD, passwordCont.text);
        }
        onLoginSuccessRedirection();
      }).catchError((e) {
        appStore.setLoading(false);
        toast(e.toString(), print: true);
      });
    }).catchError((e) {
      log(e);
      toast(e.toString(), print: true);
      appStore.setLoading(false);
    });
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    return AppScaffold(
      showAppBar: false,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: screenHeight * 0.1),
                  Center(
                    child: Image.asset(
                      logo, // Replace with your l ogo asset path
                      height: screenHeight * 0.2,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  Container(
                    height: 43,
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      shadows: [
                        BoxShadow(
                          color: Color(0x3F000000),
                          blurRadius: 4,
                          offset: Offset(0, 4),
                          spreadRadius: 0,
                        )
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                isLogin = true;
                              });
                            },
                            child: Container(
                              height: 43,
                              decoration: BoxDecoration(
                                boxShadow: isLogin
                                    ? [
                                        BoxShadow(
                                          color: Color(0x80FFFFFF),
                                          // Semi-transparent white (#FFFFFF80)
                                          offset: Offset(0, 2.19),
                                          // X: 0px, Y: 2.19px
                                          blurRadius: 1.1,
                                          // Blur radius
                                          spreadRadius: 0, // Spread radius
                                        ),
                                        // Second inset shadow (black)
                                        BoxShadow(
                                          color: Color(0x80000000),
                                          // Semi-transparent black (#00000080)
                                          offset: Offset(0, -2.19),
                                          // X: 0px, Y: -2.19px
                                          blurRadius: 1.1,
                                          // Blur radius
                                          spreadRadius: 0, // Spread radius
                                        ),
                                      ]
                                    : [],
                                gradient: isLogin
                                    ? LinearGradient(
                                        colors: [
                                          Color(0xFFB0BEC5),
                                          // Start color (light grey, replace as needed)
                                          Color(0xFF546E7A),
                                          // End color (dark grey, replace as needed)
                                        ],
                                        begin: Alignment
                                            .centerRight, // Gradient starts from top
                                        end: Alignment
                                            .centerLeft, // Gradient ends at bottom
                                      )
                                    : null,
                                borderRadius: BorderRadius.circular(35),
                              ),
                              child: Center(
                                child: Text(
                                  locale.signIn,
                                  style: TextStyle(
                                    color:
                                        isLogin ? Colors.white : Colors.black,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                isLogin = false;
                              });
                            },
                            child: Container(
                              height: 43,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(35),
                                boxShadow: !isLogin
                                    ? [
                                        BoxShadow(
                                          color: Color(0x80FFFFFF),
                                          // Semi-transparent white (#FFFFFF80)
                                          offset: Offset(0, 2.19),
                                          // X: 0px, Y: 2.19px
                                          blurRadius: 1.1,
                                          // Blur radius
                                          spreadRadius: 0, // Spread radius
                                        ),
                                        // Second inset shadow (black)
                                        BoxShadow(
                                          color: Color(0x80000000),
                                          // Semi-transparent black (#00000080)
                                          offset: Offset(0, -2.19),
                                          // X: 0px, Y: -2.19px
                                          blurRadius: 1.1,
                                          // Blur radius
                                          spreadRadius: 0, // Spread radius
                                        ),
                                      ]
                                    : [],
                                gradient: !isLogin
                                    ? LinearGradient(
                                        colors: [
                                          Color(0xFFB0BEC5),
                                          // Start color (light grey, replace as needed)
                                          Color(0xFF546E7A),
                                          // End color (dark grey, replace as needed)
                                        ],
                                        begin: Alignment
                                            .centerRight, // Gradient starts from top
                                        end: Alignment
                                            .centerLeft, // Gradient ends at bottom
                                      )
                                    : null,
                              ),
                              child: Center(
                                child: Text(
                                  locale.signUp,
                                  style: TextStyle(
                                      color: !isLogin
                                          ? Colors.white
                                          : Colors.black,
                                      fontSize: 20),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.04),
                  if (isLogin) ...[
                    Form(
                      key: signInFormKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                          SizedBox(height: screenHeight * 0.03),
                          _buildTextField(
                            controller: passwordCont,
                            hintText: locale.password,
                            isPassword: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return locale.passwordIsEmpty;
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    // SizedBox(height: screenHeight * 0.02),
                    // Text(
                    //   'هل نسيت كلمة السر؟',
                    //   style: TextStyle(
                    //     color: Colors.white,
                    //     fontSize: 14,
                    //   ),
                    // ),
                  ],
                  if (!isLogin) ...[
                    Form(
                      key: signUpFormKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTextField(
                              controller: signUpFirstNameCont,
                              hintText: locale.firstName,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return locale.firstNameIsEmpty;
                                }
                                return null;
                              }),
                          SizedBox(height: screenHeight * 0.03),
                          _buildTextField(
                              controller: signUpLastNameCont,
                              hintText: locale.lastName,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return locale.lastNameIsEmpty;
                                }
                                return null;
                              }),
                          SizedBox(height: screenHeight * 0.03),
                          _buildPhoneField(
                              controller: signUpMobileCont,
                              hintText: locale.phoneNumber,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return locale.phoneIsEmpty;
                                }
                                return null;
                              }),
                          // IntlPhoneField(
                          //   decoration: InputDecoration(
                          //     labelText: locale.contactNumber,
                          //     border: OutlineInputBorder(
                          //       borderSide: BorderSide(),
                          //     ),
                          //   ),
                          //   initialCountryCode: 'IN',
                          //   onChanged: (phone) {
                          //     print(phone.completeNumber);
                          //     signUpMobileCont.text = phone.completeNumber;
                          //   },
                          // ),
                          SizedBox(height: screenHeight * 0.03),
                          _buildTextField(
                            controller: signUpPasswordCont,
                            hintText: locale.password,
                            validator: (value) {
                              if (value == null || value == 'null') {
                                return locale.passwordIsEmpty;
                              }
                              return null;
                            },
                            isPassword: true,
                          ),
                          SizedBox(height: screenHeight * 0.03),
                          _buildTextField(
                            validator: (value) {
                              if (value != signUpPasswordCont.text) {
                                return locale.thePasswordDoesNotMatch;
                              }
                              return null;
                            },
                            hintText: locale.confirmPassword,
                            isPassword: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                  SizedBox(height: screenHeight * 0.04),
                  GestureDetector(
                    onTap: () {
                      if (isLogin) {
                        onSignIn();
                      } else {
                        if (signUpFormKey.currentState!.validate()) {
                          // OtpLoginAuthService().loginWithOTP(context,
                          //     countryCode: "+962",
                          //     phoneNumber: signUpMobileCont.text,
                          //     password: signUpPasswordCont.text,
                          //     firstName: signUpFirstNameCont.text,
                          //     lastName: signUpLastNameCont.text);
                          registerUser();
                        }
                      }
                    },
                    child: Container(
                      height: 55,
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(35)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isLogin ? locale.signIn : locale.signUp,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(
                            width: 15,
                          ),
                          Image.asset("assets/icons/login_icon.png",
                              width: 37, height: 36, color: Colors.white)
                        ],
                      ),
                    ),
                  ),
                  if (isLogin) ...[
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      height: 55,
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(35)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            locale.reserveByPhone,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(
                            width: 15,
                          ),
                          Image.asset("assets/icons/call_icon.png",
                              width: 37, height: 36, color: Colors.white)
                        ],
                      ),
                    ),
                    10.height,
                    TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ForgotPasswordScreen(),
                              ));
                        },
                        child: Text(
                          locale.forgotPassword,
                          style: TextStyle(color: Colors.red, fontSize: 18),
                        ))
                  ],
                  SizedBox(height: screenHeight * 0.03),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildTextField(
    {required String hintText,
    bool isPassword = false,
    TextEditingController? controller,
    String? Function(String?)? validator}) {
  bool showpass = isPassword;
  return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$hintText",
          style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.w500, color: Colors.white),
        ),
        TextFormField(
          controller: controller,
          obscureText: showpass,
          validator: validator,
          decoration: InputDecoration(
            filled: true,
            isDense: true,
            fillColor: Colors.white,
            suffixIcon: isPassword
                ? GestureDetector(
                    onTap: () {
                      setState(() => showpass = !showpass);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Image.asset(
                        "assets/icons/lock.png",
                        width: 33,
                        height: 33,
                      ),
                    ),
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(35),
              borderSide: BorderSide.none,
            ),
          ),
          style: TextStyle(color: Colors.black),
        ),
      ],
    );
  });
}

Widget _buildPhoneField(
    {required String hintText,
    bool isPassword = false,
    TextEditingController? controller,
    String? Function(String?)? validator}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        "$hintText",
        style: TextStyle(
            fontSize: 22, fontWeight: FontWeight.w500, color: Colors.white),
      ),
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
