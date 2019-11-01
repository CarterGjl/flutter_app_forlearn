import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter_app_forlearn/entity/base_entity.dart';
import 'package:flutter_app_forlearn/entity/hot_key_entity.dart';
import 'package:flutter_app_forlearn/http/api.dart';

class HotKeyModel extends ChangeNotifier {
  bool isLoading = false;
  List<HotKeyEntity> _datas = [];

  List<HotKeyEntity> get datas => _datas;

  ///更新
  updateHotKey() async {
    try {
      isLoading = true;
      notifyListeners();

      var response = await CommonApi.getHotKey();
      BaseEntity<List> baseEntity = BaseEntity.fromJson(response.data);
      _datas = baseEntity.data.map((e) => HotKeyEntity.fromJson(e)).toList();
      //随机排序 刷新成功
      _datas.sort((a, b) {
        return -1 + math.Random().nextInt(3);
      });
    } catch (e) {
      print(e);
      _datas = [];
    }
    isLoading = false;
    notifyListeners();
  }
}
