import 'dart:convert';
import 'dart:io';

import 'package:memorydemo/dao/floor.dart';
import 'package:floor/floor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../entity/word/po/word.dart';
import '../../entity/word/vo/word.dart';
import '../../service/app/app.dart';

/// 应用全局控制器
/// 负责应用初始化、全局配置管理等
class AppController extends GetxController {
  /// 应用服务实例
  var appService = Get.find<AppService>();

  @override
  void onInit() async {
    super.onInit();
    _init();
  }

  /// 初始化应用配置
  Future<void> _init() async {
    appService.readOptions();
  }
}
