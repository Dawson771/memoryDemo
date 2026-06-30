import 'dart:convert';
import 'dart:io';

import 'package:encrypt/encrypt.dart';
import 'package:flutter/services.dart';

/// 读取并解密字典数据文件
/// 从 assets/dict.db 读取加密的字典数据，使用AES解密后再通过gzip解压，最终返回JSON字符串
Future<String> wordsText() async {
  ByteData data = await rootBundle.load("assets/dict.db");
  var buff = data.buffer.asUint8List();
  final key = Key.fromUtf8('7duxouJsdlJASJ!SdsfO=sdf23joj&sd');
  var iv = IV.fromLength(16);
  final encrypter = Encrypter(AES(key));
  var decode = encrypter.decryptBytes(Encrypted(buff), iv: iv);
  var uzip = gzip.decoder.convert(decode);
  var utf = utf8.decoder.convert(uzip);
  return utf;
}
