import 'dart:io';

import 'package:flutter/services.dart';

/// 将assets资源文件释放到本地文件
/// [assetsName] assets资源路径
/// [file] 目标文件
Future<void> releaseAssetsToFile(String assetsName,File file)async{
  ByteData data = await rootBundle.load(assetsName);
  file.writeAsBytes(data.buffer.asUint8List());
}