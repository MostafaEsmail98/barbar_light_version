import 'dart:ui' as flutter;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frezka/components/app_scaffold.dart';
import 'package:frezka/paymentGateways/services/paypal_service.dart';

import 'package:frezka/paymentGateways/services/stripe_service.dart';
import 'package:frezka/screens/experts/model/employee_detail_response.dart';

import 'package:frezka/utils/colors.dart';
import 'package:frezka/utils/images.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/loader_widget.dart';
import '../../../main.dart';
import '../../../paymentGateways/models/payment_list_model.dart';
import '../../../paymentGateways/services/flutter_wave_service.dart';
import '../../../paymentGateways/services/paystack_service.dart';
import '../../../paymentGateways/services/razor_pay_service.dart';

import '../../../store/booking_request_store.dart';
import '../../dashboard/view/dashboard_screen.dart';

class BookingCompleteScreen extends StatefulWidget {
  final bool isReschedule;
  final BookingRequestStore? data;
  final AllselectedServiceString;
  final paymentMethod;
  final EmployeePhone;
  final totalPrice;

  BookingCompleteScreen(
      {this.isReschedule = false,
      this.data ,
      this.paymentMethod = '',
      this.AllselectedServiceString = '', this.EmployeePhone, this.totalPrice});

  @override
  _BookingCompleteScreenState createState() => _BookingCompleteScreenState();
}

class _BookingCompleteScreenState extends State<BookingCompleteScreen> {
  bool _isPackageListEmpty = false;

  ScrollController scrollController = ScrollController();

  TextEditingController tipController = TextEditingController();
  TextEditingController noteController = TextEditingController();

  FocusNode tipFocusNode = FocusNode();
  FocusNode noteFocusNode = FocusNode();

  List<PaymentData> payments = getPaymentList();

  late PaymentData selectedPayment;

  RazorPayService razorPayService = RazorPayService();
  StripeService stripeServices = StripeService();
  PayStackService paystackServices = PayStackService();
  PayPalService payPalServices = PayPalService();
  FlutterWaveService flutterWaveServices = FlutterWaveService();

  String tempDate = '';
  String tempTime = '';

