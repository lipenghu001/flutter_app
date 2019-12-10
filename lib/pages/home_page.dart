import 'package:flutter/material.dart';
import '../service/service_method.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'dart:convert';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with AutomaticKeepAliveClientMixin {

  int page = 1;
  List<Map> hotGoodsList=[];

  GlobalKey<RefreshFooterState> _footerKey = new GlobalKey<RefreshFooterState>();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() { 
    super.initState();
    print('111111111');
  }

  String homePageContent = '正在获取数据';

  @override
  Widget build(BuildContext context) {
    var formData = {'lon':'115.02932','lat':'35.76189'};
    return Scaffold(
      appBar: AppBar(title:Text('百姓生活+')),
      body:FutureBuilder(
        future:request('homePageContent',formData:formData),
        builder: (context,snapshot){
          if(snapshot.hasData){
            var data=json.decode(snapshot.data.toString());
            List<Map> swiperDataList = (data['data']['slides'] as List).cast(); // 顶部轮播组件数
            List<Map> navigatorList = (data['data']['category'] as List).cast();
            String adPicture = data['data']['advertesPicture']['PICTURE_ADDRESS'];
            String  leaderImage= data['data']['shopInfo']['leaderImage'];  //店长图片
            String  leaderPhone = data['data']['shopInfo']['leaderPhone']; //店长电话 
            List<Map> recommendList = (data['data']['recommend'] as List).cast(); // 商品推荐
            String floor1Title =data['data']['floor1Pic']['PICTURE_ADDRESS'];//楼层1的标题图片
            String floor2Title =data['data']['floor2Pic']['PICTURE_ADDRESS'];//楼层2的标题图片
            String floor3Title =data['data']['floor3Pic']['PICTURE_ADDRESS'];//楼层3的标题图片
            List<Map> floor1 = (data['data']['floor1'] as List).cast(); //楼层1商品和图片 
            List<Map> floor2 = (data['data']['floor2'] as List).cast(); //楼层2商品和图片 
            List<Map> floor3 = (data['data']['floor3'] as List).cast(); //楼层3商品和图片 
            
            return EasyRefresh(

              refreshFooter: ClassicsFooter(
                key:_footerKey,
                bgColor:Colors.white,
                textColor: Colors.pink,
                moreInfoColor: Colors.pink,
                showMore: true,
                noMoreText: '',
                moreInfo: '加载中',
                loadReadyText:'上拉加载....'
              ),

              child: ListView(
                  children: <Widget>[
                    SwiperDiy(swiperDataList),   //页面顶部轮播组件
                    TopNavigator(navigatorList),
                    AdBanner(adPicture),
                    LeaderPhone(leaderImage,leaderPhone),
                    Recommend(recommendList),
                    FloorTitle(picture_address:floor1Title),
                    FloorContent(floorGoodsList:floor1),
                    FloorTitle(picture_address:floor2Title),
                    FloorContent(floorGoodsList:floor2),
                    FloorTitle(picture_address:floor3Title),
                    FloorContent(floorGoodsList:floor3),
                    _hotGoods(),
                  ],
              ),
              loadMore:()async {
                print('开始加载更多');
                var formPage={'page': page};
                await request('homePageBelowConten',formData:formPage).then((val){
                  
                  var data=json.decode(val.toString());
                  List<Map> newGoodsList = (data['data'] as List ).cast();
                  setState(() {
                    hotGoodsList.addAll(newGoodsList);
                    page++; 
                  });
                });
              }
              
            );
            
          }else{
            return Center(
              child: Text('加载中'),
            );
          }
        },
      )
    );
  }

  //火爆商品接口
  void _getHotGoods(){
     var formPage={'page': page};
     request('homePageBelowConten',formData:formPage).then((val){
       
       var data=json.decode(val.toString());
       List<Map> newGoodsList = (data['data'] as List ).cast();
       setState(() {
         hotGoodsList.addAll(newGoodsList);
         page++; 
       });
     });
  }

  //火爆专区标题
  Widget hotTitle= Container(
    margin: EdgeInsets.only(top: 10.0),
    padding:EdgeInsets.all(5.0),
    alignment:Alignment.center,
    decoration: BoxDecoration(
      color: Colors.white,
      border:Border(
        bottom: BorderSide(width:0.5 ,color:Colors.black12)
      )
    ),
    child: Text('火爆专区'),
  );

  //火爆专区子项
  Widget _wrapList(){

    if(hotGoodsList.length!=0){
       List<Widget> listWidget = hotGoodsList.map((val){
          
          return InkWell(
            onTap:(){print('点击了火爆商品');},
            child: 
              Container(
                width: ScreenUtil().setWidth(372),
                color:Colors.white,
                padding: EdgeInsets.all(5.0),
                margin:EdgeInsets.only(bottom:3.0),
                child: Column(
                  children: <Widget>[
                    Image.network(val['image'],width: ScreenUtil().setWidth(375),),
                    Text(
                      val['name'],
                      maxLines: 1,
                      overflow:TextOverflow.ellipsis ,
                      style: TextStyle(color:Colors.pink,fontSize: ScreenUtil().setSp(26)),
                    ),
                    Row(
                      children: <Widget>[
                        Text('￥${val['mallPrice']}'),
                        Text(
                          '￥${val['price']}',
                          style: TextStyle(color:Colors.black26,decoration: TextDecoration.lineThrough),
                          
                        )
                      ],
                    )
                  ],
                ), 
              )
          );

      }).toList();

      return Wrap(
        spacing: 2,
        children: listWidget,
      );
    }else{
      return Text(' ');
    }
  }

  //火爆专区组合
  Widget _hotGoods(){

    return Container(
          
          child:Column(
            children: <Widget>[
              hotTitle,
               _wrapList(),
            ],
          )   
    );
  }
}


