import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:frezka/components/cached_image_widget.dart';
import 'package:frezka/screens/branch/view/branch_times_screen.dart';
import 'package:frezka/screens/review/component/review_item_component.dart';
import 'package:frezka/utils/extensions/string_extensions.dart';
import 'package:frezka/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:photo_view/photo_view.dart';


import '../../../components/app_scaffold.dart';
import '../../../components/default_user_image_placeholder.dart';
import '../../../components/empty_error_state_widget.dart';
import '../../../components/loader_widget.dart';
import '../../../main.dart';
import '../../../utils/colors.dart';
import '../employee_repository.dart';
import '../model/employee_detail_response.dart';
import '../shimmer/employee_detail_shimmer.dart';

class EmployeeDetailScreen extends StatefulWidget {
  final int employeeId;
  final int? branchId;
  final String? address;

  EmployeeDetailScreen({required this.employeeId, this.branchId, this.address});

  @override
  _EmployeeDetailScreenState createState() => _EmployeeDetailScreenState();
}

class _EmployeeDetailScreenState extends State<EmployeeDetailScreen> {
  Future<EmployeeDetailResponse>? future;

  List<String> icons = [ic_facebook, ic_instagram, ic_twitter, ic_dribble];
  bool isFirstTab = true;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    future = getEmployeeDetail(
        branchId: widget.branchId ?? appStore.branchId,
        employeeId: widget.employeeId,
        context: context);
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      showAppBar: false,
      body: SafeArea(
        child: Stack(
          children: [
            SnapHelperWidget<EmployeeDetailResponse>(
              future: future,
              initialData: employeeDetailCachedData
                  .firstWhere(
                      (element) => element?.$1 == widget.employeeId.validate(),
                      orElse: () => null)
                  ?.$2,
              loadingWidget: EmployeeDetailShimmer(),
              onSuccess: (snap) {
                EmployeeData employeeData = snap.data!;

                return Column(
                  children: [
                    Expanded(
                      child: AnimatedScrollView(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        listAnimationType: ListAnimationType.FadeIn,
                        children: [
                          /// Top UI
                          Container(
                            color: context.cardColor,
                            child: Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(20),
                                      bottomRight: Radius.circular(20)),
                                  child: AppBar(
                                    backgroundColor: Colors.black,
                                    automaticallyImplyLeading: true,
                                    leading: IconButton(
                                      icon: Icon(Icons.arrow_back_ios,
                                          color: Colors.white),
                                      onPressed: () {
                                        finish(context);
                                      },
                                    ),
                                    flexibleSpace: Container(
                                      decoration: BoxDecoration(
                                          color: Colors.black,
                                          borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(20),
                                            bottomRight: Radius.circular(20),
                                          )),
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              CachedImageWidget(
                                                url: employeeData.profileImage
                                                    .validate(),
                                                fit: BoxFit.cover,
                                                height: 150,
                                                width: 100,
                                                child:
                                                    DefaultUserImagePlaceholder(),
                                              ).paddingTop(16),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                      employeeData.fullName
                                                          .validate(),
                                                      style: boldTextStyle(
                                                          size: 30,
                                                          color: Colors.white)),
                                                  Row(
                                                    children: [
                                                      RatingBar.builder(
                                                        initialRating: employeeData
                                                                .ratingStar
                                                                ?.toDouble() ??
                                                            0,
                                                        minRating: 1,
                                                        direction:
                                                            Axis.horizontal,
                                                        allowHalfRating: true,
                                                        itemCount: 5,
                                                        ignoreGestures: true,
                                                        itemPadding:
                                                            EdgeInsets.zero,
                                                        itemSize: 20,
                                                        itemBuilder:
                                                            (context, _) =>
                                                                Icon(
                                                          Icons.star,
                                                          size: 20,
                                                          color: Colors.amber,
                                                        ),
                                                        onRatingUpdate:
                                                            (rating) {
                                                          print(rating);
                                                        },
                                                      ),
                                                      5.width,
                                                      if (employeeData
                                                              .totalReview
                                                              .validate() >=
                                                          1)
                                                        Text(
                                                          '${employeeData.totalReview.validate()}',
                                                          style:
                                                              secondaryTextStyle(
                                                                  size: 12,
                                                                  color: Colors
                                                                      .white),
                                                        )
                                                    ],
                                                  ),
                                                  TextIcon(
                                                    text: widget.address,
                                                    spacing: 5,
                                                    textStyle: primaryTextStyle(
                                                        color: Colors.white),
                                                    prefix:
                                                        ic_location.iconImage(
                                                            color: Colors.white,
                                                            size: 13),
                                                  ),
                                                ],
                                              ).paddingTop(25)
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Column(
                                  children: [
                                    SizedBox(
                                      height: 50,
                                      child: Row(
                                        children: [
                                          Expanded(
                                              child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                isFirstTab = true;
                                              });
                                            },
                                            child: Center(
                                              child: Text(
                                                locale.gallery,
                                                style: TextStyle(
                                                    color: isFirstTab
                                                        ? primaryColor
                                                        : Color(0xff848B8A),
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontSize: 22),
                                              ),
                                            ),
                                          )),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 5),
                                            child: VerticalDivider(
                                              thickness: 2,
                                            ),
                                          ),
                                          Expanded(
                                              child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                isFirstTab = false;
                                              });
                                            },
                                            child: Center(
                                              child: Text(
                                                locale.reviews,
                                                style: TextStyle(
                                                    color: !isFirstTab
                                                        ? primaryColor
                                                        : Color(0xff848B8A),
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontSize: 22),
                                              ),
                                            ),
                                          )),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          10.height,
                          Padding(
                            padding: EdgeInsets.all(16),
                            child: AnimatedScrollView(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (!isFirstTab) ...[
                                  if (employeeData.reviewData
                                      .validate()
                                      .isNotEmpty)
                                    AnimatedListView(
                                      itemCount: employeeData.reviewData!
                                          .take(10)
                                          .length,
                                      shrinkWrap: true,
                                      padding: EdgeInsets.zero,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemBuilder: (_, i) {
                                        return ReviewItemComponent(
                                            reviewData:
                                                employeeData.reviewData![i]);
                                      },
                                    )
                                  else
                                    NoDataWidget(
                                      subTitle:
                                          '${locale.noReviewsYetFor} ${employeeData.firstName}',
                                      imageWidget: EmptyStateWidget(),
                                    ),
                                ],
                                if (isFirstTab) ...[
                                  GridView.count(
                                    crossAxisCount: 3,
                                    mainAxisSpacing: 10,
                                    crossAxisSpacing: 5,
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    children: List.generate(
                                        employeeData.images!.length, (index) {
                                      return GestureDetector(
                                        onTap: () {
                                          showDialog(
                                              // Flutter method for showing popups
                                              context: context,
                                              builder: (context) => Container(
                                                    alignment: Alignment.center,
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height /
                                                            1.1,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width /
                                                            1.1,
                                                    child: Column(
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .end,
                                                          children: [
                                                            IconButton(
                                                                color:
                                                                    primaryColor,
                                                                onPressed: () =>
                                                                    Navigator.pop(
                                                                        context),
                                                                icon: Icon(
                                                                  Icons.close,
                                                                  color: Colors
                                                                      .white,
                                                                )),
                                                          ],
                                                        ),
                                                        Container(
                                                          alignment:
                                                              Alignment.center,
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height /
                                                              1.3,
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width /
                                                              1.1,
                                                          child: PhotoView(
                                                            imageProvider:
                                                                NetworkImage(
                                                              employeeData
                                                                  .images![
                                                                      index][
                                                                      'full_url']
                                                                  .toString(),
                                                              // height: MediaQuery
                                                              //             .of(
                                                              //                 context)
                                                              //         .size
                                                              //         .width /
                                                              //     1.1,
                                                              // width: MediaQuery.of(
                                                              //             context)
                                                              //         .size
                                                              //         .width /
                                                              //     1.1,
                                                              // fit: BoxFit
                                                              //     .contain
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ));
                                        },
                                        child: CachedImageWidget(
                                          url: employeeData.images![index]
                                              ['full_url'],
                                          fit: BoxFit.cover,
                                          height: 150,
                                          width: 100,
                                          radius: 15,
                                          child: DefaultUserImagePlaceholder(),
                                        ),
                                      );
                                    }),
                                  )
                                ]
                              ],
                            ),
                          ),
                        ],
                        onSwipeRefresh: () async {
                          init();
                          setState(() {});

                          return await 2.seconds.delay;
                        },
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        BranchTimesScreen(
                          BranchId: widget.branchId!,
                          employeeId: widget.employeeId,
                          employeeName: employeeData.fullName,
                        ).launch(context);
                      },
                      child: Container(
                        width: double.infinity,
                        margin: EdgeInsets.all(16),
                        padding: EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(20)),
                        child: Center(
                            child: Text(
                          locale.reserve,
                          style: TextStyle(color: Colors.white, fontSize: 25),
                        )),
                      ),
                    )
                  ],
                );
              },
              errorBuilder: (error) {
                return NoDataWidget(
                  title: error,
                  imageWidget: ErrorStateWidget(),
                  retryText: locale.reload,
                  onRetry: () {
                    appStore.setLoading(true);

                    init();
                    setState(() {});
                  },
                );
              },
            ),
            Observer(
                builder: (context) =>
                    LoaderWidget().visible(appStore.isLoading)),
          ],
        ),
      ),
    );
  }
}
