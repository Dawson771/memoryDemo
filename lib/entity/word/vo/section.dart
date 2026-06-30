import 'package:memorydemo/entity/word/po/word.dart';
import 'package:memorydemo/entity/word/vo/word.dart';

/// 学习单元/章节视图对象
/// 表示一个学习单元，包含该单元的单词列表和学习进度
class SectionVO {
  /// 章节/单元序号
  int section;

  /// 单词视图对象列表（包含完整单词信息）
  List<WordVO> wordList;

  /// 单词持久化对象列表（数据库中的单词数据）
  List<WordPO> words;

  /// 当前学习到的单词索引位置
  int studyIndex;

  /// 是否为复习模式
  bool review;

  SectionVO({
    required this.section,
    required this.wordList,
    required this.words,
    required this.studyIndex,
    required this.review,
  });
}
