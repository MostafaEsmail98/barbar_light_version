import 'package:flutter/material.dart';
import 'package:frezka/main.dart';
import 'package:frezka/utils/colors.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/view_all_label_component.dart';
import '../../../utils/app_common.dart';
import '../model/product_list_response.dart';

class ProductDescriptionComponent extends StatelessWidget {
  final ProductData productData;

  ProductDescriptionComponent({required this.productData});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (productData.description.validate().isNotEmpty) ViewAllLabel(label: locale.description, isShowAll: false).paddingSymmetric(horizontal: 16),
        if (productData.description.validate().isNotEmpty)
          ReadMoreText(
            parseHtmlString(productData.description),
            trimLines: 3,
            style: primaryTextStyle(size: 13),
            colorClickableText: primaryColor,
            trimMode: TrimMode.Line,
            trimCollapsedText: " ...${locale.readMore}",
            trimExpandedText: locale.readLess,
            locale: Localizations.localeOf(context),
          ).paddingSymmetric(horizontal: 16),
      ],
    );
  }
}
