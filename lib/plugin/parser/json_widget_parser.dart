import 'package:flutter/material.dart';

/// JSON Widget 解析器
/// 将 JSON 格式的 Widget 配置转换为实际的 Flutter Widget
class JsonWidgetParser {
  /// 解析 Widget 配置
  /// [config] Widget 的 JSON 配置
  /// [onAction] 动作回调
  static Widget parse(Map<String, dynamic> config,
      {void Function(String)? onAction}) {
    String type = config['type'] ?? '';
    Map<String, dynamic>? properties =
        config['properties'] != null ? Map<String, dynamic>.from(config['properties']) : null;

    switch (type) {
      case 'Container':
        return _parseContainer(properties, onAction);
      case 'Column':
        return _parseColumn(properties, onAction);
      case 'Row':
        return _parseRow(properties, onAction);
      case 'Text':
        return _parseText(properties);
      case 'ElevatedButton':
        return _parseElevatedButton(properties, onAction);
      case 'Image':
        return _parseImage(properties);
      case 'Padding':
        return _parsePadding(properties, onAction);
      case 'SizedBox':
        return _parseSizedBox(properties, onAction);
      case 'Align':
        return _parseAlign(properties, onAction);
      case 'Card':
        return _parseCard(properties, onAction);
      case 'Icon':
        return _parseIcon(properties);
      case 'Divider':
        return _parseDivider(properties);
      case 'Flexible':
        return _parseFlexible(properties, onAction);
      case 'Expanded':
        return _parseExpanded(properties, onAction);
      default:
        return Container();
    }
  }

  /// 解析 Container
  static Widget _parseContainer(
      Map<String, dynamic>? properties, void Function(String)? onAction) {
    return Container(
      child: properties?['child'] != null
          ? parse(properties!['child'], onAction: onAction)
          : null,
      padding: _parseEdgeInsets(properties?['padding']),
      margin: _parseEdgeInsets(properties?['margin']),
      decoration: _parseBoxDecoration(properties?['decoration']),
      width: properties?['width'],
      height: properties?['height'],
      alignment: _parseAlignment(properties?['alignment']),
    );
  }

  /// 解析 Column
  static Widget _parseColumn(
      Map<String, dynamic>? properties, void Function(String)? onAction) {
    List<dynamic>? children = properties?['children'];
    return Column(
      children: children
              ?.map((c) => parse(c, onAction: onAction))
              .toList() ??
          [],
      mainAxisAlignment:
          _parseMainAxisAlignment(properties?['mainAxisAlignment']),
      crossAxisAlignment:
          _parseCrossAxisAlignment(properties?['crossAxisAlignment']),
      mainAxisSize: _parseMainAxisSize(properties?['mainAxisSize']),
    );
  }

  /// 解析 Row
  static Widget _parseRow(
      Map<String, dynamic>? properties, void Function(String)? onAction) {
    List<dynamic>? children = properties?['children'];
    return Row(
      children: children
              ?.map((c) => parse(c, onAction: onAction))
              .toList() ??
          [],
      mainAxisAlignment:
          _parseMainAxisAlignment(properties?['mainAxisAlignment']),
      crossAxisAlignment:
          _parseCrossAxisAlignment(properties?['crossAxisAlignment']),
      mainAxisSize: _parseMainAxisSize(properties?['mainAxisSize']),
    );
  }

  /// 解析 Text
  static Widget _parseText(Map<String, dynamic>? properties) {
    return Text(
      properties?['data'] ?? '',
      style: _parseTextStyle(properties?['style']),
      textAlign: _parseTextAlign(properties?['textAlign']),
      maxLines: properties?['maxLines'],
      overflow: _parseTextOverflow(properties?['overflow']),
    );
  }

  /// 解析 ElevatedButton
  static Widget _parseElevatedButton(
      Map<String, dynamic>? properties, void Function(String)? onAction) {
    String? action = properties?['onPressed'];
    return ElevatedButton(
      onPressed: action != null && onAction != null
          ? () => onAction(action)
          : null,
      child: properties?['child'] != null
          ? parse(properties!['child'], onAction: onAction)
          : null,
      style: _parseButtonStyle(properties?['style']),
    );
  }

