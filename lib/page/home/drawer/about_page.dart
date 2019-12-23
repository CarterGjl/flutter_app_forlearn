import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_forlearn/page/webview_page.dart';
import 'package:flutter_app_forlearn/res/index.dart';
import 'package:flutter_app_forlearn/res/strings.dart';
import 'package:flutter_app_forlearn/utils/index.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatefulWidget {
  static const ROUTER_NAME = "/AboutPage";

  @override
  State<StatefulWidget> createState() {
    return _AboutPageState();
  }
}

class _AboutPageState extends State<AboutPage> {
  String appName;
  String packageName;
  String version;
  String buildNumber;

  @override
  void initState() {
    super.initState();
    getPackageInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(res.about),
      ),
      body: Container(
        color: WColors.gray_background,
        child: ListView.builder(
          physics: BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            if (index == 0) {
              return _logo();
            }
            if (index == 1) {
              return DecoratedBox(
                  child: ListTile(
                    title: Text('github'),
                    trailing: Icon(Icons.navigate_next),
                    onTap: (){
                      Navigator.pushNamed(
                          context, WebViewPage.ROUTER_NAME,
                          arguments: {
                            'title':"Github",
                            'url':'www.bing.com'
                          }
                      );
                    },
                  ),
                  decoration: BoxDecoration(color: Colors.white));
            }
            if(index == 2){
              return DecoratedBox(
                  decoration: BoxDecoration(color: Colors.white),
                child: ListTile(
                  title: Text('blog'),
                  trailing: Icon(Icons.navigate_next),
                  onTap: (){
                    Navigator.pushNamed(context, WebViewPage.ROUTER_NAME,
                      arguments: {
                        'title': 'Blog',
                        'url': 'https://blog.csdn.net/ccy0122'
                        }
                    );
                  },
                ),
              );

            }
            return DecoratedBox(
              decoration: BoxDecoration(color: Colors.white),
              child: ListTile(
                title: Text(res.checkUpdate),
                trailing: Icon(Icons.navigate_next),
                onTap: (() {
//                    DisplayUtil.showMsg(context, text: '仅官方正式版支持检测升级');
//                    return;
                  checkUpdate(context);
                }),
              ),
            );
          },
          itemCount: 4,
        ),
      ),
    );
  }

  Future getPackageInfo() async {
    var packageInfo = await PackageInfo.fromPlatform();
    appName = packageInfo.appName;
    packageName = packageInfo.packageName;
    version = packageInfo.version;
    buildNumber = packageInfo.buildNumber;
    print('版本信息：$appName,$packageName,$version,$buildNumber');
    setState(() {});
  }

  Widget _logo() {
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: pt(70), bottom: pt(20)),
          child: Image.asset(
            'images/ic_launcher.png',
            color: WColors.theme_color,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: pt(30)),
          child: Text('v.$version'),
        ),
      ],
    );
  }

  Future checkUpdate(BuildContext context) async{
    try {
      DisplayUtil.showMsg(context,text: 'checking...',duration: Duration(seconds: 1));
//      BmobQuery<BmobUpdateEntity> query = BmobQuery();
//      dynamic result = await query.queryObject('ed22ca3838');
//      BmobUpdateEntity entity = BmobUpdateEntity.fromJson(result);
//      print('$entity');

      if (version != null) {
        int cur = int.parse(version.replaceAll('.', ''));
        int news = int.parse('1');
        if (cur < news) {
          if (mounted) {
//            showDialog(
//                context: context,
//                builder: (c) {
//                  return AlertDialog(
//                    title: Text(entity.versionName),
//                    content: Text(entity.updateMsg),
//                    actions: <Widget>[
//                      FlatButton(
//                        onPressed: () {
//                          _launchURL(entity.downloadUrl);
//                        },
//                        child: Text(res.go),
//                      ),
//                      ),
//                    ],
//                  );
//                });
//            return;
          }
        }
      }
    } catch (e) {
      print(e);
      if (mounted) {
        DisplayUtil.showMsg(context, text: 'check update failed');
        return;
      }
    }
    if (mounted) {
      DisplayUtil.showMsg(context, text: res.isNewestVersion);
    }
  }
  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
