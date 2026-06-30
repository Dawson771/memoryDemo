/// 获取当天开始时间的毫秒时间戳
/// 返回今日凌晨00:00:00的时间戳
int getDayStartTime() {
  var now = DateTime.now();
  return DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
}