// 首页轮播组件编写
class SwiperDiy extends StatelessWidget {
  final List swiperDataList;
  SwiperDiy(this.swiperDataList);

  @override
  Widget build(BuildContext context) {
    
    // print('设备宽度:${ScreenUtil.screenWidth}');
    // print('设备高度:${ScreenUtil.screenHeight}');
    // print('设备像素密度:${ScreenUtil.pixelRatio}');
    return Container(
      height: ScreenUtil().setHeight(333),
      width: ScreenUtil().setWidth(750),
      child: Swiper(
        itemBuilder: (BuildContext context,int index){
          return Image.network("${swiperDataList[index]['image']}",fit:BoxFit.fill);
        },
        itemCount: swiperDataList.length,
        pagination: new SwiperPagination(),
        autoplay: true,
      ),
    );
  }
}

// 顶部导航
class TopNavigator extends StatelessWidget {
  final List navigatorList;

  TopNavigator(this.navigatorList);

  Widget _gridViewItemUI(BuildContext context, item){

    return InkWell(
      onTap: (){print('点击了导航');},
      child: Column(children: <Widget>[
        Image.network(item['image'],width:ScreenUtil().setWidth(95)),
        Text(item['mallCategoryName'])
      ],),
    );
  }

  @override
  Widget build(BuildContext context) {
    if(this.navigatorList.length>10){
      this.navigatorList.removeRange(10, this.navigatorList.length);
    }

    return Container(
      height: ScreenUtil().setHeight(320),
      padding: EdgeInsets.all(3.0),
      child: GridView.count(
        physics: NeverScrollableScrollPhysics(),
        crossAxisCount: 5,
        padding:EdgeInsets.all(5.0),
        children: navigatorList.map((item){
          return _gridViewItemUI(context, item);
        }).toList()
      ),
    );
  }
}

// 广告模块
class AdBanner extends StatelessWidget {
  final String adPicture;
  AdBanner(this.adPicture);

  @override
  Widget build(BuildContext context) {
    return Container(
    child: Image.network(adPicture),    
    );
  }
}

// 店长电话模块
class LeaderPhone extends StatelessWidget {
  final String leaderImage; //店长图片
  final String leaderPhone; //店长电话

  LeaderPhone(this.leaderImage,this.leaderPhone);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: InkWell(
        onTap: _launchURL,
        child: Image.network(leaderImage),
      ),
    );
  }
  

  void _launchURL() async {
    print(leaderPhone);
    String url = 'tel:'+leaderPhone;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}

//商品推荐
class Recommend extends StatelessWidget {

  final List recommendList;

  Recommend(this.recommendList);

  //推荐商品标题
  Widget _titleWidget(){
     return Container(
       alignment: Alignment.centerLeft,
       padding: EdgeInsets.fromLTRB(10.0, 2.0, 0,5.0),
       decoration: BoxDecoration(
         color:Colors.white,
         border: Border(
           bottom: BorderSide(width:0.5,color:Colors.black12)
         )
       ),
       child:Text(
         '商品推荐',
         style:TextStyle(color:Colors.pink)
         )
     );
  }

  // 推荐商品单独项
  Widget _item(index) {
    return InkWell(
      onTap: (){},
      child: Container(
        height: ScreenUtil().setHeight(380),
        width: ScreenUtil().setWidth(250),
        padding: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          border:Border(
            left: BorderSide(width:1,color:Colors.black12)
          )
        ),
        child: Column(
          children: <Widget>[
            Image.network(recommendList[index]['image']),
            Text('￥${recommendList[index]['mallPrice']}'),
            Text(
              '￥${recommendList[index]['price']}',
              style: TextStyle(
                decoration: TextDecoration.lineThrough,
                color:Colors.grey
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _recommedList(){

    return Container(
      height: ScreenUtil().setHeight(380),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: recommendList.length,
        itemBuilder: (context, index){
          return _item(index);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: ScreenUtil().setHeight(380),
      margin: EdgeInsets.only(top: 10.0),
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            _titleWidget(),
            _recommedList()
          ],
       ),
      )
    );
  }
}



class FloorTitle extends StatelessWidget {
  final String picture_address; // 图片地址
  FloorTitle({Key key, this.picture_address}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0),
      child: Image.network(picture_address),
    );
  }
}


//楼层商品组件
class FloorContent extends StatelessWidget {
  final List floorGoodsList;

  FloorContent({Key key, this.floorGoodsList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          _firstRow(),
          _otherGoods()
        ],
      ),
    );
  }

  Widget _firstRow(){
    return Row(
      children: <Widget>[
        _goodsItem(floorGoodsList[0]),
        Column(
          children: <Widget>[
           _goodsItem(floorGoodsList[1]),
           _goodsItem(floorGoodsList[2]),
          ],
        )
      ],
    );
  }

  Widget _otherGoods(){
    return Row(
      children: <Widget>[
       _goodsItem(floorGoodsList[3]),
       _goodsItem(floorGoodsList[4]),
      ],
    );
  }

  Widget _goodsItem(Map goods){

    return Container(
      width:ScreenUtil().setWidth(375),
      child: InkWell(
        onTap:(){print('点击了楼层商品');},
        child: Image.network(goods['image']),
      ),
    );
  }

}

class HotGoods extends StatefulWidget {
  _HotGoodsState createState() => _HotGoodsState();
}

class _HotGoodsState extends State<HotGoods> {


  void initState() { 
    super.initState();
    request('homePageBelowConten',formData: 1).then((val){
        print(val);
    });
  }
    
  @override
  Widget build(BuildContext context) {
    return Container(
       child:Text('1111'),
    );
  }
}

