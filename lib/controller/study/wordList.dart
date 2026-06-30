import 'package:memorydemo/controller/app/app.dart';
import 'package:memorydemo/controller/study/study.dart';
import 'package:memorydemo/entity/word/po/word.dart';
import 'package:memorydemo/service/study/study.dart';
import 'package:memorydemo/service/word/word.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../entity/word/vo/word.dart';
import '../../service/app/app.dart';

/// 单词列表页面控制器
/// 管理播放列表、已学习列表、熟词列表、全部单词列表的展示和操作
class WordListController extends GetxController {
  /// 页面控制器
  var pageController = PageController();

  /// 当前页面索引
  var pageIndex = 0.obs;

  /// 页面标题
  var title = "播放列表".obs;

  /// 已通过（PASS）的单词列表
  var passList = Rx(<String>[]);

  /// 已删除（熟词）的单词列表
  var deleteList = Rx(<String>[]);

  /// 全部单词列表
  var allList = Rx(<WordVO>[]);

  /// 搜索关键词
  var wordSearchText = "".obs;

  @override
  void onInit() {
    super.onInit();
    fetchWordList();
  }

  /// 获取所有单词列表数据
  void fetchWordList() async {
    await fetchBookPassWordList();
    await fetchBookDeleteWordList();
    await fetchBookAllWordList();
    onPageChanged(pageIndex.value);
  }

  /// 查询所有未删除的单词列表
  Future<void> fetchBookAllWordList() async {
    AppController app = Get.find();
    StudyController study = Get.find();
    var allList = await app.appService.wordDao
        .queryBookNotDeleteWord(app.appService.bookId);
    var all =
        allList.map((e) => study.appService.getWordVO(e)!).toList();
    this.allList.value = all;
  }

  /// 查询已删除（熟词）的单词列表
  Future<void> fetchBookDeleteWordList() async {
    AppController app = Get.find();
    StudyController study = Get.find();
    var deleteList =
        await app.appService.wordDao.queryBookDeleteWord(app.appService.bookId);
    this.deleteList.value =
        deleteList.map((e) => study.appService.getWord(e)?.word ?? "").toList();
  }

  /// 查询已通过（PASS）的单词列表
  Future<void> fetchBookPassWordList() async {
    AppController app = Get.find();
    StudyController study = Get.find();
    var passList =
        await app.appService.wordDao.queryBookPassWord(app.appService.bookId);
    this.passList.value =
        passList.map((e) => study.appService.getWord(e)?.word ?? "").toList();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  /// 页面切换时更新标题
  void onPageChanged(int index) {
    pageIndex.value = index;
    StudyController studyService = Get.find();
    switch (index) {
      case 0:
        title.value = "播放列表 · ${studyService.playingWords.length}";
        break;
      case 1:
        title.value = "已学习(PASS) · ${passList.value.length}";
        break;
      case 2:
        title.value = "熟词(已删除) · ${deleteList.value.length}";
        break;
      case 3:
        title.value = "全部单词 · ${allList.value.length}";
        break;
    }
  }

  /// 根据单词拼写获取单词视图对象
  WordVO? getWordVO(String word) {
    AppService wordService = Get.find();
    return wordService.toWordVO(wordService.getWordBySpell(word));
  }

  /// 根据单词含义搜索单词
  /// [word] 单词对象
  /// [meansText] 搜索文本
  /// 返回是否包含匹配的释义
  bool isContainsMeans(WordVO?word,String meansText){
    var means = word?.means;
    if(means!=null) {
      for (var mean in means) {
        var contains = mean.toString().toLowerCase().contains(meansText.toLowerCase());
        if(contains){
          return true;
        }
      }
    }
    return false;
  }

  /// 设为熟词：删除单词
  Future<void> deleteWord(WordVO word) async {
    AppService wordService = Get.find();
    await wordService.deleteWord(word.wordId);
    word.isDelete = await wordService.queryWordDeleteStatus(word.wordId);
  }

  /// 重新学习：从熟词中恢复单词
  Future<void> restoreWord(WordVO word) async {
    AppService wordService = Get.find();
    await wordService.restoreWord(word.wordId);
    word.isDelete = await wordService.queryWordDeleteStatus(word.wordId);
  }

  /// 获取单词删除状态
  Future<void> getDeleteStatus(WordVO word) async {
    AppService wordService = Get.find();
    word.isDelete = await wordService.queryWordDeleteStatus(word.wordId);
  }
}
