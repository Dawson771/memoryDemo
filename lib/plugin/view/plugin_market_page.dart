import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../manager/plugin_manager.dart';
import '../model/plugin.dart';

/// 插件市场页面
/// 展示可用插件列表，支持下载和安装
class PluginMarketPage extends StatelessWidget {
  PluginMarketPage({Key? key}) : super(key: key);

  final PluginManager _manager = PluginManager();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('插件市场'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: FutureBuilder<List<PluginModel>>(
        future: _manager.getMarketPlugins(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('暂无插件'));
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 16),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var plugin = snapshot.data![index];
              return _buildPluginCard(context, plugin);
            },
          );
        },
      ),
    );
  }

  /// 构建插件卡片
  Widget _buildPluginCard(BuildContext context, PluginModel plugin) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 图标
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              plugin.icon,
              width: 64,
              height: 64,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          // 信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plugin.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  plugin.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.withOpacity(0.7),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '版本: ${plugin.version}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
          // 操作按钮
          Obx(() {
            if (_manager.isInstalled(plugin.id)) {
              return ElevatedButton(
                onPressed: () => _uninstallPlugin(plugin),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.withOpacity(0.1),
                  foregroundColor: Colors.grey,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: const Text('已安装'),
              );
            }
            return ElevatedButton(
              onPressed: () => _downloadPlugin(context, plugin),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrangeAccent,
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: const Text('下载'),
            );
          }),
        ],
      ),
    );
  }

  /// 下载插件
  void _downloadPlugin(BuildContext context, PluginModel plugin) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('下载插件'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              const Text('正在下载...'),
              Obx(() {
                var progress = 0.obs;
                return Text('进度: ${progress.value}%');
              }),
            ],
          ),
        );
      },
    );

    _manager.downloadPlugin(plugin, (progress) {}).then((success) {
      Get.back();
      if (success) {
        Get.snackbar(
          '下载成功',
          '${plugin.name} 已安装',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          '下载失败',
          '请检查网络连接',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    });
  }

  /// 卸载插件
  void _uninstallPlugin(PluginModel plugin) {
    Get.dialog(
      AlertDialog(
        title: const Text('确认卸载'),
        content: Text('确定要卸载 ${plugin.name} 吗？'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              _manager.uninstallPlugin(plugin.id);
              Get.back();
              Get.snackbar(
                '已卸载',
                '${plugin.name} 已卸载',
                backgroundColor: Colors.grey,
                colorText: Colors.white,
              );
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}