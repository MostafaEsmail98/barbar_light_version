import 'package:flutter/material.dart';
import 'package:frezka/main.dart';
import 'package:frezka/screens/branch/model/branch_response.dart';
import 'package:frezka/utils/app_common.dart';
import 'package:frezka/utils/colors.dart';
import 'package:frezka/utils/extensions/string_extensions.dart';
import 'package:frezka/utils/extensions/text_icons.dart';
import 'package:frezka/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../components/status_widget.dart';
import '../../../utils/common_base.dart';

class BranchInformationComponent extends StatefulWidget {
  final BranchData branchData;

  BranchInformationComponent({required this.branchData});

  @override
  State<BranchInformationComponent> createState() => _BranchInformationComponentState();
}

class _BranchInformationComponentState extends State<BranchInformationComponent> {
  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    //
  }

  Widget shopInfoWidget({Color? color, String? title, String? icon, VoidCallback? callback}) {
    return Container(
      decoration: boxDecorationDefault(color: color ?? context.cardColor),
      alignment: Alignment.center,
      child: TextIcons(
        edgeInsets: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        expandedText: true,
        useMarquee: true,
        text: title.validate(),
        spacing: 8,
        textStyle: primaryTextStyle(color: secondaryColor, size: 14),
        prefix: icon.validate().iconImage(size: 16, color: secondaryColor),
        onTap: callback,
      ),
    );
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(widget.branchData.name.validate(), style: boldTextStyle(size: 40,color: Colors.white)),
            // if (widget.branchData.todayTime != null)
            //   StatusWidget(
            //     text: getBranchIsOpen(startTime: widget.branchData.todayTime!.startTime.validate(), endTime: widget.branchData.todayTime!.endTime.validate(), isHoliday: widget.branchData.todayTime!.isHoliday.validate().getBoolInt()).$1.validate(),
            //     color: getBranchIsOpen(startTime: widget.branchData.todayTime!.startTime.validate(), endTime: widget.branchData.todayTime!.endTime.validate(), isHoliday: widget.branchData.todayTime!.isHoliday.validate().getBoolInt()).$2,
            //   ),
          ],
        ),
        if (widget.branchData.addressLine1.validate().isNotEmpty)
          Row(

            children: [
              TextIcon(
                text: widget.branchData.addressLine1.validate(),
                spacing: 12,
                textStyle: primaryTextStyle(
                  color: Colors.white
                ),
                prefix: ic_location.iconImage(color: Colors.white, size: 16),
              ),
              Spacer(),
              Icon(Icons.star, size: 22, color: getRatingBarColor(widget.branchData.ratingStar.validate().toInt())),
              if (widget.branchData.totalReview.validate() >= 1)
                Text(
                  '${widget.branchData.totalReview.validate()}',
                  style: secondaryTextStyle(
                    size: 21,
                    color: Colors.white
                  ),
                )
            ],
          ),

        // Row(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: [
        //     shopInfoWidget(
        //       color: territoryButtonColor,
        //       icon: ic_call,
        //       title: locale.call,
        //       callback: () {
        //         launchCall(appStore.branchContactNumber);
        //       },
        //     ).expand(),
        //     12.width,
        //     shopInfoWidget(
        //       color: quaternaryButtonColor,
        //       icon: ic_direction,
        //       title: locale.direction,
        //       callback: () {
        //         commonLaunchUrl('https://www.google.com/maps/search/?api=1&query=${widget.branchData.latitude},${widget.branchData.longitude}', launchMode: LaunchMode.externalApplication);
        //       },
        //     ).expand(),
        //     12.width,
        //     shopInfoWidget(
        //       color: territoryButtonColor,
        //       icon: ic_share,
        //       title: locale.share,
        //       callback: () async {
        //         String shareBranch = "${locale.branchName}: ${widget.branchData.name}";
        //
        //         if (widget.branchData.addressLine1.validate().isNotEmpty) shareBranch = '$shareBranch\n${locale.place}: ${widget.branchData.addressLine1}';
        //         if (widget.branchData.contactNumber.validate().isNotEmpty) shareBranch = '$shareBranch\n${locale.contactNumber}: ${widget.branchData.contactNumber}';
        //
        //         Share.share(shareBranch);
        //       },
        //     ).expand(),
        //   ],
        // ),
      ],
    ).paddingSymmetric(horizontal: 16);
  }
}
