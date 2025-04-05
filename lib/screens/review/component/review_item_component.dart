import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:frezka/utils/common_base.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/cached_image_widget.dart';
import '../../../components/default_user_image_placeholder.dart';
import '../../../models/review_data.dart';
import '../../../utils/constants.dart';

class ReviewItemComponent extends StatefulWidget {
  final ReviewData reviewData;

  ReviewItemComponent({required this.reviewData});

  @override
  _ReviewItemComponentState createState() => _ReviewItemComponentState();
}

class _ReviewItemComponentState extends State<ReviewItemComponent> {
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
    return Container(
      height: 100,
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: boxDecorationWithRoundedCorners(backgroundColor: context.cardColor),
      child: Row(
        children: [
          // CachedImageWidget(
          //   url: widget.reviewData.,
          //   fit: BoxFit.cover,
          //   height: 150,
          //   width: 100,
          //   child: DefaultUserImagePlaceholder(),
          // ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.reviewData.username.validate(), style: boldTextStyle(), maxLines: 2, overflow: TextOverflow.ellipsis).flexible(),
                RatingBar.builder(
                  initialRating: widget.reviewData.rating?.toDouble() ?? 0,
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
                if (widget.reviewData.reviewMsg.validate().isNotEmpty)
                  Column(
                    children: [
                      8.height,
                      Text(widget.reviewData.reviewMsg!, style: secondaryTextStyle()),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
