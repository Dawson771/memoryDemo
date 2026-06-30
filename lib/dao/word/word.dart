import 'package:memorydemo/entity/word/po/word.dart';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart';

import '../../util/time.dart';

/// 单词数据访问对象（DAO）
/// 提供单词相关的所有数据库操作方法
@dao
abstract class WordDao {
  /// 数据库执行器
  DatabaseExecutor get database;

  /// 查询适配器，用于执行自定义SQL
  QueryAdapter get queryAdapter {
    return QueryAdapter(database);
  }

  /// 添加单个单词
  @insert
  Future<int?> addWord(WordPO wordPO);

  /// 查询正在学习中的单词
  /// [count] 需要查询的数量
  @Query('''
  select word.* from  word_status status left join word word on word.word = status.word
   where status.status = 0 
   group by word.word
   limit :count
  ''')
  Future<List<WordPO>> queryStudyingWords(int count);

  /// 查询未学习过的新单词（随机排序）
  /// [book] 书籍ID
  /// [count] 需要查询的数量
  @Query('''
  select word.* from  word word left join word_status status on word.word = status.word
   where word.book=:book and status.id is null
   group by word.word
   order by random()
   limit :count
  ''')
  Future<List<WordPO>> queryNotStudyWords(int book, int count);

  /// 查询需要复习的单词（已完成学习且到达复习时间）
  /// [count] 需要查询的数量
  @Query('''
  select word.* from  word word left join  word_status status  on word.word = status.word
   where status.status = 1 
    and nextReviewTime<CAST((julianday('now') - 2440587.5)*86400000 AS INTEGER)
   group by word.word
   limit :count
  ''')
  Future<List<WordPO>> queryNeedReviewWords(int count);

  /// 创建单词学习状态记录
  @insert
  Future<int> createWordStatus(WordStatusPO status);

  /// 查询单词的学习状态
  /// [word] 单词内容
  @Query('''
  select * from word_status where word=:word
  ''')
  Future<WordStatusPO?> queryWordStatus(String word);

  /// 更新单词学习状态
  @update
  Future<int> updateStatus(WordStatusPO status);

  /// 更新或插入单词状态
  /// [wordId] 单词ID
  /// [status] 状态值：0=学习中，-1=删除，1=已学习
  Future<void> upsetWordStatusById(String? wordId, int status) async {
    var wordStatus = await queryWordStatus(wordId ?? '');
    if (wordStatus == null) {
      await createWordStatus(WordStatusPO(word: wordId, status: status));
      return;
    }
    await queryAdapter.queryNoReturn('''
    update word_status set status=?1 where word=?2
    ''', arguments: [status, wordId ?? '']);
  }

  /// 查询所有单词状态列表
  @Query('''
  select * from word_status 
  ''')
  Future<List<WordStatusPO>> queryWordStatusList();

  /// 查询指定书籍的单词总数
  /// [wordBook] 书籍ID
  Future<int?> queryWordCount(int wordBook) async {
    var count = await queryAdapter.query(
        'select count(0) as count from word where book=?1',
        mapper: (Map<String, Object?> row) => row['count'] as int?,
        arguments: [wordBook]);
    return count;
  }

  /// 查询学习进度单词数量（包含已删除/熟词的数量）
  /// [wordBook] 书籍ID
  Future<int?> queryProgressWordCount(int wordBook) async {
    var count = await queryAdapter.query(
        '''select count(0) as count from  word_status status
        left join  word word  on status.word = word.word
         where word.book=?1 and (status.status=1 or (status.studyCycle>0) or status.status=-1)
        ''',
        mapper: (Map<String, Object?> row) => row['count'] as int?,
        arguments: [wordBook]);
    return count;
  }

  /// 查询今日学习通过的单词数量（进入周期一以上的单词，周期0删除不算，周期0删除代表本来就会的单词）
  /// [wordBook] 书籍ID
  Future<int?> queryDailyBookPassWordCount(int wordBook) async {
    var count = await queryAdapter.query(
        '''select count(0) as count from  word_status status
        left join  word word  on status.word = word.word
         where word.book=?1 and (status.status=1 or status.studyCycle>0)
         and createTime > ${getDayStartTime()}
        ''',
        mapper: (Map<String, Object?> row) => row['count'] as int?,
        arguments: [wordBook]);
    return count;
  }

