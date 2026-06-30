import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart';
import 'package:flutter/services.dart';
import 'package:cryptography/cryptography.dart';

import 'relation.dart';

/// 单词数据模型（字典数据结构）
/// 包含单词的完整信息：ID、拼写、发音、释义、助记、例句等
class Word {
  /// 单词ID
  String? id;

  /// 单词拼写
  String? word;

  /// 美式发音
  String? usVoice;

  /// 英式发音
  String? ukVoice;

  /// 单词释义
  String? means;

  /// 助记方法
  String? helper;

  /// 例句列表
  List<Sentence>? sentences;

  /// 转换为Map
  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'word': this.word,
      'usVoice': this.usVoice,
      'ukVoice': this.ukVoice,
      'means': this.means,
      'helper': this.helper,
      'sentences': this.sentences,
    };
  }

  /// 从Map创建Word对象
  factory Word.fromMap(Map<String, dynamic> map) {
    var sentences = map['sentences'] as List<dynamic>;
    return Word(
      id: map['id'] as String?,
      word: map['word'] as String?,
      usVoice: map['usVoice'] as String?,
      ukVoice: map['ukVoice'] as String?,
      means: map['means'] as String?,
      helper: map['helper'] as String?,
      sentences: sentences.map((e) {
        return Sentence(
          sentence: e["sentence"] as String,
          sentenceCn: e["sentenceCn"] as String,
        );
      }).toList(),
    );
  }

  Word({
    this.id,
    this.word,
    this.usVoice,
    this.ukVoice,
    this.means,
    this.helper,
    this.sentences,
  });
}

/// 例句数据模型
class Sentence {
  /// 英文例句
  String? sentence;

  /// 例句中文翻译
  String? sentenceCn;

  Sentence({
    this.sentence,
    this.sentenceCn,
  });
}

/// 单词书数据模型
class Book {
  /// 书籍ID
  String? id;

  /// 书籍名称
  String? name;

  /// 书籍包含的单词列表
  List<Word>? words;

  Book({
    this.id,
    this.name,
    this.words,
  });
}

/// 根据单词映射和关系数据构建书籍列表
/// [wordMap] 单词映射表（key为单词ID）
/// 返回所有书籍及其包含的单词列表
Future<List<Book>> readBookMap(Map<String, Word> wordMap) async {
  var res = <String, Book>{};
  for (var id in bookMap.keys) {
    var book = Book(id: id.toString(), name: bookMap[id], words: []);
    res[id.toString()] = book;
  }
  var relations = relation.split(",");
  for (var r in relations) {
    var arr = r.split(">");
    var wordId = arr[0];
    var bookId = arr[1];
    var word = wordMap[wordId];
    var book = res[bookId];
    if (word != null) {
      book?.words?.add(word);
    }
  }
  return res.values.toList();
}

/// 读取并解析所有单词数据
/// 从加密的字典文件中读取并解析，返回单词映射表（key为单词ID）
Future<Map<String, Word>> readWordMap() async {
  var wordMap = <String, Word>{};
  var readTextTime = DateTime.now();
  var json = await _readWordsText();
  var convertJsonTime = DateTime.now();
  List<dynamic> wordsJson = const JsonDecoder().convert(json);
  for (var value in wordsJson) {
    var word = Word.fromMap(value);
    wordMap[word.id!] = word;
  }
  var endTime = DateTime.now();
  print(
      "read text use time:${convertJsonTime.millisecondsSinceEpoch - readTextTime.millisecondsSinceEpoch} "
      "\n convert json use time:${endTime.millisecondsSinceEpoch - convertJsonTime.millisecondsSinceEpoch}");
  return wordMap;
}

/// 解密字典数据
/// 根据平台使用不同的解密库（移动端使用cryptography，桌面端使用encrypt）
/// [src] 加密的原始数据
/// 返回解密后的字节数据
Future<List<int>> _decrypt(Uint8List src) async {
  final key = Key.fromUtf8('7duxouJsdlJASJ!SdsfO=sdf23joj&sd');
  var iv = IV.fromLength(16);
  if (Platform.isAndroid || Platform.isIOS) {
    var aes = AesCtr.with256bits(macAlgorithm: Hmac.sha256());
    var secretKey = await aes.newSecretKeyFromBytes(key.bytes);
    final correctMac = await aes.macAlgorithm.calculateMac(
      src,
      secretKey: secretKey,
      nonce: iv.bytes,
      aad: [],
    );
    var secretBox = SecretBox(src,nonce: iv.bytes,mac:correctMac);
    var ret = await aes.decrypt(secretBox, secretKey: secretKey);
    return ret;
  } else {
    var aes = AES(key);
    return aes.decrypt(Encrypted(src), iv: iv);
  }
}

/// 读取字典文件文本内容
/// 流程：读取assets文件 -> AES解密 -> gzip解压 -> UTF8解码
/// 返回解密解压后的JSON字符串
Future<String> _readWordsText() async {
  var readBuffTime = DateTime.now().millisecondsSinceEpoch;
  ByteData data = await rootBundle.load("assets/dict.db");
  var buff = data.buffer.asUint8List();
  var decryptTime = DateTime.now().millisecondsSinceEpoch;
  var decode = await _decrypt(buff);
  var gzipTime = DateTime.now().millisecondsSinceEpoch;
  var uzip = gzip.decoder.convert(decode);
  var textTime = DateTime.now().millisecondsSinceEpoch;
  var utf = utf8.decoder.convert(uzip);
  var endTime = DateTime.now().millisecondsSinceEpoch;
  print('read file use time:${decryptTime - readBuffTime}');
  print('decrypt file use time:${gzipTime - decryptTime}');
  print('gzip file use time:${textTime - gzipTime}');
  print('convert text use time:${endTime - textTime}');
  return utf;
}
