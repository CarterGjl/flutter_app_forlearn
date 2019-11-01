import 'package:bloc/bloc.dart';
import 'package:flutter_app_forlearn/http/api.dart';
import 'package:flutter_app_forlearn/page/home/bloc/home_evetn.dart';
import 'package:flutter_app_forlearn/page/home/bloc/home_state.dart';
import 'package:flutter_app_forlearn/util/share.dart';

import '../../../main.dart';

class HomeBloc extends Bloc<HomeEvent,HomeState>{

  bool isLogin = false;
  String userName;

  bool alredyHomeloaded = false;

  @override
  HomeState get initialState => HomeLoading();

  @override
  Stream<HomeState> mapEventToState(HomeEvent event) async* {
    if (event is LoadHome) {
      yield* _mapLoadHomeToState();
    } else if (event is LogoutHome) {
      yield* _mapLogoutHomeToState();
    } else if (event is StartSearchEvent) {
      yield HomeSearchStarted(event.isSearchWXArticle, event.searchKey);
    } /*else if (event is LoadBmobInfo) {
      yield* _mapLoadBmobInfoToState(event.userName);
    } else if (event is UpdateBmobInfo) {
      yield* _mapUpdateBmobInfoToState(event.bmobUserEntity);
    }*/
  }
//  Stream<HomeState> _mapLoadBmobInfoToState(String userName) async* {
//    try {
//      BmobQuery<BmobUserEntity> query = BmobQuery();
//      query.addWhereEqualTo('userName', userName);
//      List<dynamic> results = await query.queryObjects();
//      if (results == null || results.length == 0) {
//        print('HomeBloc._mapLoadBmobInfoToState  新用户，创建bmob行');
//        BmobUserEntity initUser = BmobUserEntity.empty();
//        initUser.userName = userName;
//        initUser.level = 1;
//        initUser.signature = res.initSignature;
//        initUser.strWhat = '';
//        initUser.numWhat = 0;
//        BmobSaved saved = await initUser.save();
//        initUser.objectId = saved.objectId;
//        initUser.createdAt = initUser.updatedAt = saved.createdAt;
//        yield HomeBmobLoaded(initUser);
//      } else {
//        yield HomeBmobLoaded(BmobUserEntity.fromJson(results[0]));
//      }
//    } catch (e) {
//      print('HomeBloc._mapLoadBmobInfoToState  $e');
//      //不报错
//    }
//  }
//  Stream<HomeState> _mapUpdateBmobInfoToState(BmobUserEntity entity) async* {
//    try {
//      yield HomeLoading();
//      BmobUpdated updated = await entity.update();
//      entity.updatedAt = updated.updatedAt;
//      yield HomeBmobLoaded(entity);
//    } catch (e) {
//      print('HomeBloc._mapUpdateBmobInfoToState  $e');
//      yield HomeLoadError(e);
//    }
//  }

  Stream<HomeState> _mapLogoutHomeToState() async* {
    try {
      alredyHomeloaded = false;
      yield HomeLoading();
      await AccountApi.logout();
      await SPUtil.setLogin(false);
      yield HomeLoaded(isLogin);
      alredyHomeloaded = true;
//      yield HomeBmobLoaded(null);
      dispatch(LoadHome());
    } catch (e) {
      yield HomeLoadError(e);
    }
  }

  Stream<HomeState> _mapLoadHomeToState() async* {
    try {
      alredyHomeloaded = false;
      yield HomeLoading();
      isLogin = await SPUtil.isLogin();
      if (isLogin) {
        userName = await SPUtil.getUserName();
      } else {
        userName = null;
      }
      yield HomeLoaded(isLogin, userName: userName);
      alredyHomeloaded = true;
      if (bmobEnable && isLogin && userName != null) {
        dispatch(LoadBmobInfo(userName));
      }
    } catch (e) {
      yield HomeLoadError(e);
    }
  }
}