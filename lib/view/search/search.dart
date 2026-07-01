import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:memorydemo/entity/word/vo/word.dart';

import '../../controller/search/search.dart';
import '../../util/audio.dart';
import '../../widget/sentence.dart';

/// 单词搜索页面
/// 提供单词搜索功能，支持模糊匹配，显示单词详情
class WordSearchView extends GetView<WordSearchController> {
  const WordSearchView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
        title: Container(
          height: 40,
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextField(
            onChanged: (text) {
              controller.search(text);
            },
            autofocus: true,
            decoration: InputDecoration(
              hintText: "搜索单词...",
              hintStyle: TextStyle(
                color: Colors.grey.withOpacity(0.5),
                fontSize: 14,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              prefixIcon: Icon(
                Icons.search,
                color: Colors.grey.withOpacity(0.5),
                size: 20,
              ),
              suffixIcon: Obx(() {
                if (controller.keyword.value.isEmpty) {
                  return const SizedBox.shrink();
                }
                return IconButton(
                  onPressed: () {
                    controller.clearSearch();
                  },
                  icon: Icon(
                    Icons.clear,
                    color: Colors.grey.withOpacity(0.5),
                    size: 20,
                  ),
                );
              }),
            ),
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.keyword.value.isEmpty) {
          return buildEmptyView(context);
        }
        if (controller.isSearching.value) {
          return buildLoadingView(context);
        }
        if (controller.searchResults.isEmpty) {
          return buildNoResultView(context);
        }
        return buildResultList(context);
      }),
    );
  }

  /// 构建空状态视图（未搜索时）
  Widget buildEmptyView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 80,
            color: Colors.grey.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            "输入单词进行搜索",
            style: TextStyle(
              color: Colors.grey.withOpacity(0.5),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建加载视图
  Widget buildLoadingView(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  /// 构建无结果视图
  Widget buildNoResultView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sentiment_dissatisfied,
            size: 80,
            color: Colors.grey.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            "未找到匹配的单词",
            style: TextStyle(
              color: Colors.grey.withOpacity(0.5),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建搜索结果列表
  Widget buildResultList(BuildContext context) {
    return ListView.builder(
      itemCount: controller.searchResults.length,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) {
        var word = controller.searchResults[index];
        return buildWordItem(context, word as WordVO);
      },
    );
  }

  /// 构建单词列表项
  Widget buildWordItem(BuildContext context, WordVO word) {
    return InkWell(
      onTap: () {
        // 点击展开详情
        showWordDetail(context, word);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.grey.withOpacity(0.1),
              width: 1,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 单词
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        word.word ?? "",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrangeAccent,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // 音标
                      if (word.ukVoice != null)
                        GestureDetector(
                          onTap: () {
                            playWordSound(word.word, 1);
                          },
                          child: Row(
                            children: [
                              Icon(
                                Icons.volume_down_outlined,
                                size: 16,
                                color: Colors.grey.withOpacity(0.6),
                              ),
                              Text(
                                "[${word.ukVoice}]",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // 释义（最多显示2行）
                  if (word.means != null && word.means!.isNotEmpty)
                    Text(
                      word.means!.take(2).join("\n"),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            // 右侧箭头
            Icon(
              Icons.keyboard_arrow_right,
              color: Colors.grey.withOpacity(0.3),
            ),
          ],
        ),
      ),
    );
  }

  /// 显示单词详情弹窗
  void showWordDetail(BuildContext context, WordVO word) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  // 顶部拖动条
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // 关闭按钮
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      onPressed: () {
                        Get.back();
                      },
                      icon: const Icon(Icons.close),
                    ),
                  ),
                  // 单词内容
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 单词标题
                          Text(
                            word.word ?? "",
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepOrangeAccent,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // 音标
                          Row(
                            children: [
                              // 英式发音
                              if (word.ukVoice != null)
                                InkWell(
                                  onTap: () {
                                    playWordSound(word.word, 1);
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 16),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.volume_down_outlined,
                                          color: Colors.black54,
                                          size: 20,
                                        ),
                                        const Text(
                                          "英 ",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.black54,
                                          ),
                                        ),
                                        Text(
                                          "[${word.ukVoice}]",
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              // 美式发音
                              if (word.usaVoice != null)
                                InkWell(
                                  onTap: () {
                                    playWordSound(word.word, 2);
                                  },
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.volume_down_outlined,
                                        color: Colors.black54,
                                        size: 20,
                                      ),
                                      const Text(
                                        "美 ",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black54,
                                        ),
                                      ),
                                      Text(
                                        "[${word.usaVoice}]",
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // 释义
                          if (word.means != null && word.means!.isNotEmpty)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.grey.withOpacity(0.05),
                              ),
                              child: Text(
                                word.means!.join("\n"),
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          const SizedBox(height: 20),
                          // 例句
                          if (word.sentence != null)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "例句",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                InkWell(
                                  onTap: () {
                                    playSentenceSound(
                                      word.sentence ?? "",
                                      cacheName: word.wordId ?? word.word,
                                    );
                                  },
                                  child: WordSentence(
                                    sentence: word.sentence,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                WordSentence(
                                  sentence: word.sentenceMeans,
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}