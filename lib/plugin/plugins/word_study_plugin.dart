import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../controller/app/app.dart';
import '../../controller/home/home.dart';
import '../../controller/search/search.dart';
import '../../controller/study/study.dart';
import '../../service/app/app.dart';
import '../../service/study/study.dart';
import '../../view/home/home.dart';
import '../../view/search/search.dart';
import '../../view/study/study.dart';
import '../sdk/plugin_interface.dart';

/// 单词学习插件
/// 实现 IPlugin 接口，封装现有的单词学习功能
class WordStudyPlugin implements IPlugin {
  late PluginMetadata _metadata;
  PluginState _state = PluginState.initialized;
  final _eventController = StreamController<PluginEventData>.broadcast();
  BuildContext? _context;

  /// 应用服务实例
  late AppService _appService;

  /// 学习服务实例
  late StudyService _studyService;

  @override
  PluginMetadata get metadata => _metadata;

  @override
  PluginState get state => _state;

  @override
  List<PluginConfig> get configs => _getConfigs();

  @override
  Stream<PluginEventData> get onEvent => _eventController.stream;

  WordStudyPlugin() {
    _metadata = PluginMetadata(
      id: 'word_study',
      name: '单词学习',
      version: '1.0.0',
      description: '基于艾宾浩斯记忆曲线的单词学习插件，支持自动播放、循环队列、多词库切换',
      icon: 'https://picsum.photos/seed/word/64/64',
      author: 'MemoryDemo Team',
      homepage: 'https://example.com',
      type: PluginType.feature,
    );
  }

  /// 获取插件配置项
  List<PluginConfig> _getConfigs() {
    return [
      PluginConfig(
        key: 'daily_word_count',
        name: '每日词汇量',
        description: '每天学习的单词数量',
        type: PluginConfigType.int,
        defaultValue: 50,
        options: [10, 20, 30, 50, 100, 200],
      ),
      PluginConfig(
        key: 'think_wait_time',
        name: '思考等待时间',
        description: '单词展示后等待用户思考的时间（秒）',
        type: PluginConfigType.int,
        defaultValue: 3,
        options: [0, 1, 2, 3, 5, 10, 15, 20],
      ),
      PluginConfig(
        key: 'read_wait_time',
        name: '阅读等待时间',
        description: '显示释义后等待的时间（秒）',
        type: PluginConfigType.int,
        defaultValue: 5,
        options: [1, 2, 3, 5, 10, 15, 20],
      ),
      PluginConfig(
        key: 'loop_queue_size',
        name: '循环队列大小',
        description: '同时在队列中循环的单词数量',
        type: PluginConfigType.int,
        defaultValue: 5,
        options: [1, 2, 3, 5, 10, 15, 20],
      ),
      PluginConfig(
        key: 'auto_pass',
        name: '自动 PASS',
        description: '阅读时间结束后自动 PASS',
        type: PluginConfigType.bool,
        defaultValue: false,
      ),
    ];
  }

  @override
  Future<void> initialize(BuildContext context, Map<String, dynamic> config) async {
    _context = context;

    try {
      // 初始化服务（如果尚未初始化）
      if (!Get.isRegistered<AppService>()) {
        await _initializeServices();
      } else {
        _appService = Get.find<AppService>();
        _studyService = Get.find<StudyService>();
      }

      // 应用配置
      _applyConfig(config);

      _state = PluginState.initialized;
      _emitEvent(PluginEvent.started);
    } catch (e) {
      _state = PluginState.destroyed;
      _emitEvent(PluginEvent.error, {'error': e.toString()});
      rethrow;
    }
  }

  /// 初始化服务
  Future<void> _initializeServices() async {
    _appService = AppService();
    _studyService = StudyService();
    Get.put(_appService);
    Get.put(_studyService);
    Get.put(AppController());
    Get.put(HomeController());
    Get.put(StudyController());
    Get.put(WordSearchController());
  }

  /// 应用配置
  void _applyConfig(Map<String, dynamic> config) {
    if (config.containsKey('daily_word_count')) {
      _appService.dailyWantCount.value = config['daily_word_count'] as int;
    }
    if (config.containsKey('think_wait_time')) {
      _appService.thinkWaitTime.value = config['think_wait_time'] as int;
    }
    if (config.containsKey('read_wait_time')) {
      _appService.readWaitTime.value = config['read_wait_time'] as int;
    }
    if (config.containsKey('loop_queue_size')) {
      _appService.loopQueueSize.value = config['loop_queue_size'] as int;
    }
    if (config.containsKey('auto_pass')) {
      _appService.autoPass.value = config['auto_pass'] as bool;
    }
  }

  @override
  Future<void> start() async {
    if (_state != PluginState.initialized) {
      throw Exception('Plugin not initialized');
    }
    _state = PluginState.started;
    _emitEvent(PluginEvent.started);
  }

  @override
  Future<void> pause() async {
    if (_state != PluginState.started) {
      throw Exception('Plugin not started');
    }
    _state = PluginState.paused;
    _emitEvent(PluginEvent.paused);
  }