  /// 解析 Image
  static Widget _parseImage(Map<String, dynamic>? properties) {
    String? src = properties?['src'];
    if (src == null) return Container();

    if (src.startsWith('http')) {
      return Image.network(
        src,
        width: properties?['width'],
        height: properties?['height'],
        fit: _parseBoxFit(properties?['fit']),
      );
    } else {
      return Image.asset(
        src,
        width: properties?['width'],
        height: properties?['height'],
        fit: _parseBoxFit(properties?['fit']),
      );
    }
  }

  /// 解析 Padding
  static Widget _parsePadding(
      Map<String, dynamic>? properties, void Function(String)? onAction) {
    return Padding(
      padding: _parseEdgeInsets(properties?['padding']) ?? EdgeInsets.zero,
      child: properties?['child'] != null
          ? parse(properties!['child'], onAction: onAction)
          : null,
    );
  }

  /// 解析 SizedBox
  static Widget _parseSizedBox(
      Map<String, dynamic>? properties, void Function(String)? onAction) {
    return SizedBox(
      width: properties?['width'],
      height: properties?['height'],
      child: properties?['child'] != null
          ? parse(properties!['child'], onAction: onAction)
          : null,
    );
  }

  /// 解析 Align
  static Widget _parseAlign(
      Map<String, dynamic>? properties, void Function(String)? onAction) {
    return Align(
      alignment: _parseAlignment(properties?['alignment']) ?? Alignment.center,
      child: properties?['child'] != null
          ? parse(properties!['child'], onAction: onAction)
          : null,
    );
  }

  /// 解析 Card
  static Widget _parseCard(
      Map<String, dynamic>? properties, void Function(String)? onAction) {
    return Card(
      child: properties?['child'] != null
          ? parse(properties!['child'], onAction: onAction)
          : null,
      elevation: properties?['elevation'],
      margin: _parseEdgeInsets(properties?['margin']),
      shape: _parseShapeBorder(properties?['shape']),
    );
  }

  /// 解析 Icon
  static Widget _parseIcon(Map<String, dynamic>? properties) {
    String? iconName = properties?['icon'];
    if (iconName == null) return const Icon(Icons.error);

    IconData icon = _getIconData(iconName);
    return Icon(
      icon,
      size: properties?['size'],
      color: _parseColor(properties?['color']),
    );
  }

  /// 解析 Divider
  static Widget _parseDivider(Map<String, dynamic>? properties) {
    return Divider(
      height: properties?['height'],
      thickness: properties?['thickness'],
      color: _parseColor(properties?['color']),
    );
  }

  /// 解析 Flexible
  static Widget _parseFlexible(
      Map<String, dynamic>? properties, void Function(String)? onAction) {
    return Flexible(
      flex: properties?['flex'] ?? 1,
      fit: _parseFlexFit(properties?['fit']),
      child: properties?['child'] != null
          ? parse(properties!['child'], onAction: onAction)
          : null,
    );
  }

  /// 解析 Expanded
  static Widget _parseExpanded(
      Map<String, dynamic>? properties, void Function(String)? onAction) {
    return Expanded(
      flex: properties?['flex'] ?? 1,
      child: properties?['child'] != null
          ? parse(properties!['child'], onAction: onAction)
          : null,
    );
  }

  // ==================== 辅助解析方法 ====================

  /// 解析 EdgeInsets
  static EdgeInsets? _parseEdgeInsets(dynamic value) {
    if (value is num) {
      return EdgeInsets.all(value.toDouble());
    }
    if (value is Map) {
      return EdgeInsets.fromLTRB(
        (value['left'] ?? 0).toDouble(),
        (value['top'] ?? 0).toDouble(),
        (value['right'] ?? 0).toDouble(),
        (value['bottom'] ?? 0).toDouble(),
      );
    }
    return null;
  }

  /// 解析 TextStyle
  static TextStyle? _parseTextStyle(Map<String, dynamic>? value) {
    if (value == null) return null;
    return TextStyle(
      fontSize: value['fontSize']?.toDouble(),
      fontWeight: _parseFontWeight(value['fontWeight']),
      color: _parseColor(value['color']),
      fontStyle: _parseFontStyle(value['fontStyle']),
      decoration: _parseTextDecoration(value['decoration']),
    );
  }

