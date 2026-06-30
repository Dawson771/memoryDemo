import 'package:memorydemo/controller/selectBook/selectBook.dart';
import 'package:memorydemo/controller/study/wordList.dart';
import 'package:memorydemo/widget/book_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';

/// 选择单词书页面
/// 以网格形式展示所有可用的单词书，用户点击选择后返回结果
class SelectBookPage extends GetView<SelectBookController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: Icon(
              Icons.arrow_back_ios,
            )),
        title: Text(
          "选择单词书",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.normal,
          ),
        ),
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
        ),
        backgroundColor: Colors.white,
        shadowColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: buildGridView(),
      ),
    );
  }

  /// 构建单词书网格视图
  /// 使用网格布局展示所有单词书，显示封面、书名和词汇量
  Widget buildGridView() {
    return GridView.builder(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 150,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.8,
        ),
        itemCount: controller.bookCount,
        itemBuilder: (context, index) {
          var bookName = controller.bookNames[index];
          var bookInfo = controller.bookInfo[bookName];
          var book = controller.bookMap[bookName];
          return ListTile(
            title: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FittedBox(
                  child: BookImage(
                    title: bookInfo["title"],
                    subTitle: bookInfo["subTitle"],
                    color: bookInfo["color"],
                    fontColor: bookInfo["fontColor"],
                    wordCount: "词汇量:${book?.words?.length}",
                  ),
                ),
                // Text(
                //   bookName,
                //   style: TextStyle(fontSize: 12),
                // )
              ],
            ),
            onTap: () {
              Get.back(result: controller.bookNames[index]);
            },
            selected: controller.bookNames[index] == controller.selectBookName,
            selectedTileColor: Colors.grey.withOpacity(0.2),
          );
        });
  }

  /// 构建单词书列表视图（备用实现）
  /// 使用列表形式展示所有单词书
  ListView buildListView() {
    return ListView.builder(
      itemBuilder: (context, index) {
        return ListTile(
          title: Text("${controller.bookNames[index]}"),
          onTap: () {
            Get.back(result: controller.bookNames[index]);
          },
          selected: controller.bookNames[index] == controller.selectBookName,
          selectedTileColor: Colors.grey.withOpacity(0.2),
        );
      },
      itemCount: controller.bookCount,
    );
  }
}

/// 单词列表页面（备用实现）
/// 展示不同分类的单词列表：播放列表、已学习、熟词
class WordListView extends GetView<WordListController> {
  const WordListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: Icon(
              Icons.keyboard_arrow_down_outlined,
              size: 32,
            )),
        title: Obx(
          () => Text(
            controller.title.value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: Colors.transparent),
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: Stack(
        children: [
          PageView.builder(
              itemCount: 3,
              controller: controller.pageController,
              onPageChanged: (index) {
                controller.onPageChanged(index);
              },
              itemBuilder: (context, index) {
                //1.播放列表
                //2.已学习
                //3.熟词(已删除)
                return ListView.builder(
                  itemCount: 100,
                  padding: EdgeInsets.only(bottom: 50),
                  itemBuilder: (ctx, index) {
                    return ListTile(
                      title: Text("hello"),
                    );
                  },
                  physics: const ClampingScrollPhysics(),
                );
              }),
          Align(
            alignment: Alignment.bottomCenter,
            child: Obx(
              () => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < 3; i++)
                    Container(
                      width: 10,
                      height: 10,
                      margin: EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 10,
                      ),
                      decoration: controller.pageIndex.value == i
                          ? BoxDecoration(
                              color: Colors.purple.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(100),
                            )
                          : BoxDecoration(
                              border: Border.all(
                                  color: Colors.purple.withOpacity(0.8)),
                              borderRadius: BorderRadius.circular(100),
                            ),
                    )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
