import 'package:equatable/equatable.dart';
import 'package:flutter_app_forlearn/entity/article_type_entity.dart';
import 'package:flutter_app_forlearn/entity/project_entity.dart';

abstract class ArticleState extends Equatable {
  ArticleState([List props = const []]) : super(props);
}

class ArticleUnready extends ArticleState {
  @override
  String toString() {
    return 'ArticleUnready{}';
  }
}

class ArticleLoading extends ArticleState {
  @override
  String toString() {
    return 'ArticleLoading{}';
  }
}

class ArticleTypesLoaded extends ArticleState {
  List<ArticleTypeEntity> articleTypes;

  ArticleTypesLoaded(this.articleTypes) : super([articleTypes]);

  @override
  String toString() {
    return 'ArticleTypesLoaded{articleTypes: $articleTypes}';
  }
}

class ArticleDatasLoaded extends ArticleState {
  List<ProjectEntity> datas;
  int curPage;
  int totalPage;

  ArticleDatasLoaded(this.datas, this.curPage, this.totalPage)
      : super([datas, curPage, totalPage]);

  @override
  String toString() {
    return 'ArticleDatasLoaded{datas: $datas, curPage: $curPage, totalPage: $totalPage}';
  }


}

class ArticleCollectChanged extends ArticleState{
  int id;
  bool collect;

  ArticleCollectChanged(this.id, this.collect);

  @override
  String toString() {
    return 'ArticleCollectChanged{id: $id, collect: $collect}';
  }

}
class ArticleLoaded extends ArticleState {
  @override
  String toString() {
    return 'ArticleLoaded{}';
  }
}
class ArticleLoadError extends ArticleState{
  Exception exception;

  ArticleLoadError(this.exception):super([exception]);

  @override
  String toString() {
    return 'ArticleLoadError{exception: $exception}';
  }


}
