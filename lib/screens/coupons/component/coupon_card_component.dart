import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frezka/components/cached_image_widget.dart';
import 'package:frezka/components/price_widget.dart';
import 'package:frezka/main.dart';
import 'package:frezka/utils/dash_line.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/dotted_line.dart';

class CouponCardComponent extends StatelessWidget {
  final String? couponImage;
  final String? couponTitle;
  final String? couponCode;
  final String? expiryDate;
  final String? couponDiscount;
  final bool? isFixDiscount;
  final String? discountAmount;
  const CouponCardComponent({super.key, this.isFixDiscount, this.discountAmount, this.expiryDate, this.couponDiscount, this.couponCode, this.couponImage, this.couponTitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
          color: Color(0xFFFFF9E6),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Color(0xffDDBF5D),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "%",
                              style: TextStyle(
                                fontSize: 16,color: Colors.black,
                              ),
                            ),
                            Text(locale.discount,style: TextStyle(color: Colors.black,),),
                          ],
                        ),
                        Text(
                          couponDiscount ?? "0",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 50),
                        )
                      ],
                    ),
                    Text(
                      couponTitle ?? "",
                      style: TextStyle(fontSize: 12,color: Colors.black,),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 1,
                height: 120,
                child: DottedLine(
                  direction: Axis.vertical,
                  dashColor: Colors.black,
                ),
              ),
              Expanded(
                child: Container(
                  height: 60,
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                      border:
                      Border.all(color: Colors.black, width: 2)),
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      Text(
                        couponCode ??"",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,color: Colors.black,
                        ),
                      ),
                      PositionedDirectional(
                          top: -12,
                          child: Container(
                              color: Color(0xFFFFF9E6),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5),
                                child: Text(locale.useCoupon,
                                    style: TextStyle(fontSize: 14,color: Colors.black,)),
                              ))),
                    ],
                  ),
                ),
              ),
            ],
          ),
          PositionedDirectional(
            start: -25,
            top: 50,
            child: Container(
              height: 25,
              width: 25,
              decoration: BoxDecoration(
                  color: Colors.black, shape: BoxShape.circle),
            ),
          ),
          PositionedDirectional(
            end: -25,
            top: 50,
            child: Container(
              height: 25,
              width: 25,
              decoration: BoxDecoration(
                  color: Colors.black, shape: BoxShape.circle),
            ),
          ),
        ],
      ),
    );
  }
}
