import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_forlearn/http/dio_util.dart';
import 'package:flutter_app_forlearn/page/account/login_page.dart';
import 'package:flutter_app_forlearn/page/home/bloc/home_evetn.dart';
import 'package:flutter_app_forlearn/page/home/bloc/home_state.dart';
import 'package:flutter_app_forlearn/res/strings.dart';
import 'package:flutter_app_forlearn/utils/screen_utils.dart';
import 'package:flutter_app_forlearn/views/level_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../main.dart';
import 'bloc/HomeBloc.dart';
import 'drawer/about_page.dart';

///主页侧滑菜单
// ignore: must_be_immutable
class HomeDrawer extends StatefulWidget {


  bool isLogin = false;
  String userName;

  HomeDrawer(this.isLogin, this.userName);

  @override
  State<StatefulWidget> createState() {
    return _HomeDrawerState();
  }

}

class _HomeDrawerState extends State<HomeDrawer> {

  HomeBloc homeBloc;
  bool hasSignin = false;

  @override
  void initState() {
    super.initState();
    homeBloc = BlocProvider.of<HomeBloc>(context);
    hasSignin = true;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener(
      bloc: homeBloc,
      listener: (context, state) {

      },
      child: BlocBuilder<HomeEvent,HomeState>(
          bloc: homeBloc,
          builder: (context,state){
            return Column(
              children: <Widget>[
                Container(
                  height: pt(200),
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage('images/drawer_bg.jpeg'),
                          fit: BoxFit.cover,
                          alignment: Alignment.center)),
                  alignment: Alignment.center,
                  child: SafeArea(
                    child: Stack(
                      children: <Widget>[
                        Positioned(
                          left: pt(10),
                          top: pt(15),
                          child: widget.userName == null
                              ? Container()
                              : GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              if (!hasSignin) {
//                                hasSignin = true;
//                                BmobUserEntity copy = widget.bmobUserEntity
//                                    .copyWith(
//                                    level: widget.bmobUserEntity.level +
//                                        1);
//                                homeBloc.dispatch(UpdateBmobInfo(copy));
                              }
                            },
                            child: Row(
                              children: <Widget>[
                                Text(
                                  !hasSignin ? res.signin : res.signined,
                                  style: TextStyle(color: Colors.white),
                                ),
                                SizedBox(
                                  width: pt(5),
                                ),
                                Image.asset(
                                  'images/signin.png',
                                  color: Colors.white,
                                  width: 25,
                                  height: 25,
                                )
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          right: pt(10),
                          top: pt(15),
                          child: widget.userName == null
                              ? Container()
                              : GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
//                              Navigator.pushNamed(
//                                  context, RankPage.ROUTER_NAME);
                            },
                            child: Image.asset(
                              'images/rank.png',
                              color: Colors.white,
                              width: 30,
                              height: 30,
                            ),
                          ),
                        ),
                        Positioned(
                          left: pt(10),
                          bottom: pt(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(pt(17)),
                                    child: widget.isLogin
                                        ? Image.asset(
                                      'images/user_icon.jpeg',
                                      fit: BoxFit.cover,
                                      width: pt(34),
                                      height: pt(34),
                                    )
                                        : Icon(
                                      Icons.account_circle,
                                      color: Colors.white,
                                      size: pt(34),
                                    ),
                                  ),
                                  GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () {
                                      if (!widget.isLogin) {
                                        Navigator.pushNamed(context,
                                            LoginPage.ROUTER_NAME)
                                            .then((_) {
                                          homeBloc.dispatch(LoadHome());
                                        });
                                      }
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: pt(10)),
                                      child: Text(
                                        widget.userName ?? res.login,
                                        style: TextStyle(
                                            fontSize: 26,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: widget.userName == null
                                    ? Container()
                                    : GestureDetector(
                                  onTap: () {
                                    showSignatureDialog();
                                  },
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        widget.userName,
//            widget.bmobUserEntity.signature ==
//            null ||
//            widget.bmobUserEntity
//                .signature.length ==
//            0)
//            ? res.initSignature
//                : widget
//                .bmobUserEntity.signature,
                                        style:
                                        TextStyle(color: Colors.white),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                      getLevelWidgets(
                                          /*widget.bmobUserEntity.level*/1),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Offstage(
                  offstage: !bmobEnable,
                  child: _menuItem(Icon(Icons.feedback), res.feedback, () {
                    showFeedbackDialog();
                  }),
                ),
                _menuItem(Icon(Icons.attach_money), res.supportAuthor, () {
//                  Navigator.pushNamed(context, SupportAuthorPage.ROUTER_NAME);
                }),
                _menuItem(Icon(Icons.error_outline), res.about, () {
                  Navigator.pushNamed(context, AboutPage.ROUTER_NAME);
                }),
                _menuItem(Icon(Icons.account_circle),
                    widget.isLogin ? res.logout : res.login, () {
                      Navigator.pop(context);
                      if (widget.isLogin) {
                        homeBloc.dispatch(LogoutHome());
                      } else {
                        Navigator.pushNamed(context, LoginPage.ROUTER_NAME)
                            .then((_) {
                          homeBloc.dispatch(LoadHome());
                        });
                      }
                    }),
              ],
            );
          }),
    );
  }

  Widget _menuItem(Widget icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: icon,
      title: Text(title),
      onTap: onTap,
    );
  }

  Future checkTodayHasSignin(DateTime updateTime) async {
    ///为防止打卡作弊，当前时间从网络上获取
    DateTime now;
    try {
      Response response = await dio.get(
          'http://api.m.taobao.com/rest/api3.do?api=mtop.common.getTimestamp');
      Map<String, dynamic> data =
      (response.data as Map<String, dynamic>)['data'];
      String todayMills = data['t'];
      now = DateTime.fromMillisecondsSinceEpoch(int.parse(todayMills),
          isUtc: true);
    } catch (e) {
      print(e);
      hasSignin = true;
      setState(() {});
      return;
    }

    DateTime today = DateTime(
      now.year,
      now.month,
      now.day,
    );
//    print('$updateTime,$today');
    hasSignin = updateTime.isAfter(today.toUtc());
    setState(() {});
  }

  showSignatureDialog() {
    showDialog(
        context: context,
        builder: (context) {
          TextEditingController controller =
          TextEditingController(text: widget.userName);
//          if (widget.bmobUserEntity.signature != null) {
//            controller.selection = TextSelection(
//                baseOffset: widget.bmobUserEntity.signature.length,
//                extentOffset: widget.bmobUserEntity.signature.length);
//          }
          return AlertDialog(
            contentPadding: EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 0),
            content: TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: pt(5),
                  vertical: pt(8),
                ),
              ),
              controller: controller,
              autofocus: true,
            ),
            actions: <Widget>[
              FlatButton(
                child: Text(res.cancel),
                onPressed: () => Navigator.of(context).pop(),
              ),
              FlatButton(
                child: Text(res.confirm),
                onPressed: () {
//                  BmobUserEntity copy = widget.bmobUserEntity
//                      .copyWith(signature: controller.text);
//                  homeBloc.dispatch(UpdateBmobInfo(copy));
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  showFeedbackDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          TextEditingController controller = TextEditingController();
          return AlertDialog(
            contentPadding: EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 0),
            content: Container(
              height: pt(200),
              decoration: BoxDecoration(
                border: Border.all(),
              ),
              child: TextField(
                maxLines: null,
                textAlign: TextAlign.start,
                decoration: InputDecoration(
                  hintText: res.feedbackTips,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: pt(5),
                    vertical: pt(8),
                  ),
                ),
                controller: controller,
                autofocus: true,
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text(res.cancel),
                onPressed: () => Navigator.of(context).pop(),
              ),
              FlatButton(
                child: Text(res.confirm),
                onPressed: () {
//                  BmobFeedbackEntity feedback = BmobFeedbackEntity(
////                      widget.userName ?? '未登录用户', controller.text ?? '空');
//                  feedback.save().then((_) {
//                   print('feedback send success');
//                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

}