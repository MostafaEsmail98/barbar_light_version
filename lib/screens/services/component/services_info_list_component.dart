import 'package:flutter/material.dart';
import 'package:frezka/components/price_widget.dart';
import 'package:frezka/utils/colors.dart';
import 'package:frezka/utils/common_base.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/cached_image_widget.dart';
import '../../../main.dart';
import '../models/service_response.dart';

class ServicesInfoListComponent extends StatefulWidget {
  final ServiceListData serviceInfo;
  final Function() onPressed;

  ServicesInfoListComponent(
      {required this.serviceInfo, required this.onPressed});

  @override
  _ServicesInfoListComponentState createState() =>
      _ServicesInfoListComponentState();
}

class _ServicesInfoListComponentState extends State<ServicesInfoListComponent> {
  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onPressed.call();
      },
      child: Container(
        decoration: boxDecorationWithRoundedCorners(
            backgroundColor: context.cardColor, borderRadius: radius()),
        padding: EdgeInsets.only(left: 16, right: 8, top: 16, bottom: 16),
        margin: EdgeInsets.only(bottom: 16),
        child: Row(
          children: [
            Checkbox(
              value: widget.serviceInfo.isServiceChecked,
              shape: RoundedRectangleBorder(borderRadius: radius(20)),
              visualDensity: VisualDensity.compact,
              activeColor: primaryColor,
              side: BorderSide(color: textSecondaryColorGlobal),
              checkColor: primaryColor,
              onChanged: (value) {
                widget.onPressed.call();
              },
            ),
            Expanded(
                child: Text('${widget.serviceInfo.name.validate()}',
                    style: boldTextStyle())),
            CachedImageWidget(
              url: widget.serviceInfo.serviceImage.validate(),
              height: 40,
              width: 40,
              fit: BoxFit.cover,
              radius: defaultRadius,
            ),
            SizedBox(
              width: 5,
            ),
            PriceWidget(
              isBoldText: true,
              price: widget.serviceInfo.defaultPrice.validate(),
              size: 17,
              color: context.textTheme.titleLarge!.color,
            ),
          ],
        ),
      ),
    );
  }
}
