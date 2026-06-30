import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 设置状态栏和导航栏样式
/// 根据当前主题亮度自动调整状态栏文字颜色（亮色主题显示深色文字，暗色主题显示浅色文字）
/// 同时设置状态栏和导航栏为透明背景
void setStatusBar(BuildContext context) {
  var th = Theme.of(context).brightness == Brightness.light
      ? SystemUiOverlayStyle.dark
      : SystemUiOverlayStyle.light;
  SystemChrome.setSystemUIOverlayStyle(th.copyWith(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
  ));
}