  /// 解析 Color
  static Color? _parseColor(dynamic value) {
    if (value is String) {
      if (value.startsWith('#')) {
        return Color(int.parse(value.substring(1), radix: 16) + 0xFF000000);
      }
      switch (value.toLowerCase()) {
        case 'red':
          return Colors.red;
        case 'blue':
          return Colors.blue;
        case 'green':
          return Colors.green;
        case 'black':
          return Colors.black;
        case 'white':
          return Colors.white;
        case 'grey':
        case 'gray':
          return Colors.grey;
        case 'orange':
          return Colors.orange;
        case 'purple':
          return Colors.purple;
        default:
          return null;
      }
    }
    return null;
  }

  /// 解析 BoxDecoration
  static BoxDecoration? _parseBoxDecoration(Map<String, dynamic>? value) {
    if (value == null) return null;
    return BoxDecoration(
      color: _parseColor(value['color']),
      borderRadius: _parseBorderRadius(value['borderRadius']),
      border: _parseBorder(value['border']),
    );
  }

  /// 解析 BorderRadius
  static BorderRadius? _parseBorderRadius(dynamic value) {
    if (value is num) {
      return BorderRadius.circular(value.toDouble());
    }
    if (value is Map) {
      return BorderRadius.only(
        topLeft: Radius.circular((value['topLeft'] ?? 0).toDouble()),
        topRight: Radius.circular((value['topRight'] ?? 0).toDouble()),
        bottomLeft: Radius.circular((value['bottomLeft'] ?? 0).toDouble()),
        bottomRight: Radius.circular((value['bottomRight'] ?? 0).toDouble()),
      );
    }
    return null;
  }

  /// 解析 Border
  static Border? _parseBorder(Map<String, dynamic>? value) {
    if (value == null) return null;
    return Border.all(
      color: _parseColor(value['color']) ?? Colors.black,
      width: (value['width'] ?? 1).toDouble(),
    );
  }

  /// 解析 Alignment
  static Alignment? _parseAlignment(String? value) {
    switch (value) {
      case 'center':
        return Alignment.center;
      case 'topLeft':
        return Alignment.topLeft;
      case 'topRight':
        return Alignment.topRight;
      case 'bottomLeft':
        return Alignment.bottomLeft;
      case 'bottomRight':
        return Alignment.bottomRight;
      case 'topCenter':
        return Alignment.topCenter;
      case 'bottomCenter':
        return Alignment.bottomCenter;
      case 'centerLeft':
        return Alignment.centerLeft;
      case 'centerRight':
        return Alignment.centerRight;
      default:
        return null;
    }
  }

  /// 解析 MainAxisAlignment
  static MainAxisAlignment _parseMainAxisAlignment(String? value) {
    switch (value) {
      case 'start':
        return MainAxisAlignment.start;
      case 'end':
        return MainAxisAlignment.end;
      case 'center':
        return MainAxisAlignment.center;
      case 'spaceBetween':
        return MainAxisAlignment.spaceBetween;
      case 'spaceAround':
        return MainAxisAlignment.spaceAround;
      case 'spaceEvenly':
        return MainAxisAlignment.spaceEvenly;
      default:
        return MainAxisAlignment.start;
    }
  }

  /// 解析 CrossAxisAlignment
  static CrossAxisAlignment _parseCrossAxisAlignment(String? value) {
    switch (value) {
      case 'start':
        return CrossAxisAlignment.start;
      case 'end':
        return CrossAxisAlignment.end;
      case 'center':
        return CrossAxisAlignment.center;
      case 'stretch':
        return CrossAxisAlignment.stretch;
      case 'baseline':
        return CrossAxisAlignment.baseline;
      default:
        return CrossAxisAlignment.center;
    }
  }

  /// 解析 MainAxisSize
  static MainAxisSize _parseMainAxisSize(String? value) {
    switch (value) {
      case 'min':
        return MainAxisSize.min;
      case 'max':
        return MainAxisSize.max;
      default:
        return MainAxisSize.max;
    }
  }

  /// 解析 TextAlign
  static TextAlign _parseTextAlign(String? value) {
    switch (value) {
      case 'left':
        return TextAlign.left;
      case 'right':
        return TextAlign.right;
      case 'center':
        return TextAlign.center;
      case 'justify':
        return TextAlign.justify;
      default:
        return TextAlign.start;
    }
  }

  /// 解析 TextOverflow
  static TextOverflow _parseTextOverflow(String? value) {
    switch (value) {
      case 'clip':
        return TextOverflow.clip;
      case 'fade':
        return TextOverflow.fade;
      case 'ellipsis':
        return TextOverflow.ellipsis;
      default:
        return TextOverflow.visible;
    }
  }

