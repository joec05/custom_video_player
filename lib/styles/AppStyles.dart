// ignore: file_names
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

var defaultFontSize = 16.9;

var standardTextFontSize = defaultFontSize.sp;

var videoControlActionIconSize = 32.5.sp;

var menuMainContainerButtonMargin = EdgeInsets.symmetric(vertical: 0.8.h);

var menuButtonWidth = 80.w;

var menuButtonStyle = ElevatedButton.styleFrom(
  backgroundColor: Colors.orange,
  fixedSize: Size(40.w, 7.h),
  textStyle: TextStyle(
    fontSize: standardTextFontSize,
    fontWeight: FontWeight.w400
  )
);

var videoControlFullScreenIconSize = 25.sp;

var videoControlFullScreenIconContainerMargin = EdgeInsets.only(left: 1.w);