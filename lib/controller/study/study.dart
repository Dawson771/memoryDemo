import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:memorydemo/dao/word/word.dart';
import 'package:memorydemo/entity/word/vo/word.dart';
import 'package:memorydemo/service/app/app.dart';
import 'package:memorydemo/service/study/study.dart';
import 'package:memorydemo/service/word/word.dart';
import 'package:memorydemo/view/review/list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:wakelock/wakelock.dart';

import '../../entity/word/po/word.dart';
import '../../util/audio.dart';

/// 播放回调函数类型定义
typedef Future<void> PlayCallback(Player player);

/// 单词播放器类
/// 管理单词学习的播放循环，包括思考阶段和展示阶段
class Player {
  /// 是否开始播放
  bool _start = false;

  /// 是否正在播放中
  bool _playing = false;

  /// 释义展示时间（秒）
  int showTime;

  /// 思考等待时间（秒）
  int thinkTime;

  /// 开始时间（毫秒时间戳）
  int startTime = DateTime.now().millisecondsSinceEpoch;

  /// 停止时间（毫秒时间戳）
  int? stopTime;

  /// 当前单词的学习状态
  WordStatusPO? wordStatus;

  /// 思考阶段开始回调
  PlayCallback thinkStart;

  /// 思考阶段结束回调
  PlayCallback thinkEnd;

  /// 展示阶段开始回调
  PlayCallback showStart;

  /// 展示阶段结束回调
  PlayCallback showEnd;

  /// 播放结束回调
  PlayCallback onEnd;

  /// 是否正常播放完成
  bool playComplete = true;

  /// 创建播放器并开始播放
  Player.create({
    required this.thinkStart,
    required this.thinkEnd,
    required this.showStart,
    required this.showEnd,
    required this.onEnd,
    this.showTime = 7,
    this.thinkTime = 3,
  }) {
    start();
  }

  /// 开始播放
  void start() async {
    if (!_start) {
      //等待playing结束
      for (;;) {
        await const Duration(milliseconds: 100).delay();
        if (_playing == false) {
          break;
        }
      }
      _start = true;
      _playing = true;
      _loop();
    }
  }

  /// 停止播放
  void stop() async {
    if (_start == false) {
      return;
    }
    stopTime = DateTime.now().millisecondsSinceEpoch;
    _start = false;
    for (;;) {
      await const Duration(milliseconds: 100).delay();
      if (_playing == false) {
        break;
      }
    }
  }

  /// 播放主循环
  /// 流程：思考开始 -> 思考等待 -> 思考结束 -> 展示开始 -> 展示等待 -> 展示结束 -> 结束回调
  void _loop() async {
    for (; _start;) {
      startTime = DateTime.now().millisecondsSinceEpoch;
      playComplete = true;
      if (_start) {
        await thinkStart(this);
      }
      if (_start) {
        await Duration(seconds: thinkTime).delay();
      }
      if (_start) {
        await thinkEnd(this);
      }
      if (_start) {
        await showStart(this);
      }
      if (_start) {
        await Duration(seconds: showTime).delay();
      }
      if (_start) {
        await showEnd(this);
      }
      if (!_start) {
        playComplete = false;
      }
      await onEnd(this);
    }
    _playing = false;
    _start = false;
  }
}

/// 学习时间记录器
/// 记录整体学习时间段
class _StudyTimeRecorder {
  /// 开始时间
  int? startTime;

  /// 结束时间
  int? endTime;

  /// 学习服务实例
  StudyService service;

  /// 记录开始时间
  void recordStart() {
    startTime = DateTime.now().millisecondsSinceEpoch;
  }

  /// 记录结束时间并保存学习记录
  void recordEnd() {
    if (startTime == null) {
      return;
    }
    endTime = DateTime.now().millisecondsSinceEpoch;
    //记录
    service.addStudyRecord(startTime!, endTime!);
    startTime = DateTime.now().millisecondsSinceEpoch;
  }

  _StudyTimeRecorder({
    this.startTime,
    this.endTime,
    required this.service,
  });
}

/// 学习页面控制器
/// 管理学习页面的所有状态和交互，包括播放控制、单词管理、学习设置等
class StudyController extends GetxController with WidgetsBindingObserver {
  /// 当前学习的单词
  var word = Rx<WordVO?>(null);

  /// 今日学习通过的单词数量
  var dailyStudyCount = 0.obs;

  /// 需要复习的单词数量
  var reviewCount = 0.obs;

  /// 是否处于思考阶段
  var thinking = false.obs;

  /// 是否正在播放
  var playing = false.obs;

  /// 控制按钮是否可用
  var controlEnable = true.obs;

  /// 播放按钮是否可用
  var playButtonEnable = true.obs;

