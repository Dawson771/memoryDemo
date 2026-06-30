import 'package:memorydemo/controller/selectBook/selectBook.dart';
import 'package:memorydemo/controller/study/wordList.dart';
import 'package:memorydemo/view/selectBook/selectBook.dart';
import 'package:get/get.dart';

import '../controller/home/home.dart';
import '../controller/statistic/statistic.dart';
import '../controller/study/study.dart';
import '../service/home/home.dart';
import '../service/study/study.dart';
import '../view/home/home.dart';
import '../view/statistic/statistic.dart';
import '../view/study/study.dart';

/// 应用路由配置
/// 使用GetX路由管理，每个页面在进入时注入对应的Controller和Service
var pages = [
  /// 主页路由 - 展示学习进度、今日统计和开始学习按钮
  GetPage(
      name: "/",
      page: () {
        Get.put(HomeService());
        Get.put(HomeController());
        return HomeView();
      }),

  /// 学习界面路由 - 单词学习主界面，包含播放控制、学习/复习功能
  GetPage(
      name: "/study",
      page: () {
        Get.put(StudyService());
        Get.put(StudyController());
        return StudyPage();
      }),

  /// 选择单词书界面路由 - 用于切换不同的单词书
  GetPage(
      name: "/selectBook",
      page: () {
        Get.put(SelectBookController());
        return SelectBookPage();
      }),

  /// 统计详情界面路由 - 展示学习数据统计图表
  GetPage(
      name: "/statistic",
      page: () {
        Get.put(StatisticController());
        return StatisticPage();
      }),
];
