import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter_app_forlearn/entity/banner_entity.dart';
import 'package:flutter_app_forlearn/entity/base_entity.dart';
import 'package:flutter_app_forlearn/entity/base_list_entity.dart';
import 'package:flutter_app_forlearn/entity/project_entity.dart';
import 'package:flutter_app_forlearn/entity/project_type_entity.dart';
import 'package:flutter_app_forlearn/http/api.dart';
import 'package:flutter_app_forlearn/page/home/bloc/HomeBloc.dart';
import 'package:flutter_app_forlearn/page/project/block/ProjectEvent.dart';
import 'package:flutter_app_forlearn/page/project/block/project_state.dart';

import '../../home/bloc/home_state.dart';

class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  HomeBloc homeBloc;
  StreamSubscription subscription;

  ProjectBloc(this.homeBloc) {
    ///等主页的基础数据加载完了后，子页再开始加载数据
    ///因为state使用的是BehaviorSubject，即粘性广播，所以即使ProjectBloc在HomeBloc发送了HomeLoaded之后才被实例，listen依然能接收到该事件。这也是为什么不用blocListener的原因(它会skip(1))
    subscription = homeBloc.state.listen((state) {
      if (state is HomeLoaded) {
        print('项目子页：主页加载完成，开始加载子页');
        dispatch(LoadProject());
      }
    });
  }

  @override
  void dispose() {
    subscription?.cancel();
    super.dispose();
  }

  @override
  ProjectState get initialState => ProjectUnready();

  @override
  Stream<ProjectState> mapEventToState(ProjectEvent event) async* {
    if (event is LoadProject) {
      yield* _mapLoadProjectToState();
    } else if (event is LoadMoreProjectDatas) {
      yield* _mapLoadMoreProjectDatasToState(event.originDatas, event.page);
    }else if (event is CollectProject) {
      yield* _mapCollectProjectToState(event.id, event.collect);
    }
  }

  Stream<ProjectState> _mapLoadMoreProjectDatasToState(
      List<ProjectEntity> datas, int page) async* {
    try {
      yield ProjectLoading();
      ProjectDatasLoaded datasState = await _getProjectDatasState(datas, page);
      yield datasState;
      yield ProjectLoaded();
    } catch (e) {
      yield ProjectLoadError(e);
    }
  }

  Stream<ProjectState> _mapLoadProjectToState() async* {
    try {
      ///从这里可知，UI层是否显示加载框不能依赖于ProjectLoading状态，因为在ProjectLoaded之前还有一些中间状态，
      ///所以UI层要自己记录isLoading，即ProjectLoading时置为true，直到ProjectLoaded或ProjectLoadError时置为false
      yield ProjectLoading();
      List<BannerEntity> bannerEntitys = await _getBanners();
      yield ProjectBannerLoaded(bannerEntitys);
      List<ProjectTypeEntity> types = await _getProjectTypes();
      yield ProjectTypesLoaded(types);
      ProjectDatasLoaded datasState = await _getProjectDatasState([], 1);
      yield datasState;
      yield ProjectLoaded();
    } catch (e) {
      yield ProjectLoadError(e);
    }
  }

  _getBanners() async {
    Response response = await ProjectApi.getBanners();
    BaseEntity<List> baseEntity = BaseEntity.fromJson(response.data);
    List<BannerEntity> bannerEntitys = baseEntity.data.map((e) {
      return BannerEntity.fromJson(e);
    }).toList();
    return bannerEntitys;
  }

  _getProjectTypes() async {
    Response response = await ProjectApi.getProjectTree();
    BaseEntity<List> baseEntity = BaseEntity.fromJson(response.data);
    List<ProjectTypeEntity> types = baseEntity.data.map((e) {
      return ProjectTypeEntity.fromJson(e);
    }).toList();
    return types;
  }
  Stream<ProjectState> _mapCollectProjectToState(int id, bool collect) async* {
    try {
      yield ProjectLoading();
      if (collect) {
        await CollectApi.collect(id);
      } else {
        await CollectApi.unCollect(id);
      }
      yield ProjectCollectChanged(id, collect);
      yield ProjectLoaded();
    } catch (e) {
      yield ProjectLoadError(e);
    }
  }
  _getProjectDatasState(List<ProjectEntity> datas, int page) async {
    Response response = await ProjectApi.getNewProjects(page);
    BaseEntity<Map<String, dynamic>> baseEntity =
    BaseEntity.fromJson(response.data);
    BaseListEntity<List> baseListEntity =
    BaseListEntity.fromJson(baseEntity.data);
    if (datas == null || datas.length == 0) {
      datas = baseListEntity.datas.map((e) => ProjectEntity.fromJson(e)).toList();
    } else {
      datas.addAll(
          baseListEntity.datas.map((e) => ProjectEntity.fromJson(e)).toList());
    }
    return ProjectDatasLoaded(
        datas, baseListEntity.curPage, baseListEntity.pageCount);
  }
}