  /// 查询书籍中已通过的单词列表
  /// [wordBook] 书籍ID
  Future<List<String>> queryBookPassWord(int wordBook) async {
    var wordList = await queryAdapter.queryList(
        '''select word.word as word from  word_status status
        left join  word word  on status.word = word.word
         where word.book=?1 and (status.status=1 or status.studyCycle>0)
        ''',
        mapper: (Map<String, Object?> row) => row['word'] as String,
        arguments: [wordBook]);
    return wordList;
  }

  /// 查询书籍中已删除（标记为熟词）的单词列表
  /// [wordBook] 书籍ID
  Future<List<String>> queryBookDeleteWord(int wordBook) async {
    var wordList = await queryAdapter.queryList(
        '''select word.word as word from  word_status status
        left join  word word  on status.word = word.word
         where word.book=?1 and status.status=-1
        ''',
        mapper: (Map<String, Object?> row) => row['word'] as String,
        arguments: [wordBook]);
    return wordList;
  }

  /// 查询指定书籍中所有未删除的单词（-1代表删除）
  /// [wordBook] 书籍ID
  Future<List<String>> queryBookNotDeleteWord(int wordBook) async {
    var wordList = await queryAdapter.queryList(
        '''select word.word as word from  word word
        left join  word_status status  on status.word = word.word
         where word.book=?1 and (status.status!=-1 or status.status is null)
        ''',
        mapper: (Map<String, Object?> row) => row['word'] as String,
        arguments: [wordBook]);
    return wordList;
  }

  /// 查询今日通过的单词总数（所有书籍）
  Future<int?> queryDailyPassWordCount() async {
    var count = await queryAdapter.query(
      '''select count(distinct word.word) as count from  word_status status
        left join  word word  on status.word = word.word
         where (status.status=1 or (status.studyCycle>0 and status.status!=-1))
         and createTime > ${getDayStartTime()}
        ''',
      mapper: (Map<String, Object?> row) => row['count'] as int?,
    );
    return count;
  }

  /// 查询今日学习的单词数量（包括没有pass的，但不包括删除的）
  /// [wordBook] 书籍ID
  Future<int?> queryDailyStudyCount(int wordBook) async {
    var count = await queryAdapter.query(
        '''select count(0) as count from  word_status status
        left join  word word  on status.word = word.word
         where word.book=?1 and createTime > ${getDayStartTime()} and status.status!=-1 and status.status is not null
        ''',
        mapper: (Map<String, Object?> row) => row['count'] as int?,
        arguments: [wordBook]);
    return count;
  }

  /// 查询需要复习的单词总数
  Future<int?> queryReviewWordCount() async {
    var count = await queryAdapter.query(
        '''
          select count(0) as count from word_status  
           where studyCycle>0 and nextReviewTime < ${DateTime.now().millisecondsSinceEpoch} and status!=-1
        ''',
        mapper: (Map<String, Object?> row) => row['count'] as int?,
        arguments: []);
    return count;
  }

  /// 添加学习时间记录
  @insert
  Future<int> addStudyTimeRecord(StudyTimeCountPO po);

  /// 添加单词学习时间记录
  @insert
  Future<int> addWordStudyTimeRecord(WordStudyTimeCountPO po);

  /// 查询今日学习总时长（毫秒）
  Future<int?> queryStudyTime() async {
    var count = await queryAdapter.query(
        '''
          select sum(endTime-startTime) as time from word_study_time_count  
           where startTime > ${getDayStartTime()}
        ''',
        mapper: (Map<String, Object?> row) => row['time'] as int?,
        arguments: []);
    return count;
  }

  /// 清空单词表
  Future<void> clearWord() async {
    return await queryAdapter.queryNoReturn("delete from word");
  }

  /// 批量添加单词
  /// [words] 单词列表
  Future<void> addWords(List<WordPO> words) async {
    var batch = database.batch();
    for (var word in words) {
      batch.insert("word", {
        "word": word.word,
        "book": word.book,
      });
    }
    await batch.commit();
  }
}
