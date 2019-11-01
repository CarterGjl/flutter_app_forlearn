import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_app_forlearn/entity/project_entity.dart';
import 'package:flutter_app_forlearn/page/account/login_page.dart';
import 'package:flutter_app_forlearn/page/search/hot_key_model.dart';
import 'package:flutter_app_forlearn/page/search/search_result_model.dart';
import 'package:flutter_app_forlearn/res/colors.dart';
import 'package:flutter_app_forlearn/res/strings.dart';
import 'package:flutter_app_forlearn/utils/display_util.dart';
import 'package:flutter_app_forlearn/utils/index.dart';
import 'package:flutter_app_forlearn/utils/string_decode.dart';
import 'package:flutter_app_forlearn/views/load_more_footer.dart';
import 'package:flutter_app_forlearn/views/loading_view.dart';
import 'package:flutter_app_forlearn/views/saerch_bar.dart';
import 'package:provider/provider.dart';

import '../webview_page.dart';

class SearchPage extends StatefulWidget {
  static const ROUTER_NAME = '/SearchPage';

  @override
  State<StatefulWidget> createState() {
    return _SearchPageState();
  }
}

class _SearchPageState extends State<SearchPage> {
  String _seachKey;
  BuildContext _innerContext;

  @override
  Widget build(BuildContext context) {
    if (_seachKey == null) {
      _seachKey = ModalRoute.of(context).settings.arguments;
      if (_seachKey == null) {
        _seachKey = "RxJava";
      }
    }
    print('根页面刷新');
    return Scaffold(
      body: Builder(builder: (context) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(builder: (context) {
              return SearchResultModel(_seachKey, (e) {
                DisplayUtil.showMsg(context, exception: e);
              })
                ..getResults(_seachKey);
            })
          ],
          child: Builder(builder: (context) {
            this._innerContext = context;
            return DecoratedBox(
                decoration: _themeGradientDecoration(),
                child: SafeArea(
                    child: DecoratedBox(
                  decoration: BoxDecoration(color: WColors.gray_background),
                  child: Column(
                    children: <Widget>[
                      SearchAppBar(),
                      HotKeyBanner(),
                      Expanded(child: ResultsList()),
                    ],
                  ),
                )));
          }),
        );
      }),
    );
  }
}

Decoration _themeGradientDecoration() {
  return BoxDecoration(
      gradient: LinearGradient(
    colors: [
//        WColors.theme_color_dark,
      WColors.theme_color,
      WColors.theme_color_light,
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  ));
}

// ignore: must_be_immutable
class SearchAppBar extends StatelessWidget {
  TextEditingController _searchTextContriller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer<SearchResultModel>(
        builder: (BuildContext context, SearchResultModel value, Widget child) {
      print('搜索框被刷新');
      _searchTextContriller.value = TextEditingValue(
          text: value.searchKey,
          selection: TextSelection.collapsed(offset: value.searchKey.length));

      return DecoratedBox(
        decoration: _themeGradientDecoration(),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: pt(10)),
          child: Row(
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: pt(16)),
                  child: Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  ),
                ),
              ),
              Expanded(
                  child: Padding(
                padding: EdgeInsets.only(right: pt(16)),
                child: Hero(
                    tag: 'searchBar',
                    child: Material(
                      type: MaterialType.transparency,
                      child: SearchBar(
                        height: pt(30),
                        color: Colors.grey[50],
                        child: TextField(
                          controller: _searchTextContriller,
                          textInputAction: TextInputAction.search,
                          onSubmitted: (text) {
                            if (_searchTextContriller.text != null &&
                                !value.isLoading) {
                              print('刷新颗粒度测试：全部刷新（因为涉及键盘弹出收起，整个根布局会被刷新）');
                              value.getResults(_searchTextContriller.text);
                            }
                          },
                          style: TextStyle(fontSize: 14),
                          decoration: InputDecoration(
                              hintText: res.searchTips,
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.only(),
                              hintStyle: TextStyle(
                                  fontSize: 12,
                                  color: WColors.hint_color_dark)),
                        ),
                        iconColor: WColors.hint_color_dark,
                      ),
                    )),
              ))
            ],
          ),
        ),
      );
    });
  }
}

class HotKeyBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        builder: (context) {
          return HotKeyModel()..updateHotKey();
        },
        child: DecoratedBox(
          decoration: _themeGradientDecoration(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: pt(16)),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      res.peopleAreSearching,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600),
                    ),
                    SizedBox(
                      width: pt(5),
                    ),
                    Consumer<HotKeyModel>(builder: (context, value, child) {
                      print('刷新按钮 被点击');
                      return value.isLoading
                          ? CupertinoActivityIndicator()
                          : GestureDetector(
                              onTap: () {
                                print('刷新热搜栏');
                                value.updateHotKey();
                              },
                              child: Icon(
                                Icons.refresh,
                                color: Colors.white,
                                size: 20,
                              ),
                            );
                    })
                  ],
                ),
                SizedBox(
                  height: pt(5),
                ),
                Consumer<HotKeyModel>(builder: (context, value, child) {
                  print('热搜栏被刷新');
                  return Wrap(
                    children: List.generate(value.datas.length, (index) {
                      return _hotKeyItem(value.datas[index].name, () {
                        //获取搜索结果，并不需要刷新【热搜栏】，即当前builder不需要刷新，所以listen = false;
                        var searchResultModel = Provider.of<SearchResultModel>(
                            context,
                            listen: false);
                        if (!searchResultModel.isLoading) {
                          print('只刷新搜索框 结果列表');
                          searchResultModel.getResults(value.datas[index].name);
                        }
                      });
                    }),
                  );
                })
              ],
            ),
          ),
        ));
  }

  Widget _hotKeyItem(String name, Function() onTap) {
    return Padding(
      padding: EdgeInsets.only(bottom: pt(5)),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          height: pt(24),
          padding: EdgeInsets.symmetric(horizontal: pt(5)),
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Text(
                name,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    decoration: TextDecoration.underline),
              )
            ],
          ),
        ),
      ),
    );
  }
}

///结果列表
class ResultsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SearchResultModel>(builder: (context, value, child) {
      print('结果列表被刷新');
      return NotificationListener(
        onNotification: (notification) {
          if (notification is ScrollUpdateNotification) {
            //确定是否到达了底部
            if (notification.metrics.pixels >=
                notification.metrics.maxScrollExtent) {
              //确定当前允许加载更多
              if (!value.isLoading && value.hasMore()) {
                print('刷新颗粒度测试：期望只刷新【搜索框】【结果列表】');
                value.getResults(value.searchKey, page: value.currentPage + 1);
              }
              return false;
            }
          }
          return false;
        },
        child: Container(
          child: getLoadingParent(
              child: ListView.builder(
                itemBuilder: (context, index) {
                  if (index < value.datas.length) {
                    return ArticleItem(value.datas[index], value.isLoading, () {
                      if (value.isLoading) {
                        return;
                      }
                      SPUtil.isLogin().then((islogin) {
                        if (islogin) {
                          print('刷新颗粒度测试：期望只刷新【搜索框】【结果列表】');
                          value.collect(value.datas[index].id,
                              !value.datas[index].collect);
                        } else {
                          Navigator.pushNamed(context, LoginPage.ROUTER_NAME);
                        }
                      });
                    });
                  } else {
                    return getLoadMoreFooter(value.hasMore(),
                        color: Colors.white);
                  }
                },
                itemCount: value.datas.length + 1,
              ),
              isLoading: value.isLoading),
        ),
      );
    });
  }
}

class ArticleItem extends StatefulWidget {
  ProjectEntity data;
  bool isLoading;
  var onTap;

  ArticleItem(this.data, this.isLoading, this.onTap);

  @override
  _ArticleItemState createState() => _ArticleItemState();
}

