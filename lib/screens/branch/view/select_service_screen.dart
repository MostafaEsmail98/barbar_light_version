import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frezka/components/app_scaffold.dart';
import 'package:frezka/screens/auth/view/sign_in_screen.dart';
import 'package:frezka/screens/branch/view/booking_complete_screen.dart';
import 'package:frezka/utils/colors.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/common_app_dialog.dart';
import '../../../components/empty_error_state_widget.dart';
import '../../../components/loader_widget.dart';
import '../../../main.dart';
import '../../../paymentGateways/payment_repo.dart';
import '../../../utils/common_base.dart';
import '../../../utils/constants.dart';
import '../../../utils/model_keys.dart';
import '../../booking/booking_repository.dart';
import '../../coupons/component/coupon_bottom_sheet_component.dart';
import '../../dashboard/view/dashboard_screen.dart';
import '../../services/component/services_info_list_component.dart';
import '../../services/models/service_response.dart';
import '../../services/service_repository.dart';

class SelectServiceScreen extends StatefulWidget {
  final int BranchId;
  final int employeeId;
  final employeeName;
  final employeePhone;

  const SelectServiceScreen(
      {super.key,
      required this.BranchId,
      required this.employeeId,
      this.employeeName,
      required this.employeePhone});

  @override
  State<SelectServiceScreen> createState() => _SelectServiceScreenState();
}

class _SelectServiceScreenState extends State<SelectServiceScreen> {
  List<ServiceListData> selectedService = [];
  Future<List<ServiceListData>>? futureService;
  double totalPrice = 0;
  String AllselectedServiceString = '';
  int page = 1;
  bool ShowPayment = true;
  String paymentMethod = locale.cash;
  String paymentMethodval = 'cash';

  void init() async {
    fetchAllServiceData();
  }

  bool isLastPage = false;

  String convertTo24HourFormat(String time12h) {
    try {
      // التأكد من أن AM / PM مكتوبة بشكل صحيح
      String formattedInput = time12h.trim().toUpperCase();

      // تحديد التنسيق المناسب بناءً على وجود دقائق
      DateFormat inputFormat;
      if (formattedInput.contains(":")) {
        inputFormat = DateFormat('h:mma'); // مثل 2:30 PM
      } else {
        inputFormat = DateFormat('ha'); // مثل 2 PM
      }

      // تحويل الوقت إلى كائن DateTime
      DateTime parsedTime = inputFormat.parse(formattedInput);

      // إخراج النتيجة بصيغة HH:mm:ss
      return DateFormat('HH:mm:ss').format(parsedTime);
    } catch (e) {
      // في حال حدوث خطأ في التحويل
      return 'Invalid time format';
    }
  }

  void fetchAllServiceData({bool flag = false, bool isClear = false}) async {
    if (isClear) {
      selectedService.clear();
      bookingRequestStore.setSelectedServiceListInRequest(selectedService);
    }

    futureService = getServiceList(
      branchId: widget.BranchId,
      categoryId: "",
      page: page,
      search: "",
      list: [],
      lastPageCallBack: (p0) {
        isLastPage = p0;
      },
    ).then(
      (value) {
        if (flag) setState(() {});
        return value;
      },
    );
  }

  @override
  void dispose() {
    selectedService.clear();
    bookingRequestStore.setSelectedServiceListInRequest(selectedService);
    bookingRequestStore.packageFilterList.clear();
    super.dispose();
  }

  String tempDate = "";
  String tempTime = "";

