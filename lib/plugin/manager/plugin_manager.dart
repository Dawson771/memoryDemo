import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:path_provider/path_provider.dart';

import '../model/plugin.dart';
import '../plugins/word_study_plugin.dart';
import '../sdk/plugin_interface.dart';

/// 插件管理器
/// 负责插件的下载、缓存、安装、卸载和加载
/// 支持两种插件模式：
/// 1. 内置插件（编译时集成，通过 SDK 接口调用）
/// 2. 动态插件（运行时下载，通过 JSON Widget 渲染）
class PluginManager {
  static PluginManager? _instance;

  factory PluginManager() {
    _instance ??= PluginManager._internal();
    return _instance!;
  }

  PluginManager._internal();

  final _storage = GetStorage();
  final _dio = Dio();
  late Directory _pluginDir;

  var installedPlugins = <PluginModel>[].obs;
  final _loadedPlugins = <String, IPlugin>{};

  /// 内置插件列表（编译时集成）
  final _builtInPlugins = <String, IPlugin>{
    'word_study': WordStudyPlugin(),
  };

  Future<void> init() async {
    var appDir = await getApplicationSupportDirectory();
    _pluginDir = Directory("${appDir.path}/plugins");
    if (!_pluginDir.existsSync()) {
      _pluginDir.createSync(recursive: true);
    }
    await _loadInstalledPlugins();
    await _initializeBuiltInPlugins();
  }

  /// 初始化内置插件
  Future<void> _initializeBuiltInPlugins() async {
    for (var plugin in _builtInPlugins.values) {
      if (!_loadedPlugins.containsKey(plugin.metadata.id)) {
        _loadedPlugins[plugin.metadata.id] = plugin;
      }
    }
  }

