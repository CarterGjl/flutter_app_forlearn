import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_app_forlearn/res/colors.dart';
import 'package:flutter_app_forlearn/res/strings.dart';
import 'package:flutter_app_forlearn/utils/screen_utils.dart';


Widget getLoadMoreFooter(bool hasMore,{Color color = WColors.gray_background}) {
  return Container(
    width: double.infinity,
    height: pt(45),
    color: color,
    alignment: Alignment.center,
    child: hasMore
        ? CupertinoActivityIndicator()
        : Text(
            res.isBottomst,
            style: TextStyle(color: WColors.hint_color),
          ),
  );
}
