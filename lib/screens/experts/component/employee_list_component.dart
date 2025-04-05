import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frezka/components/cached_image_widget.dart';
import 'package:frezka/screens/booking/component/quick_book_component.dart';
import 'package:frezka/screens/branch/view/branch_times_screen.dart';
import 'package:frezka/utils/common_base.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../components/default_user_image_placeholder.dart';
import '../../../main.dart';
import '../../experts/model/employee_detail_response.dart';

class EmployeeListComponent extends StatefulWidget {
  final EmployeeData expertData;
  final double? width;
  final Decoration? decoration;
  final Color? expertNameTextColor;
  final VoidCallback? onTap;
  final branchId;
  EmployeeListComponent(
      {required this.expertData,
      this.width,
      this.decoration,
      this.expertNameTextColor,
      this.onTap,
      this.branchId});

  @override
  State<EmployeeListComponent> createState() => _EmployeeListComponentState();
}

class _EmployeeListComponentState extends State<EmployeeListComponent> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      padding: EdgeInsetsDirectional.only(start: 10, end: 5, top: 16),
      decoration: widget.decoration ??
          boxDecorationWithRoundedCorners(backgroundColor: context.cardColor),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              SizedBox(
                height: 90,
                width: 70,
                // child: SvgPicture.asset("assets/icons/shield.svg")
              ),
              PositionedDirectional(
                // start: 10,
                // end: 10,
                // bottom: 10,
                // top: -10,
                child: CachedImageWidget(
                  url: widget.expertData.profileImage.validate(),
                  height: 90,
                  width: 70,
                  fit: BoxFit.contain,
                  child: DefaultUserImagePlaceholder(),
                ),
              ),
            ],
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.expertData.fullName.validate(),
                      style: boldTextStyle(color: Color(0xff4D4D4D)),
                      textAlign: TextAlign.center),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Text(
                      //     "${calculateAgeFromString(widget.expertData.dateOfBirth.validate())} ${locale.year} , ${locale.expert} ${widget.expertData.expert.validate(value: "0")} ${locale.years} ",
                      //     style:
                      //         TextStyle(color: Color(0xff4D4D4D), fontSize: 9)),
                      Text(
                        locale.available,
                        style:
                            TextStyle(color: Color(0xff61B77A), fontSize: 12),
                      ),
                    ],
                  ),
                  RatingBar.builder(
                    initialRating:
                        widget.expertData.ratingStar?.toDouble() ?? 0,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    ignoreGestures: true,
                    itemPadding: EdgeInsets.zero,
                    itemSize: 20,
                    itemBuilder: (context, _) => Icon(
                      Icons.star,
                      size: 20,
                      color: Colors.amber,
                    ),
                    onRatingUpdate: (rating) {
                      print(rating);
                    },
                  ),
                  Text(
                    widget.expertData.aboutSelf ?? "",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: 5,
          ),
          Column(
            children: [
              GestureDetector(
                onTap: () {
                  widget.onTap?.call();
                },
                child: Container(
                  height: 30,
                  width: MediaQuery.of(context).size.width / 3,
                  decoration: BoxDecoration(
                    color: Color(0xff818181),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Center(
                      child: Text(
                    locale.showProfile,
                    style: TextStyle(color: Colors.white, fontSize: 11),
                  )),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              GestureDetector(
                onTap: () {
                  print({
                    'BranchId': widget.branchId,
                    'employeeId': widget.expertData.id,
                    'employeeName': widget.expertData.fullName
                  });
                  BranchTimesScreen(
                    BranchId: widget.branchId,
                    employeeId: widget.expertData.id!,
                    employeeName: widget.expertData.fullName,
                  ).launch(context);
                },
                child: Container(
                  height: 50,
                  width: 120,
                  decoration: BoxDecoration(
                    color: Color(0xFFDEB054),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Center(
                      child: Text(
                    locale.reserveNow,
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  )),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

int calculateAgeFromString(String dateString) {
  if (dateString == "") {
    return 0;
  }
  // Parse the date string into a DateTime object
  DateTime dateOfBirth = DateTime.parse(dateString);

  final DateTime today = DateTime.now();

  // Calculate the difference in years
  int age = today.year - dateOfBirth.year;

  // Adjust if the birthday hasn't occurred yet this year
  if (today.month < dateOfBirth.month ||
      (today.month == dateOfBirth.month && today.day < dateOfBirth.day)) {
    age--;
  }

  return age;
}
