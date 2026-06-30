import 'package:memorydemo/dao/word/word.dart';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'dart:async';

import '../entity/word/po/word.dart';

part 'floor.g.dart';

/// Floor数据库配置
/// 定义数据库版本和包含的实体表
/// v1版本包含4张表：单词表、单词状态表、学习时间表、单词学习时间表
@Database(
  version: 1,
  entities: [
    WordPO,
    WordStatusPO,
    StudyTimeCountPO,
    WordStudyTimeCountPO,
  ],
)
abstract class AppDatabase extends FloorDatabase {
  /// 单词数据访问对象
  WordDao get wordDao;
}
