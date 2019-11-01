import 'package:equatable/equatable.dart';
import 'package:flutter_app_forlearn/entity/project_entity.dart';

abstract class ProjectEvent extends Equatable{

  ProjectEvent([List props = const []]):super(props);
}

///加载全部
class LoadProject extends ProjectEvent{

  @override
  String toString() {
    return 'LoadProject{}';
  }
}

///加载更多项目
class LoadMoreProjectDatas extends ProjectEvent{
  List<ProjectEntity> originDatas;
  int page;///从这里可知，UI层是否显示加载框不能依赖于ProjectLoading状态，因为在ProjectLoaded之前还有一些中间状态，
      ///所以UI层要自己记录isLoading，即ProjectLoading时置为true，直到ProjectLoaded或ProjectLoadError时置为false


  LoadMoreProjectDatas(this.originDatas, this.page):super([originDatas,page]);

  @override
  String toString() {
    return 'LoadMoreProjectDatas{originDatas: $originDatas, page: $page}';
  }


}

class CollectProject extends ProjectEvent{
  int id;
  bool collect;

  CollectProject(this.id, this.collect):super([id,collect]);

  @override
  String toString() {
    return 'CollectProject{id: $id, collect: $collect}';
  }

}