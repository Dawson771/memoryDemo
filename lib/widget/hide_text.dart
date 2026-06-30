import 'package:flutter/material.dart';

/// 隐藏文本组件
/// 用于在复习模式下隐藏/显示单词或短语
/// 隐藏时显示下划线占位，显示时显示完整文本
class HideText extends StatelessWidget {
  /// 要显示的文本内容
  TextSpan text;
  /// 隐藏时的占位颜色
  Color color;
  /// 是否显示文本内容
  bool show;

  HideText({
    Key? key,
    required this.text,
    required this.color,
    required this.show,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, cons) {
      var painter = TextPainter(
        text: text,
        textDirection: TextDirection.ltr,
      );
      painter.layout();
      return Stack(
        children: [
          Opacity(
            opacity: show ? 1 : 0,
            child: Container(
              // alignment: Alignment.bottomCenter,
              width: painter.width + 12,
              height: painter.height,
              alignment: Alignment.bottomCenter,
              child: RichText(
                text: text,
              ),
            ),
          ),
          Container(
            // alignment: Alignment.bottomCenter,
            width: painter.width + 12,
            height: painter.height,
            decoration: BoxDecoration(
                border:
                Border(bottom: BorderSide(color: Colors.grey, width: 1))),
            // child: show
            //     ? null
            //     : Icon(
            //   Icons.remove_red_eye,
            //   color: color,
            // ),
          ),
        ],
      );
    });
  }
}
