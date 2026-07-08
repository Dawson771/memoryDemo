import 'package:flutter/widgets.dart';

/// 插件生命周期状态
enum PluginState {
  initialized,
  started,
  paused,
  stopped,
  destroyed,
}

/// 插件元数据
class PluginMetadata {
  /// 插件唯一标识
  final String id;

  /// 插件名称
  final String name;

  /// 插件版本
  final String version;

  /// 插件描述
  final String description;

  /// 插件图标
  final String icon;

  /// 插件作者
  final String? author;

  /// 插件主页
  final String? homepage;

  /// 是否需要权限
  final List<String> permissions;

  /// 插件类型
  final PluginType type;

  PluginMetadata({
    required this.id,
    required this.name,
    required this.version,
    required this.description,
    required this.icon,
    this.author,
    this.homepage,
    this.permissions = const [],
    this.type = PluginType.feature,
  });
}

/// 插件类型
enum PluginType {
  /// 功能插件（提供完整功能）
  feature,

  /// 组件插件（提供 UI 组件）
  widget,

  /// 数据插件（提供数据源）
  data,

  /// 工具插件（提供工具方法）
  utility,
}

/// 插件事件类型
enum PluginEvent {
  /// 插件启动
  started,

  /// 插件暂停
  paused,

  /// 插件停止
  stopped,

  /// 数据更新
  dataUpdated,

  /// 错误发生
  error,
}

/// 插件事件数据
class PluginEventData {
  final PluginEvent event;
  final Map<String, dynamic>? data;

  PluginEventData(this.event, {this.data});
}

/// 插件配置项
class PluginConfig {
  /// 配置键
  final String key;

  /// 配置名称
  final String name;

  /// 配置描述
  final String description;

  /// 配置类型
  final PluginConfigType type;

  /// 默认值
  final dynamic defaultValue;

  /// 可选值（用于枚举类型）
  final List<dynamic>? options;

  /// 是否必填
  final bool required;

  PluginConfig({
    required this.key,
    required this.name,
    required this.description,
    required this.type,
    this.defaultValue,
    this.options,
    this.required = false,
  });
}

/// 配置类型
enum PluginConfigType {
  string,
  int,
  double,
  bool,
  enum_,
  list,
  map,
}

/// 插件 API 接口
/// 所有插件必须实现此接口
abstract class IPlugin {
  /// 插件元数据
  PluginMetadata get metadata;

  /// 插件状态
  PluginState get state;

  /// 插件配置项
  List<PluginConfig> get configs;

  /// 初始化插件
  /// [context] Flutter 上下文
  /// [config] 插件配置
  Future<void> initialize(BuildContext context, Map<String, dynamic> config);

  /// 启动插件
  Future<void> start();

  /// 暂停插件
  Future<void> pause();

  /// 停止插件
  Future<void> stop();

  /// 销毁插件
  Future<void> destroy();

  /// 获取插件主 Widget
  /// [context] Flutter 上下文
  /// 返回值：插件的主界面 Widget
  Widget buildWidget(BuildContext context);

  /// 获取插件卡片 Widget（用于首页展示）
  /// [context] Flutter 上下文
  /// 返回值：插件的卡片 Widget
  Widget buildCardWidget(BuildContext context);

  /// 获取插件设置页面
  /// [context] Flutter 上下文
  /// 返回值：插件的设置页面 Widget，如果不需要设置则返回 null
  Widget? buildSettingsWidget(BuildContext context);

  /// 获取插件统计数据
  /// 返回值：插件的统计信息 Map
  Map<String, dynamic> getStatistics();

  /// 执行插件方法
  /// [method] 方法名称
  /// [params] 方法参数
  /// 返回值：方法执行结果
  Future<dynamic> executeMethod(String method, Map<String, dynamic> params);

  /// 事件流（用于监听插件事件）
  Stream<PluginEventData> get onEvent;
}