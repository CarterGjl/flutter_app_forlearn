import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_forlearn/res/strings.dart';
import 'package:flutter_app_forlearn/utils/string_decode.dart';
import 'package:flutter_app_forlearn/views/loading_view.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:url_launcher/url_launcher.dart';

class WebViewPage extends StatefulWidget {
  static const ROUTER_NAME = '/WebViewPage';

  @override
  State<StatefulWidget> createState() {
    return _WebViewPageState();
  }
}

class _WebViewPageState extends State<WebViewPage> {
  String title;
  String url;
  FlutterWebviewPlugin flutterWebviewPlugin;
  bool showLoading = false;

  @override
  void initState() {
    super.initState();
    flutterWebviewPlugin = FlutterWebviewPlugin();
    //initialChild只有第一网页加载时会显示，网页内部页面跳转不会再显示，所以要手动加上页面内跳转监听
    flutterWebviewPlugin.onStateChanged.listen((state) {
      print('_WebViewPageState.initState  state = ${state.type}');
      if (state.type == WebViewState.startLoad) {
        setState(() {
          showLoading = true;
        });
      } else if (state.type == WebViewState.finishLoad ||
          state.type == WebViewState.abortLoad) {
        setState(() {
          showLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var args = ModalRoute.of(context).settings.arguments;
    if (args is Map) {
      title = decodeString(args['title']);
      url = args['url'];
    }
    return WebviewScaffold(
      url: url,
      withZoom:false,
      useWideViewPort: true,
      withOverviewMode: true,
      displayZoomControls: false,
      supportMultipleWindows: false,

      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: <Widget>[
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              child: Container(
                child: Icon(Icons.close, color: Colors.white,),

              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: EdgeInsets.only(left: 10.0, right: 8),
                child: Icon(Icons.arrow_back,color: Colors.white,),

              ),
              onTap: () {
                flutterWebviewPlugin.goBack();
              },
            ),
            Expanded(
                child: Text(
              title,
              style: TextStyle(fontSize: 16),
            ))
          ],
        ),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.open_in_browser),
              tooltip: res.openBrowser,
              onPressed: () {
                _launchURL();
              })
        ],
        bottom: PreferredSize(
          child: showLoading
              ? LinearProgressIndicator(
            backgroundColor: Colors.grey,
          )
              : Container(),
          preferredSize: Size(double.infinity, 1),
        ),
      ),
      hidden: true,
      initialChild: getLoading(),
//      withZoom: true,
      withLocalStorage: true,
    );
  }

  void _launchURL() async{
    if(await canLaunch(url)){
      await launch(url);
    }else{
      throw 'can not launch $url';
    }
  }
}