class _ArticleItemState extends State<ArticleItem>
    with SingleTickerProviderStateMixin {
  bool lastCollectState;
  AnimationController _collectController;
  Animation _collectAnim;

  @override
  void initState() {
    super.initState();
    _collectController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    CurvedAnimation curvedAnimation =
        CurvedAnimation(parent: _collectController, curve: Curves.easeOut);
    _collectAnim = Tween<double>(begin: 1, end: 1.8).animate(curvedAnimation);
  }

  @override
  void dispose() {
    super.dispose();
    _collectController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (lastCollectState == false && lastCollectState != widget.data.collect) {
      _collectController.forward(from: 0).then((_) {
        _collectController.reverse();
      });
    }
    lastCollectState = widget.data.collect;
    return Container(
      color: Colors.white,
      child: Column(
        children: <Widget>[
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.only(right: pt(8), left: pt(8)),
            leading: GestureDetector(
              behavior: HitTestBehavior.opaque,
              child: Container(
                alignment: Alignment.center,
                width: 40,
                height: 40,
                child: ScaleTransition(
                  scale: _collectAnim,
                  child: Icon(
                    widget.data.collect
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color:
                        widget.data.collect ? WColors.warning_red : Colors.grey,
                    size: 24,
                  ),
                ),
              ),
              onTap: widget.onTap,
            ),
            title: Text(
              decodeString(widget.data.title)
                  .replaceAll("<em class='highlight'>", '')
                  .replaceAll("\</em>", ''), //去掉HTML语法
              style: TextStyle(
                fontSize: 15,
              ),
            ),
            subtitle: Row(
              children: <Widget>[
                //搜索页不需要显示"置顶"
//                widget.data.type == 1 //目前本人通过对比json差异猜测出type=1表示置顶类型
//                    ? Container(
//                        decoration: BoxDecoration(
//                            border: Border.all(color: Colors.red[700])),
//                        margin: EdgeInsets.only(right: pt(6)),
//                        padding: EdgeInsets.symmetric(horizontal: pt(4)),
//                        child: Text(
//                          res.stickTop,
//                          style: TextStyle(
//                              color: Colors.red[700],
//                              fontWeight: FontWeight.w600,
//                              fontSize: 10),
//                        ),
//                      )
//                    : Container(),
                widget.data.fresh
                    ? Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: WColors.warning_red)),
                        margin: EdgeInsets.only(right: pt(6)),
                        padding: EdgeInsets.symmetric(horizontal: pt(4)),
                        child: Text(
                          res.New,
                          style: TextStyle(
                              color: WColors.warning_red,
                              fontWeight: FontWeight.w600,
                              fontSize: 10),
                        ),
                      )
                    : Container(),

                ///WanAndroid文档原话：superChapterId其实不是一级分类id，因为要拼接跳转url，内容实际都挂在二级分类下，所以该id实际上是一级分类的第一个子类目的id，拼接后故可正常跳转
                widget.data.superChapterId == 294 //项目
                    ? Container(
                        decoration: BoxDecoration(
                            border:
                                Border.all(color: WColors.theme_color_dark)),
                        margin: EdgeInsets.only(right: pt(6)),
                        padding: EdgeInsets.symmetric(horizontal: pt(4)),
                        child: Text(
                          res.project,
                          style: TextStyle(
                              color: WColors.theme_color_dark,
                              fontWeight: FontWeight.w600,
                              fontSize: 10),
                        ),
                      )
                    : Container(),
                widget.data.superChapterId == 440 //问答
                    ? Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: WColors.theme_color)),
                        margin: EdgeInsets.only(right: pt(6)),
                        padding: EdgeInsets.symmetric(horizontal: pt(4)),
                        child: Text(
                          res.QA,
                          style: TextStyle(
                              color: WColors.theme_color,
                              fontWeight: FontWeight.w600,
                              fontSize: 10),
                        ),
                      )
                    : Container(),
                widget.data.superChapterId == 408 //公众号
                    ? Container(
                        decoration: BoxDecoration(
                            border:
                                Border.all(color: WColors.theme_color_light)),
                        margin: EdgeInsets.only(right: pt(6)),
                        padding: EdgeInsets.symmetric(horizontal: pt(4)),
                        child: Text(
                          res.vxArticle,
                          style: TextStyle(
                              color: WColors.theme_color_light,
                              fontWeight: FontWeight.w600,
                              fontSize: 10),
                        ),
                      )
                    : Container(),
                Expanded(
                  child: Text(
                      '${res.author}：${widget.data.author}  ${res.time}：${widget.data.niceDate}'),
                ),
              ],
            ),
            onTap: () {
              Navigator.pushNamed(
                context,
                WebViewPage.ROUTER_NAME,
                arguments: {
                  'title': widget.data.title,
                  'url': widget.data.link,
                },
              );
            },
          ),
          Divider(
            height: 10,
          )
        ],
      ),
    );
  }
}
