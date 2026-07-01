import 'package:get/get.dart';
import 'package:memorydemo/service/app/app.dart';

/// 单词搜索控制器
/// 负责单词搜索的逻辑处理，包括关键词搜索、搜索结果管理
class WordSearchController extends GetxController {
  /// 应用服务实例
  AppService appService = Get.find();

  /// 搜索关键词
  var keyword = "".obs;

  /// 搜索结果列表
  var searchResults = <dynamic>[].obs;

  /// 是否正在搜索
  var isSearching = false.obs;

  /// 搜索单词
  /// [text] 搜索关键词
  /// 根据关键词模糊匹配单词拼写，返回匹配结果列表
  void search(String text) {
    keyword.value = text;
    if (text.isEmpty) {
      searchResults.clear();
      return;
    }

    isSearching.value = true;
    
    // 从 wordMap 中搜索匹配的单词
    var results = <dynamic>[];
    var wordMap = appService.wordService.wordMap;
    
    for (var word in wordMap.values) {
      // 模糊匹配：单词拼写包含关键词（不区分大小写）
      if (word.word != null && 
          word.word!.toLowerCase().contains(text.toLowerCase())) {
        var wordVO = appService.toWordVO(word);
        if (wordVO != null) {
          results.add(wordVO);
        }
      }
    }

    // 按单词长度排序，短单词优先显示
    results.sort((a, b) {
      var lenA = (a.word as String?)?.length ?? 0;
      var lenB = (b.word as String?)?.length ?? 0;
      return lenA.compareTo(lenB);
    });

    // 限制结果数量，避免性能问题
    if (results.length > 100) {
      results = results.sublist(0, 100);
    }

    searchResults.value = results;
    isSearching.value = false;
  }

  /// 清空搜索
  void clearSearch() {
    keyword.value = "";
    searchResults.clear();
  }
}