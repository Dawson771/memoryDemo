import 'package:json_annotation/json_annotation.dart';

part 'plugin.g.dart';

/// 插件模型类
/// 定义插件的元数据和动态配置
@JsonSerializable()
class PluginModel {
  /// 插件唯一标识
  String id;

  /// 插件名称
  String name;

  /// 插件版本
  String version;

  /// 插件描述
  String description;

  /// 插件图标 URL
  String icon;

  /// Widget 配置（JSON 格式）
  Map<String, dynamic> widget;

  /// 动作配置（点击事件等）
  Map<String, PluginAction> actions;

  /// 是否已安装
  @JsonKey(ignore: true)
  bool installed = false;

  /// 安装时间
  @JsonKey(ignore: true)
  DateTime? installedAt;

  PluginModel({
    required this.id,
    required this.name,
    required this.version,
    required this.description,
    required this.icon,
    required this.widget,
    required this.actions,
  });

  factory PluginModel.fromJson(Map<String, dynamic> json) =>
      _$PluginModelFromJson(json);

  Map<String, dynamic> toJson() => _$PluginModelToJson(this);
}

/// 插件动作类型
enum PluginActionType {
  /// 跳转到指定路由
  @JsonValue('navigate')
  navigate,

  /// 调用方法
  @JsonValue('method')
  method,

  /// 弹出对话框
  @JsonValue('dialog')
  dialog,
}

/// 插件动作配置
@JsonSerializable()
class PluginAction {
  /// 动作类型
  PluginActionType type;

  /// 路由路径（navigate 类型）
  String? route;

  /// 方法名称（method 类型）
  String? method;

  /// 方法参数
  Map<String, dynamic>? params;

  /// 对话框标题（dialog 类型）
  String? dialogTitle;

  /// 对话框内容
  String? dialogContent;

  PluginAction({
    required this.type,
    this.route,
    this.method,
    this.params,
    this.dialogTitle,
    this.dialogContent,
  });

  factory PluginAction.fromJson(Map<String, dynamic> json) =>
      _$PluginActionFromJson(json);

  Map<String, dynamic> toJson() => _$PluginActionToJson(this);
}