import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_forlearn/entity/base_entity.dart';
import 'package:flutter_app_forlearn/entity/base_list_entity.dart';
import 'package:flutter_app_forlearn/entity/project_entity.dart';
import 'package:flutter_app_forlearn/http/api.dart';
import 'package:flutter_app_forlearn/page/project/project_page.dart';
import 'package:flutter_app_forlearn/res/index.dart';
import 'package:flutter_app_forlearn/utils/display_util.dart';
import 'package:flutter_app_forlearn/utils/index.dart';
import 'package:flutter_app_forlearn/views/load_more_footer.dart';
import 'package:flutter_app_forlearn/views/loading_view.dart';

///项目详情页
class ProjectDetailPage extends StatefulWidget {
  static const ROUTER_NAME = '/ProjectDetailPage';

  @override
  State<StatefulWidget> createState() {
    return _ProjectDetailPage();
  }
}

class _ProjectDetailPage extends State<ProjectDetailPage>
    with TickerProviderStateMixin {
  int typeId;
  String typeName;
  List<ProjectEntity> datas;
  int currentPage;
  int totalPage;
  bool isloading;
  ScrollController _scrollController;
  BuildContext innerContext;
  double lastOffsetPixels = 0;

  @override
  void initState() {
    currentPage = 1;
    totalPage = 1;
    isloading = false;
    datas = [];
    _scrollController = ScrollController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (typeId == null || typeName == null) {
      Map args = ModalRoute.of(context).settings.arguments;
      typeId = args['id'];
      typeName = args['name'];
      getProjects(id: typeId);

      _scrollController.addListener(() {
        if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent) {
          if (currentPage < totalPage &&
              !isloading &&
              _scrollController.position.pixels !=
                  lastOffsetPixels /*这个是为了避免没网时连续重复触发*/) {
            lastOffsetPixels = _scrollController.position.pixels;
            getProjects(page: currentPage + 1, id: typeId);
          }
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(typeName),
      ),
      backgroundColor: WColors.gray_background,
      body: Builder(builder: (context) {
        innerContext = context;
        return getLoadingParent(
            child: ListView.builder(
              physics: ClampingScrollPhysics(),
              itemBuilder: (context, index) {
                if (index < datas.length) {
                  return Container(
                    margin: EdgeInsets.symmetric(
                        horizontal: pt(16), vertical: pt(8)),
                    height: pt(180),
                    child: ProjectItem(datas[index], isloading),
                  );
                } else {
                  return getLoadMoreFooter(currentPage < totalPage);
                }
              },
              itemCount: datas.length + 1,
              controller: _scrollController,
            ),
            isLoading: isloading);
      }),
    );
  }

  Future getProjects({int page = 1, @required int id}) async {
    isloading = true;
    setState(() {});
    try {
      Response response = await ProjectApi.getProjectList(page, id);
      BaseEntity<Map<String, dynamic>> baseEntity =
          BaseEntity.fromJson(response.data);
      BaseListEntity<List> baseListEntity =
          BaseListEntity.fromJson(baseEntity.data);
      currentPage = baseListEntity.curPage;
      totalPage = baseListEntity.pageCount;
      if (datas == null || datas.length == 0) {
        datas =
            baseListEntity.datas.map((e) => ProjectEntity.fromJson(e)).toList();
      } else {
        datas.addAll(baseListEntity.datas
            .map((e) => ProjectEntity.fromJson(e))
            .toList());
      }
    } catch (e) {
      if (innerContext != null) {
        DisplayUtil.showMsg(innerContext, exception: e);
      }
    }

    isloading = false;
    setState(() {});
  }
}