  /// 解析 FontWeight
  static FontWeight? _parseFontWeight(String? value) {
    switch (value) {
      case 'bold':
        return FontWeight.bold;
      case 'normal':
        return FontWeight.normal;
      case 'w100':
        return FontWeight.w100;
      case 'w200':
        return FontWeight.w200;
      case 'w300':
        return FontWeight.w300;
      case 'w400':
        return FontWeight.w400;
      case 'w500':
        return FontWeight.w500;
      case 'w600':
        return FontWeight.w600;
      case 'w700':
        return FontWeight.w700;
      case 'w800':
        return FontWeight.w800;
      case 'w900':
        return FontWeight.w900;
      default:
        return null;
    }
  }

  /// 解析 FontStyle
  static FontStyle? _parseFontStyle(String? value) {
    switch (value) {
      case 'italic':
        return FontStyle.italic;
      case 'normal':
        return FontStyle.normal;
      default:
        return null;
    }
  }

  /// 解析 TextDecoration
  static TextDecoration? _parseTextDecoration(String? value) {
    switch (value) {
      case 'none':
        return TextDecoration.none;
      case 'underline':
        return TextDecoration.underline;
      case 'overline':
        return TextDecoration.overline;
      case 'lineThrough':
        return TextDecoration.lineThrough;
      default:
        return null;
    }
  }

  /// 解析 BoxFit
  static BoxFit? _parseBoxFit(String? value) {
    switch (value) {
      case 'fill':
        return BoxFit.fill;
      case 'cover':
        return BoxFit.cover;
      case 'contain':
        return BoxFit.contain;
      case 'fitWidth':
        return BoxFit.fitWidth;
      case 'fitHeight':
        return BoxFit.fitHeight;
      case 'none':
        return BoxFit.none;
      case 'scaleDown':
        return BoxFit.scaleDown;
      default:
        return null;
    }
  }

  /// 解析 ButtonStyle
  static ButtonStyle? _parseButtonStyle(Map<String, dynamic>? value) {
    if (value == null) return null;
    return ButtonStyle(
      backgroundColor:
          MaterialStateProperty.all(_parseColor(value['backgroundColor'])),
      foregroundColor:
          MaterialStateProperty.all(_parseColor(value['foregroundColor'])),
      padding: MaterialStateProperty.all(_parseEdgeInsets(value['padding'])),
      shape: MaterialStateProperty.all(_parseShapeBorder(value['shape'])),
    );
  }

  /// 解析 ShapeBorder
  static ShapeBorder? _parseShapeBorder(Map<String, dynamic>? value) {
    if (value == null) return null;
    return RoundedRectangleBorder(
      borderRadius: _parseBorderRadius(value['borderRadius']) ??
          BorderRadius.circular(4),
    );
  }

  /// 解析 FlexFit
  static FlexFit _parseFlexFit(String? value) {
    switch (value) {
      case 'loose':
        return FlexFit.loose;
      case 'tight':
        return FlexFit.tight;
      default:
        return FlexFit.loose;
    }
  }

  /// 根据名称获取 IconData
  static IconData _getIconData(String name) {
    switch (name) {
      case 'search':
        return Icons.search;
      case 'home':
        return Icons.home;
      case 'book':
        return Icons.book;
      case 'play':
        return Icons.play_arrow;
      case 'pause':
        return Icons.pause;
      case 'settings':
        return Icons.settings;
      case 'download':
        return Icons.download;
      case 'star':
        return Icons.star;
      case 'heart':
        return Icons.favorite;
      case 'share':
        return Icons.share;
      case 'info':
        return Icons.info;
      case 'arrowRight':
        return Icons.arrow_forward;
      case 'arrowLeft':
        return Icons.arrow_back;
      case 'check':
        return Icons.check;
      case 'close':
        return Icons.close;
      case 'volume':
        return Icons.volume_up;
      case 'image':
        return Icons.image;
      case 'refresh':
        return Icons.refresh;
      case 'plus':
        return Icons.add;
      case 'minus':
        return Icons.remove;
      case 'edit':
        return Icons.edit;
      case 'delete':
        return Icons.delete;
      default:
        return Icons.error;
    }
  }
}