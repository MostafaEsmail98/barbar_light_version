import 'package:flutter/material.dart';
import 'package:frezka/components/cached_image_widget.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../utils/common_base.dart';
import '../../../utils/images.dart';
import '../model/notification_model.dart';

class NotificationWidget extends StatelessWidget {
  final NotificationData notificationData;

  NotificationWidget({required this.notificationData});


  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.width(),
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: boxDecorationDefault(
        color: Colors.white,
        borderRadius: radius(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CachedImageWidget(url: ic_notification_user, height: 40),
          16.width,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (notificationData.data != null && notificationData.data!.notificationDetail != null) Text('#${notificationData.data!.notificationDetail!.id.validate()}', style: boldTextStyle(size: 12)).expand(),
                  Text(formatDate(notificationData.createdAt.validate()), style: secondaryTextStyle()),
                ],
              ),
              8.height,
              Text(notificationData.data!.subject.validate(), style: secondaryTextStyle(), maxLines: 3, overflow: TextOverflow.ellipsis),
            ],
          ).expand(),
        ],
      ),
    );
  }
}