  @override
  void initState() {
    init();
    tempDate = bookingRequestStore.date.validate();
    tempTime = bookingRequestStore.time.validate();
    print((tempDate));
    print(convertTo24HourFormat(tempTime));
    print("${widget.employeeId}++++++++++");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBarWidget: AppBar(
        elevation: 0,
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        centerTitle: true,
        title: Text(
          locale.reserve,
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            )),
      ),
      body: Column(
        children: [
          Container(
            height:
                ShowPayment ? context.height() * 0.6 : context.height() * 0.6,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      locale.services,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SnapHelperWidget<List<ServiceListData>>(
                    future: futureService,
                    loadingWidget: LoaderWidget(),
                    errorBuilder: (error) {
                      return NoDataWidget(
                        title: error,
                        retryText: locale.reload,
                        imageWidget: ErrorStateWidget(),
                        onRetry: () {
                          page = 1;
                          appStore.setLoading(true);
                          fetchAllServiceData(flag: true);
                        },
                      ).paddingTop(120).center();
                    },
                    onSuccess: (servicesInfoListData) {
                      return AnimatedListView(
                        itemCount: servicesInfoListData.length,
                        shrinkWrap: true,
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        physics: NeverScrollableScrollPhysics(),
                        emptyWidget: NoDataWidget(
                          title: locale.noServicesFound,
                          imageWidget: EmptyStateWidget(),
                        ),
                        itemBuilder: (context, index) {
                          ServiceListData serviceData =
                              servicesInfoListData[index];
                          serviceData.isServiceChecked = bookingRequestStore
                              .selectedServiceList
                              .any((element) =>
                                  element.id.validate() ==
                                  serviceData.id.validate());

                          return ServicesInfoListComponent(
                            serviceInfo: serviceData,
                            onPressed: () {
                              serviceData.isServiceChecked =
                                  !serviceData.isServiceChecked;

                              if (serviceData.isServiceChecked) {
                                selectedService.add(serviceData);
                              } else {
                                selectedService.removeWhere((element) =>
                                    element.id.validate() ==
                                    serviceData.id.validate());
                              }
                              bookingRequestStore
                                  .setSelectedServiceListInRequest(
                                      selectedService);
                              double total = 0;
                              String selectedServiceString = '';
                              selectedService.forEach((element) async {
                                selectedServiceString = selectedServiceString +
                                    element.name.toString() +
                                    ' , ';
                                total = total +
                                    double.parse(
                                        element!.defaultPrice.toString());
                              });

                              setState(() {
                                AllselectedServiceString =
                                    selectedServiceString;
                                totalPrice = total;
                              });
                            },
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: Colors.grey)),
            // height: MediaQuery.of(context).size.height / 8,
            width: context.width(),
            child: Container(
              margin: EdgeInsets.all(5),
              child: !ShowPayment
                  ? Container()
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * .5,
                              height: MediaQuery.of(context).size.height / 9,

                              // padding: EdgeInsets.symmetric(
                              //     horizontal: 16, vertical: 10),
                              child: Column(
                                children: [
                                  Text(
                                    locale.enterYourCode,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  AnimatedContainer(
                                    // width: double.infinity,
                                    width:
                                        MediaQuery.of(context).size.width / 2,
                                    height:
                                        MediaQuery.of(context).size.height / 18,
                                    // margin:
                                    //     EdgeInsets.symmetric(horizontal: 16),
                                    duration: Duration(seconds: 1),
                                    // padding: EdgeInsets.all(16),
                                    decoration: boxDecorationDefault(
                                        color: context.cardColor),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        bookingRequestStore.isCouponApplied
                                            ? Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  // Divider(height: 30),
                                                  Text(bookingRequestStore
                                                      .discountCouponCode
                                                      .toString())
                                                  // Row(
                                                  //   children: [
                                                  //     Stack(
                                                  //       children: [
                                                  //         DottedBorderWidget(
                                                  //           radius:
                                                  //               defaultRadius,
                                                  //           color:
                                                  //               secondaryColor,
                                                  //           child: Container(
                                                  //             padding: EdgeInsets
                                                  //                 .symmetric(
                                                  //                     vertical:
                                                  //                         6,
                                                  //                     horizontal:
                                                  //                         16),
                                                  //             decoration:
                                                  //                 boxDecorationWithRoundedCorners(
                                                  //               backgroundColor:
                                                  //                   Colors
                                                  //                       .transparent,
                                                  //             ),
                                                  //             child: Text(
                                                  //               bookingRequestStore
                                                  //                   .discountCouponCode
                                                  //                   .validate(),
                                                  //               style: boldTextStyle(
                                                  //                   color:
                                                  //                       secondaryColor),
                                                  //             ),
                                                  //           ),
                                                  //         ),
                                                  //         Positioned(
                                                  //           top: 4,
                                                  //           right: 8,
                                                  //           child: Container(
                                                  //             padding:
                                                  //                 EdgeInsets
                                                  //                     .all(2),
                                                  //             decoration:
                                                  //                 BoxDecoration(
                                                  //               color: Colors
                                                  //                   .black,
                                                  //               borderRadius:
                                                  //                   BorderRadius
                                                  //                       .circular(
                                                  //                           defaultRadius -
                                                  //                               4),
                                                  //             ),
                                                  //             child: Icon(
                                                  //               Icons.close,
                                                  //               color: context
                                                  //                   .scaffoldBackgroundColor,
                                                  //               size: 12,
                                                  //             ),
                                                  //           ).onTap(
                                                  //             () {
                                                  //               bookingRequestStore
                                                  //                   .setCouponApplied(
                                                  //                       false);
                                                  //               toast(
                                                  //                   locale
                                                  //                       .couponIsRemoved,
                                                  //                   print:
                                                  //                       true);
                                                  //               setState(() {});
                                                  //             },
                                                  //           ),
                                                  //         )
                                                  //       ],
                                                  //     ),
                                                  //     Text(
                                                  //       "${locale.youSaved} ${leftCurrencyFormat()}${bookingRequestStore.finalDiscountCouponAmount}${rightCurrencyFormat()}",
                                                  //       style: boldTextStyle(
                                                  //           color: greenColor,
                                                  //           size: 13),
                                                  //     ),
                                                  //   ],
                                                  // ),
                                                ],
                                              )
                                            : Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(locale.selectCoupon),
                                                ],
                                              )
                                      ],
                                    ),
                                  ).onTap(
                                    () {
                                      if (bookingRequestStore
                                          .selectedServiceList.isNotEmpty) {
                                        showModalBottomSheet(
                                          isScrollControlled: true,
                                          isDismissible: true,
                                          context: context,
                                          builder: (context) =>
                                              DraggableScrollableSheet(
                                            initialChildSize: 0.4,
                                            maxChildSize: 0.8,
                                            minChildSize: 0.3,
                                            expand: false,
                                            builder:
                                                (context, scrollController) {
                                              return CouponBottomSheetComponent(
                                                  scrollController:
                                                      scrollController);
                                            },
                                          ),
                                        ).then((value) => setState(() {}));
                                      } else {
                                        toast(locale.pleaseSelectService);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height: MediaQuery.of(context).size.height / 9,
                              width: MediaQuery.of(context).size.width * 0.4,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.4,
                                    height:
                                        MediaQuery.of(context).size.height / 22,
                                    alignment: Alignment.center,
                                    // padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                    child: Text(
                                      locale.paymentMethod,
                                      style: TextStyle(
                                        overflow: TextOverflow.ellipsis,
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  AnimatedContainer(
                                    width:
                                        MediaQuery.of(context).size.width / 2.7,
                                    height:
                                        MediaQuery.of(context).size.height / 18,
                                    duration: Duration(seconds: 1),
                                    // padding: EdgeInsets.all(16),
                                    decoration: boxDecorationDefault(
                                        color: context.cardColor),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(paymentMethod
                                            .capitalizeFirstLetter())
                                      ],
                                    ),
                                  ).onTap(
                                    () {
                                      var icons = [
                                        Icons.monetization_on,
                                        Icons.wrap_text_outlined,
                                        Icons.view_comfortable_outlined,
                                      ];
                                      if (bookingRequestStore
                                          .selectedServiceList.isNotEmpty) {
                                        showModalBottomSheet(
                                          isScrollControlled: true,
                                          isDismissible: true,
                                          context: context,
                                          builder: (context) =>
                                              DraggableScrollableSheet(
                                            initialChildSize: .06 * 3,
                                            maxChildSize: 0.8,
                                            minChildSize: 0.1,
                                            expand: false,
                                            builder:
                                                (context, scrollController) {
                                              return AnimatedListView(
                                                itemCount: [
                                                  locale.cash,
                                                  locale.cliq,
                                                  locale.visa
                                                ].length,
                                                physics:
                                                    NeverScrollableScrollPhysics(),
                                                shrinkWrap: true,
                                                itemBuilder: (p0, index) {
                                                  return GestureDetector(
                                                    onTap: () async {
                                                      setState(() {
                                                        paymentMethod = [
                                                          locale.cash,
                                                          locale.cliq,
                                                          locale.visa
                                                        ][index];
                                                        paymentMethodval = [
                                                          'cash',
                                                          'cliq',
                                                          'visa',
                                                        ][index];
                                                      });
                                                      if (index == 1) {
                                                        await Clipboard.setData(
                                                            ClipboardData(
                                                                text: appStore
                                                                    .branchContactNumber));
                                                        toast(
                                                            'تم نسخ رقم كليك !');
                                                      }
                                                      Navigator.pop(context);
                                                    },
                                                    child: Container(
                                                      padding:
                                                          EdgeInsets.all(5),
                                                      alignment:
                                                          Alignment.center,
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceEvenly,
                                                        children: [
                                                          Icon([
                                                            Icons
                                                                .monetization_on,
                                                            Icons
                                                                .wrap_text_outlined,
                                                            Icons
                                                                .view_comfortable_outlined,
                                                          ][index]),
                                                          Text(
                                                            [
                                                              locale.cash,
                                                              locale.cliq,
                                                              locale.visa
                                                            ][index],
                                                            style: TextStyle(
                                                              color: const Color
                                                                  .fromARGB(
                                                                  255, 0, 0, 0),
                                                              fontSize: 20,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                          ),
                                        ).then((value) => setState(() {}));
                                      } else {
                                        toast(locale.pleaseSelectService);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'المجموع:',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                            ),
                            Text(
                              ' JD ' +
                                  (bookingRequestStore.isCouponApplied
                                          ? (bookingRequestStore
                                                      .couponDiscountPercentage /
                                                  100) *
                                              totalPrice
                                          : totalPrice)
                                      .toString(),
                              style:
                                  TextStyle(color: primaryColor, fontSize: 20),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            if (bookingRequestStore
                                .selectedServiceList.isNotEmpty) {
                              appStore.setLoading(true);
                              saveBooking();
                            } else {
                              toast(locale.pleaseSelectService);
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(20)),
                            child: Center(
                                child: Text(
                              locale.confirmReservation,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 25),
                            )),
                          ),
                        ),
                      ],
                    ),
            ),
          )
        ],
      ),
    );
  }

  DateTime? initialDateTime;

  void saveBooking() {
    if (!appStore.isLoggedIn) {
      toast(locale.signInToReserve);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => SignInScreen()));
      return;
    }
    print('appStore');
    print(appStore);
    appStore.branchId = widget.BranchId;

    print(bookingRequestStore.toJson(employeeId: widget.employeeId));

    appStore.setLoading(true);
    String dateString = tempDate + " " + convertTo24HourFormat(tempTime);

    try {
      initialDateTime = DateTime.parse(dateString);
      bookingRequestStore.employeeName = widget.employeeName ?? '';
      bookingRequestStore.employeeId = widget.employeeId;
      bookingRequestStore.selectedServiceList
          .validate()
          .forEachIndexed((element, index) {
        if (index == 0) {
          element.startDateTime = formatDate(initialDateTime.toString(),
              format: DateFormatConst.NEW_FORMAT);
          element.previousTime = initialDateTime;
        } else {
          ServiceListData previousData =
              bookingRequestStore.selectedServiceList.validate()[index - 1];
          element.startDateTime = formatDate(
              previousData.previousTime!
                  .add(previousData.durationMin.minutes)
                  .toString(),
              format: DateFormatConst.NEW_FORMAT);
          element.previousTime =
              previousData.previousTime!.add(previousData.durationMin.minutes);
        }
      });
      // bookingRequestStore.setNoteInRequest(noteController.text);
    } catch (e) {
      appStore.setLoading(false);
      return toast(e.toString());
    }

    /// Save Booking API
    saveBookingAPI(bookingRequestStore.toJson(
      employeeId: widget.employeeId,
      paymentMethodval: paymentMethodval,
      dateTime: formatDate(initialDateTime.toString(),
          format: DateFormatConst.NEW_FORMAT),
    )).then((value) async {
      appStore.setLoading(false);
      bookingRequestStore.setBookingIdInRequest(value[CommonKey.bookingId]);

      savePayment(
              bookingId: bookingRequestStore.bookingId.validate(),
              isPackageReclaim: bookingRequestStore.isPackageReclaim)
          .then((value) {
        finish(context);
        finish(context);
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BookingCompleteScreen(
                  EmployeePhone: widget.employeePhone,
                  totalPrice: totalPrice,
                  paymentMethod: paymentMethod,
                  data: bookingRequestStore,
                  AllselectedServiceString: AllselectedServiceString),
            ));
        // showBookingCompleteDialog();
      }).catchError((e) {
        toast(e.toString());
      });
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });
  }

  Future<void> savePayment(
      {required int bookingId, bool isPackageReclaim = false}) async {
    await savePay(
      bookingId: bookingId,
      externalTransactionId: '',
      // transactionType: paymentMethodval,
      transactionType: PaymentMethods.PAYMENT_METHOD_CASH,
      discountPercentage: 0,
      discountAmount: 0,
      taxData: bookingRequestStore.taxPercentage.validate(),

      /// if package is reclaimed then set the payment is paid
      paymentStatus: isPackageReclaim ? SERVICE_PAYMENT_STATUS_PAID : '0',
    );
  }

  void showBookingCompleteDialog() {
    showDialog(
      context: context,
      useSafeArea: false,
      builder: (BuildContext context) => CommonAppDialog(
        title: '${locale.bookingSuccessful}',
        subTitle:
            '${locale.yourBookingFor} ${bookingRequestStore.isPackagePurchase ? bookingRequestStore.selectedPackageList.map((e) => e.name.validate()).toList().join(', ') : bookingRequestStore.selectedServiceList.validate().map((e) => e.name.validate()).toList().join(', ')} has been successfully booked',
        buttonText: locale.goToBookings,
        onTap: () {
          finish(context);
          DashboardScreen(pageIndex: 0).launch(context, isNewTask: true);
        },
      ),
    );
  }
}