  /// 当前播放的单词索引
  var playingIndex = 0;

  /// 播放队列中的单词列表
  var playingWords = <WordVO>[];

  /// 学习时间记录器
  var timeRecord = _StudyTimeRecorder(service: Get.find());

  /// 应用服务实例
  AppService appService = Get.find();

  /// 学习服务实例
  StudyService studyService = StudyService();

  /// 单词数据访问对象
  WordDao wordDao = Get.find();

  /// 单词播放器
  Player? player;

  /// 当前单词的学习状态
  var wordStatus = Rx<WordStatusPO?>(null);

  /// 今日学习时间
  var studyTime = "0分钟".obs;

  /// 每日目标学习数量
  var dailyWantCount = 0.obs;

  /// 思考等待时间（秒）
  var thinkWaitTime = 1.obs;

  /// 阅读/展示等待时间（秒）
  var readWaitTime = 7.obs;

  /// 循环队列单词数量
  var queueCount = 4.obs;

  /// 是否自动通过单词
  var autoPass = false.obs;

  /// 单词播放次数记录（用于自动pass逻辑）
  var playCount = <String, int>{};

  /// 是否自动旋转（预留功能）
  get autoRotating => false;

  /// 监听应用生命周期变化
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        timeRecord.recordStart();
        break;
      case AppLifecycleState.paused:
        stopPlay();
        timeRecord.recordEnd();
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  void onInit() {
    super.onInit();
    _init();
    WidgetsBinding.instance?.addObserver(this);
    timeRecord.recordStart();
    //屏幕常亮
    Wakelock.enable();
  }

  /// 初始化学习页面
  Future<void> _init() async {
    await fetchOptions();
    await fetchWords();
    await fetchCount();
    await startPlay();
  }

  /// 获取学习配置选项并设置监听
  Future<void> fetchOptions() async {
    appService.readOptions();
    dailyWantCount.value = appService.dailyWantCount;
    thinkWaitTime.value = appService.thinkWaitTime;
    readWaitTime.value = appService.readWaitTime;
    queueCount.value = appService.queueCount;
    autoPass.value = appService.autoPass;
    autoPass.listen((value) {
      appService.autoPass = value;
      appService.saveOptions();
    });
    dailyWantCount.listen((value) {
      appService.dailyWantCount = value;
      appService.saveOptions();
    });
    thinkWaitTime.listen((value) {
      appService.thinkWaitTime = value;
      appService.saveOptions();
    });
    readWaitTime.listen((value) {
      appService.readWaitTime = value;
      appService.saveOptions();
    });
    queueCount.listen((value) {
      appService.queueCount = value;
      appService.saveOptions();
    });
  }

  @override
  void onClose() {
    Wakelock.disable();
    timeRecord.recordEnd();
    WidgetsBinding.instance?.removeObserver(this);
    super.onClose();
    stopPlay();
  }

  /// 获取学习队列单词
  Future<void> fetchWords() async {
    var studyQueueMaxCount = appService.queueCount;
    var words = await studyService.fetchStudyQueueWords(studyQueueMaxCount);
    playingWords = words;
  }

  /// 获取下一个单词替换指定位置的单词
  Future<void> fetchNextWord(int index) async {
    var word = await studyService.fetchNextWord();
    if (word != null) {
      playingWords[index] = word;
      playingIndex++;
      if (playingIndex > playingWords.length) {
        playingIndex = 0;
      }
    } else {
      playingWords.removeAt(index);
    }
  }

  /// 停止播放
  Future<void> stopPlay() async {
    if (!playButtonEnable.value) {
      return;
    }
    thinking.value = false;
    playButtonEnable.value = false;
    player?.stop();
    playing.value = false;
    playButtonEnable.value = true;
  }

