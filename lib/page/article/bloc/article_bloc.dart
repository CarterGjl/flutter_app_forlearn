import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_app_forlearn/entity/article_type_entity.dart';
import 'package:flutter_app_forlearn/entity/base_entity.dart';
import 'package:flutter_app_forlearn/entity/base_list_entity.dart';
import 'package:flutter_app_forlearn/entity/project_entity.dart';
import 'package:flutter_app_forlearn/http/api.dart';
import 'package:flutter_app_forlearn/http/index.dart';
import 'package:flutter_app_forlearn/page/home/bloc/HomeBloc.dart';
import 'package:flutter_app_forlearn/page/home/bloc/home_state.dart';

import 'article_event.dart';
import 'article_status.dart';

class ArticleBloc extends Bloc<ArticleEvent, ArticleState> {
  HomeBloc homeBloc;
  StreamSubscription subscription;

  ArticleBloc(this.homeBloc) {
    print('article bloc constra');

    //等主页加载完之后子页面开始加载数据
    homeBloc.state.listen((state) {
      if (state is HomeLoaded) {
        print('博文子页 主页加载完成 开始加载子页面');
        dispatch(LoadArticle(-1));
      } else if (homeBloc.alredyHomeloaded &&
          currentState == ArticleUnready()) {
        print('博文子页：在构造函数之前主页就已经加载完成并可能已经发送了其他bloc state，开始加载子页');
        dispatch(LoadArticle(-1));
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    subscription?.cancel();
  }

  @override
  ArticleState get initialState => ArticleUnready();

  @override
  Stream<ArticleState> mapEventToState(ArticleEvent event) async* {
    if (event is LoadArticle) {
      yield* _mapLoadArticleToState(event.id);
    } else if (event is LoadMoreArticleDatas) {
       yield* _mapLoadMoreArticleDatasToState(
          datas: event.originDatas, id: event.id, page: event.page);
    }else if(event is CollectArticle){
      yield* _mapCollectArticleToState(event.id,event.collect);
    }
  }

  Stream<ArticleState> _mapLoadArticleToState(int id) async* {
    try {
      yield ArticleLoading();
      List<ArticleTypeEntity> types = await _getTypes();
      yield ArticleTypesLoaded(types);
      ArticleDatasLoaded datasLoaded =
          await _getArticleDatasState(datas: [], id: id, page: 1);
      yield datasLoaded;
      yield ArticleLoaded();
    } catch (e) {
      yield ArticleLoadError(e);
    }
  }

  Future<List<ArticleTypeEntity>> _getTypes() async {
    var response = await ArticleApi.getArticleTypes();
    BaseEntity<List> baseEntity = BaseEntity.fromJson(response.data);
    var parentTypes = baseEntity.data.map((e) {
      return ArticleTypeEntity.fromJson(e);
    }).toList();
    parentTypes.map((parentType) {
      parentType.children = parentType.children.map((value) {
        return ArticleTypeEntity.fromJson(value);
      }).toList();
    }).toList();

    return parentTypes;
  }

  Future<ArticleDatasLoaded> _getArticleDatasState({List datas, int id, int
  page}) async {
    Response response;
    if (id == -1) {
      response = await ArticleApi.getNewArticle(page);
    } else {
      response = await ArticleApi.getArticleList(page, id);
    }

    BaseEntity<Map<String, dynamic>> baseEntity =
        BaseEntity.fromJson(response.data);
    BaseListEntity<List> baseListEntity =
        BaseListEntity.fromJson(baseEntity.data);
    if (datas == null || datas.length == 0) {
      datas = baseListEntity.datas.map((value) {
        return ProjectEntity.fromJson(value);
      }).toList();
    } else {
      datas.addAll(
          baseListEntity.datas.map((e) => ProjectEntity.fromJson(e)).toList());
    }
    if (id == -1 && page == 1) {
      //如果是最新博文的第一页，插入置顶文章
      Response response2 = await ArticleApi.getTopArticles();
      BaseEntity<List> baseEntity2 = BaseEntity.fromJson(response2.data);
      List<ProjectEntity> topArticles =
          baseEntity2.data.map((e) => ProjectEntity.fromJson(e)).toList();
      datas.insertAll(0, topArticles);
    }

    return ArticleDatasLoaded(
        datas, baseListEntity.curPage, baseListEntity.pageCount);
  }

  _mapLoadMoreArticleDatasToState(
      {List<ProjectEntity> datas, int id, int page}) async* {

    try{
      yield ArticleLoading();
      ArticleDatasLoaded datasState = await _getArticleDatasState(datas: datas,
          id: id,page: page);
      yield datasState;
      yield ArticleLoaded();
    }catch(e){
      yield ArticleLoadError(e);
    }
  }

  _mapCollectArticleToState(int id, bool collect) async*{
    try{
      yield ArticleLoading();
      if(collect){
        await CollectApi.collect(id);
      }else{
        await CollectApi.unCollect(id);
      }
      yield ArticleCollectChanged(id,collect);
      yield ArticleLoaded();
    }catch(e){
      yield ArticleLoadError(e);
    }
  }
}
