import 'package:flutter/material.dart';
import 'package:frezka/components/cached_image_widget.dart';
import 'package:nb_utils/nb_utils.dart';

import '../screens/branch/component/branch_information_component.dart';
import '../screens/branch/model/branch_detail_response.dart';

class SliderComponent extends StatefulWidget {
  final BranchDetailResponse branchData;

  SliderComponent({required this.branchData});

  @override
  _SliderComponentState createState() => _SliderComponentState();
}

class _SliderComponentState extends State<SliderComponent> {
  PageController controller = PageController();

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
    return AnimatedScrollView(
      physics: NeverScrollableScrollPhysics(),
      listAnimationType: ListAnimationType.None,
      children: [
        Stack(
          children: [
            ClipRRect(
    borderRadius: radiusOnly(bottomLeft: 30, bottomRight: 30),
              child: CachedImageWidget(
                url: widget.branchData.data!.branchImg.validate(),
                height: 350,
                width: context.width(),
                fit: BoxFit.cover,
              ),
            ),

            /// Branch Information
            PositionedDirectional(bottom: 5,start: 0,end: 0,child: BranchInformationComponent(branchData: widget.branchData.data!)),
          ],
        ),
      ],
    );
  }
}
