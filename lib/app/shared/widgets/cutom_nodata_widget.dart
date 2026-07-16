import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import '../../core/constants/image_constant.dart';

class NoDataFoundWidget extends StatelessWidget {
  final String? message;
  final double? lottieHeight;
  final String? lottieAsset;
  final TextStyle? textStyle;

  const NoDataFoundWidget({
    super.key,
    this.message,
    this.lottieHeight,
    this.lottieAsset,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Lottie.asset(
          lottieAsset ?? ImageConstants.noData,
          height: lottieHeight ?? 180.h,
          fit: BoxFit.contain,
        ),
        SizedBox(height: 16.h),
        Text(
          message ?? "No Services Available",
          style:
              textStyle ??
              TextStyle(
                fontSize: 16.sp,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: 90.h),
      ],
    );
  }
}
