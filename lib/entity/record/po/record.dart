import 'package:floor/floor.dart';
import 'package:flutter/cupertino.dart';

/// 学习记录表实体类
/// 记录各种类型的学习记录，包括单词、章节、单元等
@Entity(tableName: "record")
class RecordPO {
  /// 主键ID
  @primaryKey
  String? id;

  /// 记录类型：word（单词）、section（章节）、unit（单元）
  String? type;

  /// 所属书籍名称
  String? book;

  /// 序号（单词序号、章节序号等）
  int? number;

  /// 学习时长（毫秒）
  int? time;

  /// 开始学习时间（毫秒时间戳）
  int? startTime;

  /// 结束学习时间（毫秒时间戳）
  int? endTime;

  /// 复习轮次/循环次数
  int? recycle;

  /// 是否完成
  bool? complete;

  RecordPO({
    this.id,
    this.type,
    this.book,
    this.number,
    this.time,
    this.recycle,
    this.complete,
    this.startTime,
    this.endTime,
  });
}

