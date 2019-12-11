import 'package:flutter/material.dart';
import '../service/service_method.dart';
import 'dart:convert';
import '../model/category.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CategoryPage extends StatefulWidget {
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {

  @override
  Widget build(BuildContext context) {

    // _getCategory();
    return Container(
        child: Center(
          child: Text('分类页面'),
        ),
    );
  }

}


//左侧导航菜单
class LeftCategoryNav extends StatefulWidget {
  
  _LeftCategoryNavState createState() => _LeftCategoryNavState();
}

class _LeftCategoryNavState extends State<LeftCategoryNav> {
  List list= [];
   
  @override
  Widget build(BuildContext context) {
    return Container();
  }

  Widget _leftInkWel(int index){
    return InkWell(
      onTap: (){},
      child: Container(
        height: ScreenUtil().setHeight(100),
        padding:EdgeInsets.only(left:10,top:20),
        decoration: BoxDecoration(
          color: Colors.white,
          border:Border(
            bottom:BorderSide(width: 1,color:Colors.black12)
          )
        ),
        child: Text(list[index].mallCategoryName,style: TextStyle(fontSize:ScreenUtil().setSp(28)),),
      ),
    );
  }

  void _getCategory()async{
    await request('getCategory').then((val){
      var data = json.decode(val.toString());
      CategoryModel category = CategoryModel.fromJson(data);

      setState(() {
          list =category.data;
      });
      // list.data.forEach((item)=>print(item.mallCategoryName));
    });
  }
}
