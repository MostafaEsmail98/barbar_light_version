import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frezka/components/app_scaffold.dart';
import 'package:frezka/models/review_data.dart';
import 'package:frezka/screens/booking/component/booking_information_component.dart';
import 'package:frezka/screens/booking/component/location_information_component.dart';
import 'package:frezka/screens/booking/component/payment_information_component.dart';
import 'package:frezka/utils/app_common.dart';
import 'package:frezka/utils/colors.dart';
import 'package:frezka/utils/common_base.dart';
import 'package:frezka/utils/constants.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/add_review_dialog.dart';
import '../../../components/empty_error_state_widget.dart';
import '../../../components/loader_widget.dart';
import '../../../main.dart';
import '../../review/view/review_all_screen.dart';
import '../booking_repository.dart';
import '../component/booking_packages_component.dart';
import '../component/booking_service_information_component.dart';
import '../model/booking_detail_response.dart';
import '../shimmer/booking_detail_shimmer.dart';

late VoidCallback onBookingDetailUpdate;

class BookingDetailScreen extends StatefulWidget {
  final int bookingId;
  final String? bookingStatus;

  BookingDetailScreen({required this.bookingId, this.bookingStatus});

  @override
  _BookingDetailScreenState createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  Future<BookingDetailResponse>? future;

  @override
  void initState() {
    super.initState();
    init();

    onBookingDetailUpdate = () {
      init(flag: true);
    };
  }

  void init({bool flag = false}) async {
    /// Booking Detail API
    future = getBookingDetail(bookingId: widget.bookingId.validate());
    bookingRequestStore.setCouponApplied(false);
    if (flag) setState(() {});
  }

  BookingDetailResponse? getInitialData() {
    if (bookingDetailCached.any((element) => element.id == widget.bookingId)) {
      return BookingDetailResponse(
          data: bookingDetailCached
              .firstWhere((element) => element.id == widget.bookingId));
    } else {
      return null;
    }
  }

  Future<void> getInvoice(String? id) async {
    appStore.setLoading(true);
    await getInvoiceLink(bookingId: id.validate()).then((value) {
      appStore.setLoading(false);
      viewFiles(value.link.validate());
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBarWidget: commonAppBarWidget(
        context,
        title: '#${widget.bookingId}',
        appBarHeight: 70,
        roundCornerShape: true,
        showLeadingIcon: Navigator.canPop(context),
      ),
      body: Stack(
        children: [
          SnapHelperWidget<BookingDetailResponse>(
            future: future,
            initialData: getInitialData(),
            loadingWidget: BookingDetailShimmer(),
            errorBuilder: (error) {
              return NoDataWidget(
                title: error,
                retryText: locale.reload,
                imageWidget: ErrorStateWidget(),
                onRetry: () {
                  appStore.setLoading(true);

                  init();
                  setState(() {});
                },
              );
            },
            onSuccess: (snap) {
              if (snap.data == null) {
                return NoDataWidget(
                  title: locale.noDetailsFound,
                  retryText: locale.reload,
                  onRetry: () {
                    appStore.setLoading(true);

                    init();
                    setState(() {});
                  },
                );
              }

              return AnimatedScrollView(
                padding: EdgeInsets.all(16),
                physics: AlwaysScrollableScrollPhysics(),
                children: [
                  LocationInformationComponent(booking: snap.data!),
                  16.height,
                  BookingInformationComponent(
                    booking: snap.data!,
                    bookingStatus: widget.bookingStatus,
                    serviceList: snap.data!.serviceList.validate(),
                  ),
                  24.height,
                  if (snap.data!.packages != null &&
                      snap.data!.packages!.isEmpty)
                    BookingServiceInformationComponent(
                      serviceList: snap.data!.serviceList.validate(),
                      productList: snap.data!.productsInfo,
                      bookingStatus: widget.bookingStatus,
                    ).paddingBottom(8),

                  //Booking Packages
                  if ((snap.data!.packages != null &&
                      snap.data!.packages!.isNotEmpty))
                    BookingPackagesComponent(
                      packagesList: snap.data!.packages.validate(),
                      bookingStatus: widget.bookingStatus,
                    ).paddingBottom(8),

                  if (snap.data != null)
                    PaymentInformationComponent(booking: snap.data!),
                  if (snap.data!.payment?.paymentStatus == 1 &&
                      snap.data!.status == BookingStatusConst.COMPLETED)
                    AppButton(
                      child: Text(locale.downloadInvoice,
                          style: boldTextStyle(color: Colors.white)),
                      color: context.primaryColor,
                      width: context.width(),
                      elevation: 0,
                      margin: EdgeInsets.only(top: 16),
                      onTap: () async {
                        await getInvoice(snap.data?.id.toString());
                      },
                    ).paddingBottom(40),
                  24.height,
                  InkWell(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: AddReviewDialog(
                            customerReview: ReviewData(id: snap.data!.id),
                            staffId: snap.data!.employeeId,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      height: 60,
                      decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(12)),
                      child: Center(
                          child: Text(
                        locale.rate,
                        style: boldTextStyle(size: LABEL_TEXT_SIZE)
                            .copyWith(color: Colors.white),
                      )),
                    ),
                  )
                ],
                onSwipeRefresh: () async {
                  init();
                  setState(() {});
                  return await 2.seconds.delay;
                },
              );
            },
          ),
          Observer(
              builder: (context) => LoaderWidget().visible(appStore.isLoading)),
        ],
      ),
    );
  }
}
