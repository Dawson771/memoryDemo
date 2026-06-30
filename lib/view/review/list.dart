import 'package:memorydemo/entity/word/vo/word.dart';
import 'package:memorydemo/util/audio.dart';
import 'package:memorydemo/widget/hide_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../word/word.dart';

/// 学习检测列表视图
/// 以问答形式展示单词复习列表，点击单词可显示/隐藏答案
/// 底部提供完成/下一步按钮
class StudyCheckListView extends StatelessWidget {
  /// 是否显示答案（用于整体控制，已弃用，每个单词单独控制）
  var show = false.obs;
  /// 单词列表数据
  List<WordVO> wordList;
  /// 下一步按钮点击回调
  VoidCallback? onNextPressed;
  /// 下一步按钮显示文本
  String? nextText;

  StudyCheckListView({
    Key? key,
    required this.wordList,
    this.onNextPressed,
    this.nextText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: BouncingScrollPhysics(),
      // padding: EdgeInsets.only(
      //   bottom: 150,
      // ),
      itemBuilder: (context, index) {
        if (index == wordList.length) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 80),
            child: LayoutBuilder(
                builder: (context, cons) {
                  return ElevatedButton(
                    onPressed: onNextPressed,
                    child: Text(nextText ?? "完成"),
                    style: ButtonStyle(
                        backgroundColor:
                        MaterialStateProperty.all(Colors.deepPurpleAccent),
                        minimumSize: MaterialStateProperty.all(
                            Size(cons.maxWidth - 40, 48)),
                        textStyle: MaterialStateProperty.all(TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ))),
                  );
                }

          ),
        );
        }
        return WordQuestion(
        index: index,
        word: wordList[index],
        );
        },
      itemCount: wordList.isEmpty ? 0 : wordList.length + 1,
    );
  }
}

/// 单词问题项组件
/// 复习模式下的单个单词卡片，显示例句（隐藏关键单词）
/// 点击可显示/隐藏答案，显示时自动播放发音
class WordQuestion extends StatelessWidget {
  WordQuestion({
    Key? key,
    required this.index,
    required this.word,
  }) : super(key: key);
  /// 单词数据
  WordVO word;
  /// 是否显示答案
  var show = false.obs;
  /// 当前索引
  int index;
  /// 自动隐藏答案的时间戳（毫秒）
  int hideTime = 0;

  @override
  Widget build(BuildContext context) {
    //例句，下划线，单词卡片按钮
    var example = word.sentence ?? "";
    var spans = <InlineSpan>[];
    var pos = 0;
    spans.add(TextSpan(
        text: "${index + 1}. ",
        style: TextStyle(
          color: Colors.black54,
          fontSize: 16,
        )));
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
      var wordStr = example.substring(wordStart + 3, wordEnd);
      spans.add(WidgetSpan(
          baseline: TextBaseline.alphabetic,
          alignment: PlaceholderAlignment.baseline,
          child: InkWell(
            child: Obx(
                  () =>
                  HideText(
                    show: show.value,
                    text: TextSpan(
                        text: "$wordStr",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        )),
                    color: Colors.grey,
                  ),
            ),
          )));
      pos = wordEnd + 4;
    }
    spans.add(TextSpan(
        text: example.substring(pos),
        style: TextStyle(
          color: Colors.black54,
          fontSize: 16,
        )));
    return InkWell(
      onTap: () async {
        if (!show.value) {
          show.value = true;
            playWordSound(word.word ?? "", 1,);
          var waitTime = 10000;
          hideTime = DateTime
              .now()
              .millisecondsSinceEpoch + waitTime;
          await Future.delayed(Duration(milliseconds: waitTime));
          if (DateTime
              .now()
              .millisecondsSinceEpoch >= hideTime) {
            show.value = false;
          }
        }
      },
      child: LayoutBuilder(builder: (context, cons) {
        return Obx(
              () =>
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                child: Stack(
                  children: [
                    Container(
                      padding: EdgeInsets.only(right: 50, top: 10, bottom: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: spans,
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 10, left: 2),
                            color:
                            (show.value) ? null : Colors.grey.withOpacity(0.1),
                            child: RichText(
                              text: TextSpan(
                                text: word.sentenceMeans,
                                style: TextStyle(
                                    color: (show.value)
                                        ? Colors.grey
                                        : Colors.transparent,
                                    fontSize: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        width: 40,
                        height: 40,
                        child: Container(
                          child: Ink(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: InkWell(
                              child: Icon(
                                Icons.translate,
                                color: Colors.grey,
                                size: 16,
                              ),
                              onTap: () {
                                showDictCardDialog(context, word);
                              },
                              borderRadius: BorderRadius.circular(100),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
        );
      }),
    );
  }
}

/// 显示单词详情弹窗
/// 点击翻译按钮时弹出，展示单词的完整信息
void showDictCardDialog(BuildContext context, WordVO word) {
  showDialog(
      context: context,
      builder: (context) {
        return Center(
          child: Container(
            width: 300,
            height: 400,
            child: Card(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(bottom: 50),
                child: WordView(
                  word: word,
                ),
              ),
            ),
          ),
        );
      });
}
