import 'dart:math';

import 'package:memorydemo/dao/word/word.dart';
import 'package:memorydemo/entity/record/po/record.dart';
import 'package:memorydemo/service/app/app.dart';
import 'package:memorydemo/util/time.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../util/theme.dart';
import '../../widget/book_icon.dart';

/// 首页控制器
/// 管理首页数据展示、学习统计、书籍切换等功能
class HomeController extends GetxController {
  /// 今日学习时间（分钟）
  var studyTime = 0.0.obs;

  /// 需要复习的单词数量
  var reviewCount = 0.obs;

  /// 今日学习通过的单词数量
  var dailyWordCount = 0.obs;

  /// 学习进度文本（已学/总数）
  var progress = "加载中...".obs;

  /// 学习进度百分比
  var progressPercent = 0.0.obs;

  /// 当前选择的单词书名称
  var wordBook = "加载中...".obs;

  /// 用户名
  var username = "加载中...".obs;

  /// 书籍图标数据
  var bookIcon = BookImage().obs;

  /// 应用服务实例
  AppService appService = Get.find();

  /// 单词数据访问对象
  var wordDao = Get.find<WordDao>();

  /// 跳转到学习页面
  void toStudy() async {
    await Get.toNamed("/study");
    await const Duration(milliseconds: 500).delay();
    setStatusBar(Get.context!);
    fetchInfo();
  }

  @override
  void onInit() {
    super.onInit();
    fetchInfo();
  }

  /// 获取首页展示的所有数据信息
  /// 包括书籍信息、学习进度、复习数量、学习时间等
  void fetchInfo() async {
    username.value = "";
    wordBook.value = appService.bookName;
    var bookInfo = appService.wordService.bookInfo[appService.bookName] as Map;
    bookIcon.value = BookImage(
      title: bookInfo["title"],
      subTitle: bookInfo["subTitle"],
      color: bookInfo["color"],
      fontColor: bookInfo["fontColor"],
      wordCount: "",
    );
    await appService.readWords();
    bookIcon.value = BookImage(
      title: bookInfo["title"],
      subTitle: bookInfo["subTitle"],
      color: bookInfo["color"],
      fontColor: bookInfo["fontColor"],
      wordCount: "词汇量:${appService.wordService.bookMap[appService.bookName]?.words?.length}",
    );
    var allCount = await wordDao.queryWordCount(appService.bookId);
    var progressCount = await wordDao.queryProgressWordCount(appService.bookId);
    var dailyCount = await wordDao.queryDailyPassWordCount();
    progress.value = "$progressCount/$allCount";
    dailyWordCount.value = dailyCount ?? 0;
    var reviewCount = await wordDao.queryReviewWordCount();
    this.reviewCount.value = reviewCount ?? 0;
    var studyTime = (await wordDao.queryStudyTime()) ?? 0;
    this.studyTime.value = studyTime / 1000 / 60;
  }

  /// 切换学习的单词书
  void selectBook(String bookName) {
    appService.selectBook(bookName);
    fetchInfo();
  }
}