  Future<void> _loadInstalledPlugins() async {
    var pluginsData = _storage.read<List>('installed_plugins');
    if (pluginsData != null) {
      installedPlugins.value = pluginsData
          .map((item) => PluginModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }
  }

  Future<void> _saveInstalledPlugins() async {
    await _storage.write(
        'installed_plugins', installedPlugins.map((p) => p.toJson()).toList());
  }

  /// 获取所有可用插件（内置 + 动态）
  Future<List<IPlugin>> getAllPlugins() async {
    var plugins = <IPlugin>[];
    plugins.addAll(_builtInPlugins.values);
    return plugins;
  }

  /// 获取插件元数据列表（用于展示）
  Future<List<PluginMetadata>> getAllPluginMetadata() async {
    var plugins = await getAllPlugins();
    return plugins.map((p) => p.metadata).toList();
  }

  /// 获取已安装的插件实例
  IPlugin? getPlugin(String pluginId) {
    return _loadedPlugins[pluginId];
  }

  /// 加载插件
  /// [pluginId] 插件ID
  /// [context] Flutter上下文
  /// [config] 插件配置
  Future<IPlugin?> loadPlugin(String pluginId, BuildContext context,
      {Map<String, dynamic> config = const {}}) async {
    var plugin = _builtInPlugins[pluginId];
    if (plugin != null) {
      await plugin.initialize(context, config);
      await plugin.start();
      _loadedPlugins[pluginId] = plugin;
      return plugin;
    }

    return null;
  }

  /// 卸载插件
  Future<bool> uninstallPlugin(String pluginId) async {
    try {
      var plugin = installedPlugins.firstWhereOrNull((p) => p.id == pluginId);
      if (plugin != null) {
        installedPlugins.remove(plugin);
        await _saveInstalledPlugins();

        var file = File("${_pluginDir.path}/${pluginId}.json");
        if (file.existsSync()) {
          file.deleteSync();
        }
      }

      if (_loadedPlugins.containsKey(pluginId)) {
        await _loadedPlugins[pluginId]!.destroy();
        _loadedPlugins.remove(pluginId);
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// 获取插件卡片Widget
  Widget? getPluginCard(String pluginId, BuildContext context) {
    var plugin = _loadedPlugins[pluginId];
    if (plugin != null) {
      return plugin.buildCardWidget(context);
    }
    return null;
  }

  /// 获取插件主界面Widget
  Widget? getPluginWidget(String pluginId, BuildContext context) {
    var plugin = _loadedPlugins[pluginId];
    if (plugin != null) {
      return plugin.buildWidget(context);
    }
    return null;
  }

  /// 获取插件设置页面
  Widget? getPluginSettings(String pluginId, BuildContext context) {
    var plugin = _loadedPlugins[pluginId];
    if (plugin != null) {
      return plugin.buildSettingsWidget(context);
    }
    return null;
  }

  /// 获取插件统计数据
  Map<String, dynamic>? getPluginStatistics(String pluginId) {
    var plugin = _loadedPlugins[pluginId];
    if (plugin != null) {
      return plugin.getStatistics();
    }
    return null;
  }

  /// 执行插件方法
  Future<dynamic> executePluginMethod(
      String pluginId, String method, Map<String, dynamic> params) async {
    var plugin = _loadedPlugins[pluginId];
    if (plugin != null) {
      return await plugin.executeMethod(method, params);
    }
    throw Exception('Plugin not found: $pluginId');
  }

  /// 获取插件市场列表（模拟数据）
  Future<List<PluginModel>> getMarketPlugins() async {
    await Future.delayed(const Duration(milliseconds: 500));

    return [
      PluginModel(
        id: 'word_study',
        name: '单词学习',
        version: '1.0.0',
        description: '基于艾宾浩斯记忆曲线的单词学习插件',
        icon: 'https://picsum.photos/seed/word/64/64',
        widget: {},
        actions: {},
        installed: _builtInPlugins.containsKey('word_study'),
      ),
      PluginModel(
        id: 'word_search',
        name: '单词搜索',
        version: '1.0.0',
        description: '快速搜索单词释义和例句',
        icon: 'https://picsum.photos/seed/search/64/64',
        widget: {},
        actions: {},
      ),
      PluginModel(
        id: 'study_stats',
        name: '学习统计',
        version: '1.0.0',
        description: '查看学习进度和统计数据',
        icon: 'https://picsum.photos/seed/stats/64/64',
        widget: {},
        actions: {},
      ),
    ];
  }

  /// 下载插件
  Future<bool> downloadPlugin(
      PluginModel plugin, void Function(int)? onProgress) async {
    try {
      var url = 'https://example.com/plugins/${plugin.id}/plugin.json';
      var savePath = "${_pluginDir.path}/${plugin.id}.json";

      await _dio.download(
        url,
        savePath,
        onReceiveProgress: (received, total) {
          if (total > 0 && onProgress != null) {
            onProgress((received / total * 100).round());
          }
        },
      );

      var file = File(savePath);
      if (file.existsSync()) {
        plugin.installed = true;
        plugin.installedAt = DateTime.now();
        installedPlugins.add(plugin);
        await _saveInstalledPlugins();
        return true;
      }
      return false;
    } catch (e) {
      return _installMockPlugin(plugin);
    }
  }

  Future<bool> _installMockPlugin(PluginModel plugin) async {
    await Future.delayed(const Duration(milliseconds: 500));
    plugin.installed = true;
    plugin.installedAt = DateTime.now();
    installedPlugins.add(plugin);
    await _saveInstalledPlugins();
    return true;
  }

  PluginModel? getInstalledPlugin(String pluginId) {
    return installedPlugins.firstWhereOrNull((p) => p.id == pluginId);
  }

  void executeAction(PluginModel plugin, String actionId) {
    var action = plugin.actions[actionId];
    if (action == null) return;

    switch (action.type) {
      case PluginActionType.navigate:
        if (action.route != null) {
          Get.toNamed(action.route!);
        }
        break;
      case PluginActionType.method:
        _executeMethod(action.method, action.params);
        break;
      case PluginActionType.dialog:
        Get.dialog(
          AlertDialog(
            title: Text(action.dialogTitle ?? '提示'),
            content: Text(action.dialogContent ?? ''),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('确定'),
              ),
            ],
          ),
        );
        break;
    }
  }

  void _executeMethod(String? methodName, Map<String, dynamic>? params) {
    switch (methodName) {
      case 'refresh_study':
        break;
      default:
        break;
    }
  }

  bool isInstalled(String pluginId) {
    return installedPlugins.any((p) => p.id == pluginId) ||
        _builtInPlugins.containsKey(pluginId);
  }
}