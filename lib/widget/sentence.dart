import 'package:memorydemo/entity/word/vo/word.dart';
import 'package:flutter/material.dart';

/// 单词例句组件
/// 解析包含<b>标签的例句文本，将重点单词加粗显示
/// 可选显示喇叭图标用于播放发音
class WordSentence extends StatelessWidget {
  /// 例句内容（可包含<b>标签标记重点单词）
  String? sentence;
  /// 是否显示音量图标
  bool? showVoice;

  WordSentence({
    Key? key,
    this.sentence,
    this.showVoice,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //例句，下划线，单词卡片按钮
    var example = sentence ?? "";
    var spans = <InlineSpan>[];
    if (this.showVoice == true) {
      spans.add(WidgetSpan(
          child: Icon(
            Icons.volume_down_outlined,
            size: 24,
            color: Colors.grey,
          )));
    }
    var pos = 0;
    for (;;) {
      var wordStart = example.indexOf("<b>", pos);
      if (wordStart == -1) break;
      var wordEnd = example.indexOf("</b>", wordStart);
      if (wordEnd == -1) break;
      spans.add(TextSpan(
          text: example.substring(pos, wordStart),
          style: TextStyle(
            color: Colors.black54,
            fontSize: 16,
          )));
      var word = example.substring(wordStart + 3, wordEnd);
      spans.add(TextSpan(
          text: "$word",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          )));
      pos = wordEnd + 4;
    }

    spans.add(TextSpan(
        text: example.substring(pos),
        style: TextStyle(
          color: Colors.black54,
          fontSize: 16,
        )));

    return LayoutBuilder(builder: (context, cons) {
      return Container(
        child: RichText(
          text: TextSpan(
            children: spans,
          ),
        ),
      );
    });
  }
}
