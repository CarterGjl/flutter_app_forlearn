import 'package:equatable/equatable.dart';
import 'package:flutter_app_forlearn/entity/project_entity.dart';

abstract class ArticleEvent extends Equatable{

  ArticleEvent([List props = const []]):super(props);
}

//加载全部
class LoadArticle extends ArticleEvent{
  int id;

  LoadArticle(this.id):super([id]);

  @override
  String toString() {
    return 'LoadArticle{id: $id}';
  }

}

///加载更多博文
class LoadMoreArticleDatas extends ArticleEvent{
  List<ProjectEntity> originDatas;
  int id;
  int page;

  LoadMoreArticleDatas({this.originDatas, this.id, this.page}):super
      ([originDatas,id,page]);

  @override
  String toString() {
    return 'LoadMoreArticleDatas{originDatas: $originDatas, id: $id, page: $page}';
  }

}
///收藏 取消收藏
class CollectArticle extends ArticleEvent{
  int id;
  bool collect;

  CollectArticle(this.id, this.collect):super([id,collect]);

  @override
  String toString() {
    return 'CollectArticle{id: $id, collect: $collect}';
  }


}