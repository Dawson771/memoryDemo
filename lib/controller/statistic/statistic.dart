import 'package:get/get.dart';

/// 统计页面控制器
/// 管理学习统计数据的展示和切换
class StatisticController {
  /// 学习数量
  var studyCount = 99999.obs;

  /// 当前选择的统计项
  var selectItem = StatisticItem.useTime.obs;
}

/// 统计项枚举
enum StatisticItem {
  /// 总耗时/每日耗时统计图，单位：分钟
  useTime,

  /// 学习数量/每日学习数量统计图
  passCount,

  /// 复习数量/每日复习数量统计图
  reviewCount,

  /// 学习速度/每日学习速度统计图，单位：词/分
  studySpeed,

  /// 单词平均耗时/每日单词平均耗时统计图，单位：秒
  useTimeAvg,
}
