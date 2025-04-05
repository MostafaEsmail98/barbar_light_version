import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frezka/components/app_scaffold.dart';
import 'package:frezka/screens/branch/view/booking_complete_screen.dart';
import 'package:frezka/screens/dashboard/fragment/notification_fragment.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../components/cached_image_widget.dart';
import '../../../components/empty_error_state_widget.dart';
import '../../../main.dart';
import '../../branch/branch_repository.dart';
import '../../branch/model/branch_response.dart';
import '../../branch/view/branch_detail_screen.dart';
import '../../coupons/component/coupon_card_component.dart';
import '../../coupons/coupon_repository.dart';
import '../../coupons/model/coupon_list_model.dart';
import 'package:frezka/components/common_app_dialog.dart';

class HomeFragment extends StatefulWidget {
  @override
  _HomeFragmentState createState() => _HomeFragmentState();
}

class _HomeFragmentState extends State<HomeFragment> {
  UniqueKey keyForBranchList = UniqueKey();
  Future<List<BranchData>>? future;
  Future<List<CouponListData>>? couponFuture;
  List<CouponListData> couponList = [];

  Future<List<CouponListData>> getCouponList() async {
    appStore.setLoading(true);
    await getCouponListData().then((value) {
      if (value.couponListData != null) {
        couponList = value.couponListData!;
      }

      appStore.setLoading(false);
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });
    return couponList;
  }

  List<BranchData> branchList = [];
  int page = 1;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    couponFuture = getCouponList();
    future = getBranchList(page: page, branchList: branchList);
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBarWidget: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle(statusBarColor: Colors.black),
        backgroundColor: Colors.black,
        actions: [
          FaIcon(
            FontAwesomeIcons.search,
            color: Colors.white,
          ),
          SizedBox(
            width: 10,
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NotificationFragment(),
                  ));
            },
            child: FaIcon(
              FontAwesomeIcons.solidBell,
              color: Colors.white,
            ),
          ),
          SizedBox(
            width: 10,
          ),
        ],
        title: Row(
          children: [
            Observer(builder: (context) {
              String firstName = userStore.userFirstName.trim();
              String lastName = userStore.userLastName.trim();
              String displayName = lastName.isNotEmpty && lastName != "Unknown"
                  ? '$firstName $lastName'
                  : firstName;
              return Text("${locale.welcome} ${displayName}",
                      style: boldTextStyle(size: 18, color: Colors.white))
                  .center();
            }),
            SizedBox(
              width: 6,
            ),
            FaIcon(
              FontAwesomeIcons.hand,
              color: Colors.white,
            )
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              locale.availableCoupons,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 30),
            ),
            // Coupons Section
            SnapHelperWidget<List<CouponListData>>(
              future: couponFuture,
              loadingWidget: Offstage(),
              useConnectionStateForLoader: false,
              errorBuilder: (error) {
                return NoDataWidget(
                  title: error,
                  retryText: locale.reload,
                  imageWidget: ErrorStateWidget(),
                  onRetry: () {
                    init();
                  },
                );
              },
              onSuccess: (couponList) {
                if (couponList.isEmpty) {
                  return NoDataWidget(
                    title: '${locale.opps}! ${locale.noCouponLeftIn}',
                    imageWidget: EmptyStateWidget(),
                    onRetry: () async {
                      init();
                    },
                  ).paddingSymmetric(horizontal: 32).center();
                }
                return CarouselSlider(
                  options: CarouselOptions(
                      height: 130.0, autoPlay: true, viewportFraction: 1),
                  items: couponList.map((e) {
                    return Builder(
                      builder: (BuildContext context) {
                        return CouponCardComponent(
                          couponCode: e.couponCode,
                          couponDiscount: e.discountPercentage.toString(),
                          couponImage: e.couponImage,
                          couponTitle: e.name,
                          expiryDate: e.endDateTime,
                          isFixDiscount: e.discountType == "fixed",
                          discountAmount: e.discountAmount.toString(),
                        ).onTap(() {
                          //
                        });
                      },
                    );
                  }).toList(),
                );
              },
            ),

            SizedBox(
              height: 5,
            ),
            // Our Branches Section
            Text(
              locale.ourBranches,
              style: TextStyle(
                fontSize: 25,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),

            FutureBuilder<List<BranchData>>(
                future: future,
                initialData: branchListCached,
                builder: (context, snap) {
                  if (snap.data.validate().isEmpty) return Offstage();
                  if (snap.hasData) {
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 5,
                        crossAxisSpacing: 2,
                        childAspectRatio: 0.6,
                      ),
                      itemCount: snap.data!.length,
                      itemBuilder: (context, index) {
                        return BranchCard(
                          branchData: snap.data![index],
                        );
                      },
                    );
                  }

                  return snapWidgetHelper(
                    snap,
                    loadingWidget: Offstage(),
                    errorBuilder: (error) {
                      return Offstage();
                    },
                  );
                }),
            SizedBox(
              height: 20,
            )
          ],
        ),
      ),
    );
  }
}

class BranchCard extends StatelessWidget {
  final BranchData branchData;
  const BranchCard({required this.branchData});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
              child: ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            child: CachedImageWidget(
              height: 100,
              url: branchData.branchImg.validate(),
              width: context.width(),
              fit: BoxFit.cover,
            ),
          )),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      locale.open,
                      style: TextStyle(color: Color(0xff61B77A), fontSize: 12),
                    ),
                    Text(
                      "${branchData.workingHourList?[0].startTime}-${branchData.workingHourList?[0].endTime}",
                      style: TextStyle(
                          color: Color(
                            0xffAFAFAF,
                          ),
                          fontSize: 8),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        branchData.name ?? "",
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Color(0xff6C6C6C),
                            fontSize: 17),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    RatingBar.builder(
                      initialRating: branchData.ratingStar?.toDouble() ?? 0,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      ignoreGestures: true,
                      itemPadding: EdgeInsets.zero,
                      itemSize: 12,
                      itemBuilder: (context, _) => Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 9,
                      ),
                      onRatingUpdate: (rating) {
                        print(rating);
                      },
                    )
                  ],
                ),
                Text(
                  branchData.addressLine1 ?? "",
                  style: TextStyle(color: Color(0xff6C6C6C), fontSize: 11),
                ),
                SizedBox(
                  height: 5,
                ),
                GestureDetector(
                  onTap: () {
                    BranchDetailScreen(branchId: branchData.id.validate())
                        .launch(context);
                  },
                  child: Container(
                    height: 30,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Color(0xFFDEB054),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Center(
                        child: Text(
                      locale.reserve,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    )),
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                InkWell(
                  onTap: () {
                    // showDialog(
                    //   context: context,
                    //   useSafeArea: false,
                    //   builder: (BuildContext context) => CommonAppDialog(
                    //     title: '${locale.bookingSuccessful}',
                    //     subTitle: ' has been successfully booked',
                    //     buttonText: locale.goToBookings,
                    //     onTap: () {
                    //       finish(context);
                    //     },
                    //   ),
                    // );
                    // Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //       builder: (context) => BookingCompleteScreen(),
                    //     ));
                    // return;
                    var googleMapUrl =
                        "https://www.google.com/maps/search/?api=1&query=${branchData.latitude},${branchData.longitude}";
                    launchUrlString(googleMapUrl);
                  },
                  child: Container(
                    height: 30,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Color(0xff818181),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Center(
                        child: Text(
                      locale.showLocationOnMap,
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    )),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
