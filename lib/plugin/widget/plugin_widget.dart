import 'package:flutter/material.dart';

import '../manager/plugin_manager.dart';
import '../model/plugin.dart';
import '../parser/json_widget_parser.dart';

/// 插件展示 Widget
/// 根据插件配置动态渲染 Widget
class PluginWidget extends StatelessWidget {
  final PluginModel plugin;

  const PluginWidget({
    Key? key,
    required this.plugin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return JsonWidgetParser.parse(plugin.widget, onAction: (actionId) {
      PluginManager().executeAction(plugin, actionId);
    });
  }
}