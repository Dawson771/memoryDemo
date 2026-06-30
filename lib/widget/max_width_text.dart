import 'dart:math';

import 'package:flutter/material.dart';

/// 最大宽度文本组件
/// 限制文本的最大显示宽度，超出时可水平滚动查看
/// 用于音标等可能较长的文本展示
class MaxWidthText extends StatelessWidget {
  /// 最大显示宽度
  double maxWidth;
  /// 文本内容
  String text;
  /// 文本样式
  TextStyle? style;
  /// 最大行数
  int? maxLines;

  MaxWidthText({
    Key? key,
    required this.text,
    required this.maxWidth,
    this.maxLines,
    this.style,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      var painter = TextPainter(
        text: TextSpan(text: text, style: style),
        textDirection: TextDirection.ltr,
      );
      painter.layout(maxWidth: constraints.maxWidth);
      return Container(
        width: min(maxWidth, painter.width),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Text(
            text,
            style: style,
            maxLines: maxLines,
          ),
        ),
      );
    });
  }
}