  @override
  Future<void> stop() async {
    if (_state != PluginState.started && _state != PluginState.paused) {
      throw Exception('Plugin not running');
    }
    _state = PluginState.stopped;
    _emitEvent(PluginEvent.stopped);
  }

  @override
  Future<void> destroy() async {
    _state = PluginState.destroyed;
    _eventController.close();
  }

  @override
  Widget buildWidget(BuildContext context) {
    return const StudyPage();
  }

  @override
  Widget buildCardWidget(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () => Get.toNamed('/study'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.book,
                    color: Colors.deepOrangeAccent,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '单词学习',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Obx(() {
                var studyService = Get.find<StudyService>();
                return Text(
                  '今日待复习: ${studyService.waitingCount.value} 词',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.withOpacity(0.7),
                  ),
                );
              }),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Get.toNamed('/study'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrangeAccent,
                      ),
                      child: const Text('开始学习'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.toNamed('/search'),
                      child: const Text('搜索单词'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget? buildSettingsWidget(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          _buildSettingItem(
            '每日词汇量',
            _appService.dailyWantCount.value.toString(),
            () {
              _showConfigDialog(
                context,
                '每日词汇量',
                _appService.dailyWantCount.value,
                [10, 20, 30, 50, 100, 200],
                (value) {
                  _appService.dailyWantCount.value = value;
                },
              );
            },
          ),
          _buildSettingItem(
            '思考等待时间',
            '${_appService.thinkWaitTime.value}秒',
            () {
              _showConfigDialog(
                context,
                '思考等待时间',
                _appService.thinkWaitTime.value,
                [0, 1, 2, 3, 5, 10, 15, 20],
                (value) {
                  _appService.thinkWaitTime.value = value;
                },
              );
            },
          ),
          _buildSettingItem(
            '阅读等待时间',
            '${_appService.readWaitTime.value}秒',
            () {
              _showConfigDialog(
                context,
                '阅读等待时间',
                _appService.readWaitTime.value,
                [1, 2, 3, 5, 10, 15, 20],
                (value) {
                  _appService.readWaitTime.value = value;
                },
              );
            },
          ),
          _buildSettingItem(
            '循环队列大小',
            _appService.loopQueueSize.value.toString(),
            () {
              _showConfigDialog(
                context,
                '循环队列大小',
                _appService.loopQueueSize.value,
                [1, 2, 3, 5, 10, 15, 20],
                (value) {
                  _appService.loopQueueSize.value = value;
                },
              );
            },
          ),
          _buildSettingItem(
            '自动 PASS',
            _appService.autoPass.value ? '开启' : '关闭',
            () {
              _appService.autoPass.value = !_appService.autoPass.value;
            },
          ),
        ],
      ),
    );
  }

  /// 构建设置项
  Widget _buildSettingItem(String title, String value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey, width: 0.5),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16),
            ),
            Row(
              children: [
                Text(
                  value,
                  style: TextStyle(color: Colors.grey.withOpacity(0.7)),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_ios, size: 16),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 显示配置对话框
  void _showConfigDialog(
      BuildContext context,
      String title,
      int currentValue,
      List<int> options,
      void Function(int) onSelect,
      ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: options
                .map((option) => RadioListTile(
              value: option,
              groupValue: currentValue,
              title: Text(option.toString()),
              onChanged: (value) {
                onSelect(value as int);
                Navigator.pop(context);
              },
            ))
                .toList(),
          ),
        );
      },
    );
  }

  @override
  Map<String, dynamic> getStatistics() {
    var appService = Get.find<AppService>();
    var studyService = Get.find<StudyService>();

    return {
      'today_new': appService.todayNewCount.value,
      'today_pass': appService.todayPassCount.value,
      'today_review': appService.todayReviewCount.value,
      'waiting_review': studyService.waitingCount.value,
      'total_learned': appService.totalLearnedCount.value,
      'total_pass': appService.totalPassCount.value,
      'study_duration': appService.studyDuration.value,
      'accuracy': appService.accuracy.value,
    };
  }

  @override
  Future<dynamic> executeMethod(String method, Map<String, dynamic> params) async {
    switch (method) {
      case 'start_study':
        Get.toNamed('/study');
        return {'success': true};
      case 'search_word':
        if (params.containsKey('keyword')) {
          Get.toNamed('/search', arguments: params['keyword']);
        } else {
          Get.toNamed('/search');
        }
        return {'success': true};
      case 'get_statistics':
        return getStatistics();
      case 'pass_word':
        if (params.containsKey('word_id')) {
          var studyService = Get.find<StudyService>();
          await studyService.passWord(params['word_id']);
          return {'success': true};
        }
        return {'success': false, 'error': 'word_id required'};
      case 'reset_progress':
        var appService = Get.find<AppService>();
        await appService.resetProgress();
        return {'success': true};
      default:
        throw Exception('Method not found: $method');
    }
  }

  /// 发送事件
  void _emitEvent(PluginEvent event, [Map<String, dynamic>? data]) {
    _eventController.add(PluginEventData(event, data: data));
  }
}