  DateTime? initialDateTime;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    tempDate = bookingRequestStore.date.validate();
    tempTime = bookingRequestStore.time.validate();
    selectedPayment = payments.first;
    bookingRequestStore.setCouponApplied(false);
  }

  void _handlePackageListEmpty() {
    setState(() {
      _isPackageListEmpty = true;
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBarWidget: AppBar(
        surfaceTintColor: Colors.white,

        automaticallyImplyLeading: true,
        leading: ElevatedButton(
          style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Colors.black)),
          onPressed: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => DashboardScreen()),
              (Route<dynamic> route) => false),
          child: Container(
            alignment: Alignment.center,
            child: FaIcon(
              FontAwesomeIcons.arrowRight,
              color: Colors.white,
            ),
          ),
        ),
        systemOverlayStyle: SystemUiOverlayStyle(statusBarColor: Colors.black),
        backgroundColor: Colors.black,
        // actions: [
        //   FaIcon(
        //     FontAwesomeIcons.search,
        //     color: Colors.white,
        //   ),
        //   SizedBox(
        //     width: 10,
        //   ),
        //   GestureDetector(
        //     onTap: () {
        //       Navigator.push(
        //           context,
        //           MaterialPageRoute(
        //             builder: (context) => NotificationFragment(),
        //           ));
        //     },
        //     child: FaIcon(
        //       FontAwesomeIcons.solidBell,
        //       color: Colors.white,
        //     ),
        //   ),
        //   SizedBox(
        //     width: 10,
        //   ),
        // ],

        title: Container(
          width: context.width(),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                width: 6,
              ),
              Text("التذكرة",
                  style: boldTextStyle(size: 18, color: Colors.white))
            ],
          ),
        ),
      ),
      body: Container(
        // height: context.height(),
        child: SingleChildScrollView(
          controller: scrollController,
          padding: EdgeInsets.only(left: 20, right: 20, top: 1, bottom: 20),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage(bookingBill),
                        fit: BoxFit.fitHeight,
                        alignment: Alignment.topCenter)),
                width: context.width() / 1.1,
                height: MediaQuery.of(context).size.height * .8,
                child: Stack(
                  //  decoration: BoxDecoration(
                  //   image: DecorationImage(image: AssetImage(background),fit: BoxFit.cover)
                  // ),
                  // fit: StackFit.expand,
                  children: [
                    Column(
                      children: [
                        16.height,
                        Container(
                          // color: Colors.white,
                          child: Column(
                            children: [
                              Container(
                                margin: EdgeInsets.only(
                                    top:
                                        MediaQuery.of(context).size.height / 5),
                                width: context.width() / 1.1,
                                padding: EdgeInsets.all(30),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(18),
                                  // color: Colors.white,
                                ),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'الرقم التسلسلي',
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                                widget.data!.bookingId
                                                    .toString(),
                                                style: TextStyle(
                                                    color: Colors.grey))
                                          ]),
                                      Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'رقم الهاتف',
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Directionality(
                                              textDirection: flutter.TextDirection.ltr,
                                              child: Text(widget.EmployeePhone.toString(),
                                                  style: TextStyle(
                                                      color: Colors.grey)),
                                            )
                                          ]),
                                      Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'اسم الحلاق',
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                                widget.data!.employeeName
                                                    .toString(),
                                                style: TextStyle(
                                                    color: Colors.grey))
                                          ]),
                                      Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'اسم الصالون',
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                                appStore.branchAddress
                                                        .toString() +
                                                    ' - ' +
                                                    appStore.branchName,
                                                style: TextStyle(
                                                    color: Colors.grey))
                                          ]),
                                      Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'الباقة المختارة',
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                                widget.AllselectedServiceString
                                                        .toString()
                                                    .substring(
                                                        0,
                                                        widget.AllselectedServiceString
                                                                    .toString()
                                                                .length -
                                                            2),
                                                style: TextStyle(
                                                    color: Colors.grey))
                                          ]),
                                      FittedBox(
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'المبلغ الكلي وطريقة الدفع',
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold),
                                              ),
                                              Text(
                                                  widget.paymentMethod
                                                          .toString() +
                                                      '  دينار -  ' +
                                                      (widget.totalPrice.toString()),
                                                  style: TextStyle(
                                                      color: Colors.grey))
                                            ]),
                                      ),
                                      Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'التاريخ والوقت',
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                                "${widget.data?.date} - ${widget.data?.time}",
                                                style: TextStyle(
                                                    color: Colors.grey))
                                          ]),
                                      // Column(
                                      //     crossAxisAlignment: CrossAxisAlignment.start,
                                      //     children: [
                                      //       Text(
                                      //         'ترتيبك بين العملاء',
                                      //         style: TextStyle(
                                      //             color: Colors.black,
                                      //             fontWeight: FontWeight.bold),
                                      //       ),
                                      //       Text('5',
                                      //           style: TextStyle(color: Colors.grey))
                                      //     ]),
                                    ]),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 25,
                        ),
                      ],
                    ),
                    Positioned(
                      top: 5,
                      child: Container(
                        width: context.width() / 1.1,
                        // height: MediaQuery.of(context).size.height / 2,
                        height: MediaQuery.of(context).size.height / 5,
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          // color: Colors.white,
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset(ic_confirm_check,
                                  height: 100, width: 100, color: primaryColor),
                              5.height,
                              Text(locale.yourBookingForHairBookingMessage,
                                  style: boldTextStyle(size: 20),
                                  textAlign: TextAlign.center),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Observer(
                        builder: (context) =>
                            LoaderWidget().visible(appStore.isLoading)),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 15),
                height: context.height() / 14,
                width: context.width() / 1.2,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: Colors.white,
                ),
                alignment: Alignment.center,
                child: Text('سيتم إرسال لك رسالة نصية و إشعار قبل موعدك بساعة'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
