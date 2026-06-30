import 'dart:convert';

import 'package:floor/floor.dart';
import 'package:flutter/cupertino.dart';

import '../vo/word.dart';

/// 单词表实体类
/// 存储单词的基本信息，包括单词ID、所属书籍ID和单词内容
@Entity(tableName: "word")
class WordPO {
  /// 主键ID
  @primaryKey
  int? id;

  /// 所属书籍ID
  String? book;

  /// 单词内容
  String? word;

  WordPO({
    this.id,
    this.word,
    this.book,
  });
}

/// 单词学习状态表实体类
/// 记录每个单词的学习状态、学习周期和下次复习时间
@Entity(tableName: "word_status")
class WordStatusPO {
  /// 主键ID
  @primaryKey
  int? id;

  /// 单词内容
  String? word;

  /// 学习状态：0=学习中，1=已完成，-1=已删除（熟词）
  int? status;

  /// 当前学习周期（艾宾浩斯记忆曲线的轮次）
  int? studyCycle;

  /// 下次复习时间（毫秒时间戳）
  int? nextReviewTime;

  /// 创建时间（毫秒时间戳）
  int? createTime;

  /// 更新时间（毫秒时间戳）
  int? updateTime;

  WordStatusPO({
    this.id,
    this.word,
    this.status,
    this.studyCycle,
    this.nextReviewTime,
    this.createTime,
    this.updateTime,
  });
}

/// 单词学习时间统计表实体类
/// 记录每个单词每次学习的时间详情
@Entity(tableName: "word_study_time_count")
class WordStudyTimeCountPO {
  /// 主键ID
  @primaryKey
  int? id;

  /// 学习开始时间（毫秒时间戳）
  int? startTime;

  /// 学习结束时间（毫秒时间戳）
  int? endTime;

  /// 单词内容
  String? word;

  /// 学习周期
  int? studyCycle;

  /// 是否正常播放完成（1=完成，0=未完成）
  int? playComplete;

  WordStudyTimeCountPO({
    this.id,
    this.startTime,
    this.endTime,
    this.word,
    this.studyCycle,
    this.playComplete,
  });
}

/// 学习时间统计表实体类
/// 记录整体学习时间段
@Entity(tableName: "study_time_count")
class StudyTimeCountPO {
  /// 主键ID
  @primaryKey
  int? id;

  /// 学习开始时间（毫秒时间戳）
  int? startTime;

  /// 学习结束时间（毫秒时间戳）
  int? endTime;

  StudyTimeCountPO({
    this.id,
    this.startTime,
    this.endTime,
  });
}
