import 'package:memorydemo/service/app/app.dart';
import 'package:memorydemo/service/word/word.dart';
import 'package:memorydemo/widget/sentence.dart';
import 'package:get/get.dart';

/// 选择单词书页面控制器
/// 管理书籍列表展示和选择
class SelectBookController extends GetxController {
  /// 应用服务实例
  AppService appService = Get.find();

  /// 书籍总数
  get bookCount => appService.wordService.bookNames.length;

  /// 书籍名称列表
  get bookNames => appService.wordService.bookNames;

  /// 当前选择的书籍名称
  get selectBookName => appService.bookName;

  /// 书籍配置信息
  get bookInfo => appService.wordService.bookInfo;

  /// 书籍映射表
  get bookMap => appService.wordService.bookMap;
}