  /// 开始播放
  Future<void> startPlay() async {
    if (!playButtonEnable.value) {
      return;
    }
    playButtonEnable.value = false;
    player?.stop();
    playing.value = true;
    player = Player.create(
      thinkTime: thinkWaitTime.value,
      showTime: readWaitTime.value,
      thinkStart: (Player player) async {
        thinking.value = true;
        wordStatus.value = null;
        //取词播放
        var index = playingIndex;
        var arr = playingWords;
        if (index >= arr.length) {
          playingIndex = index = 0;
        }
        if (index < arr.length) {
          word.value = arr[index];
          var wordId = arr[index].wordId;
          if (wordId != null) {
            player.wordStatus = await wordDao.queryWordStatus(wordId);
            wordStatus.value = player.wordStatus;
          }
          await playWordSound(word.value?.word, 1);
        } else {
          word.value = null;
          wordStatus.value = null;
          stopPlay();
        }
        //重设
        player.showTime = readWaitTime.value;
        //如果是复习状态，并且是自动pass状态，则减少showTime
        var cycle = player.wordStatus?.studyCycle;
        if (cycle != null && readWaitTime.value > 0) {
          if (cycle >= 1) {
            // 复习轮数越高，复习时间越短
            player.showTime = (readWaitTime.value * (1 - cycle / 8)).toInt();
            if (player.showTime < 1) {
              player.showTime = 1;
            }
          }
        }
      },
      thinkEnd: (Player player) async {
        thinking.value = false;
      },
      showStart: (Player player) async {
        //显示释义
      },
      showEnd: (Player player) async {
        if (appService.autoPass == true) {
          var key = player.wordStatus?.word ?? "";
          var wordPlayCount = playCount[key] ?? 0;
          wordPlayCount++;
          playCount[key] = wordPlayCount;
          var cycle = player.wordStatus?.studyCycle ?? 0;
          //循环次数减少
          if (wordPlayCount > 3 ||
              (cycle == 1 && wordPlayCount == 2) ||
              cycle > 1) {
            return;
          }
        }
        playingIndex++;
        if (playingIndex >= playingWords.length) {
          playingIndex = 0;
        }
        fetchCount();
      },
      onEnd: (Player player) async {
        //统计单词学习时间
        var startTime = player.startTime;
        var endTime = player.stopTime ?? DateTime.now().millisecondsSinceEpoch;
        var status = player.wordStatus;
        if (status != null) {
          studyService.addWordStudyRecord(
              startTime, endTime, player.playComplete, status);
        }
        if (appService.autoPass == true) {
          var key = player.wordStatus?.word ?? "";
          var wordPlayCount = playCount[key] ?? 0;
          var cycle = player.wordStatus?.studyCycle ?? 0;
          if (wordPlayCount > 3 ||
              (cycle == 1 && wordPlayCount == 2) ||
              cycle > 1) {
            playCount[key] = 0;
            pass();
          }
        }
      },
    );

    playButtonEnable.value = true;
  }

  /// 下一个单词
  void next() async {
    if (!controlEnable.value) {
      return;
    }
    controlEnable.value = false;
    await stopPlay();
    playingIndex++;
    if (playingIndex >= playingWords.length) {
      playingIndex = 0;
    }
    await startPlay();
    await fetchCount();
    controlEnable.value = true;
  }

  /// 上一个单词
  void previous() async {
    if (!controlEnable.value) {
      return;
    }
    controlEnable.value = false;
    await stopPlay();
    playingIndex--;
    if (playingIndex < 0) {
      playingIndex = max(playingWords.length - 1, 0);
    }
    await startPlay();
    await fetchCount();
    controlEnable.value = true;
  }

  /// 标记单词为已掌握（通过）
  void pass() async {
    if (!controlEnable.value) {
      return;
    }
    controlEnable.value = false;
    await stopPlay();
    var word = this.word.value?.wordId;
    if (word != null) {
      await studyService.pass(word);
    }
    await fetchNextWord(playingIndex);
    await startPlay();
    await fetchCount();
    controlEnable.value = true;
  }

  /// 删除单词（标记为熟词）
  void delete() async {
    if (!controlEnable.value) {
      return;
    }
    controlEnable.value = false;
    await stopPlay();
    var word = this.word.value?.wordId;
    if (word != null) {
      await studyService.delete(word);
    }
    await fetchNextWord(playingIndex);
    await startPlay();
    await fetchCount();
    controlEnable.value = true;
  }

  /// 从播放列表删除指定单词
  Future<void> deleteByWord(String? word) async {
    var wordIndex = playingWords.indexWhere((element) => element.word == word);
    if (wordIndex == -1) {
      return;
    }
    await fetchNextWord(wordIndex);
    await fetchCount();
  }

  /// 切换播放/暂停状态
  void togglePlay() async {
    if (playing.value) {
      await stopPlay();
    } else {
      await startPlay();
    }
  }

  /// 获取学习统计数据
  Future<void> fetchCount() async {
    var dailyCount = await wordDao.queryDailyPassWordCount();
    dailyStudyCount.value = dailyCount ?? 0;
    var reviewCount = await wordDao.queryReviewWordCount();
    this.reviewCount.value = reviewCount ?? 0;

    var time = (await wordDao.queryStudyTime()) ?? 0;
    var use = (time / 1000 / 60).toStringAsFixed(1);
    studyTime.value = use + " 分钟";
  }

  /// 获取当前单词的学习状态
  void fetchWordStatus() async {
    var word = this.word.value;
    if (word != null) {
      wordStatus.value = await wordDao.queryWordStatus(word.wordId ?? "");
    }
  }
}
