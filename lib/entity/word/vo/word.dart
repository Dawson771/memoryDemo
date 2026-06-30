/// 单词视图对象（VO - View Object）
/// 用于在UI层展示单词的完整信息，包括发音、释义、例句等
class WordVO {
  /// 单词ID
  String? wordId;

  /// 单词内容
  String? word;

  /// 美式发音音标
  String? usaVoice;

  /// 英式发音音标
  String? ukVoice;

  /// 单词释义列表
  List<dynamic>? means;

  /// 例句内容
  String? sentence;

  /// 例句来源
  String? sentenceOrigin;

  /// 例句中文翻译
  String? sentenceMeans;

  /// 辅助记忆信息
  String? helper;

  /// 是否已删除（熟词）
  bool? isDelete;

  WordVO({
    this.wordId,
    this.word,
    this.usaVoice,
    this.ukVoice,
    this.means,
    this.sentence,
    this.sentenceOrigin,
    this.sentenceMeans,
    this.helper,
  });
}
