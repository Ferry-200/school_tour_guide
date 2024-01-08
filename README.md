# school_tour_guide

距离计算
``` Dart
double toRadians(double num) => num * (math.pi / 180);

double getDistance(double lon1, double lat1, double lon2, double lat2) {
  double r = 6378137.0; // earth radius in meter

  lat1 = toRadians(lat1);
  lon1 = toRadians(lon1);
  lat2 = toRadians(lat2);
  lon2 = toRadians(lon2);

  double dlat = lat2 - lat1;
  double dlon = lon2 - lon1;

  double d = 2 *
      r *
      math.asin(math.sqrt(math.pow(math.sin(dlat / 2), 2) +
          math.cos(lat1) * math.cos(lat2) * math.pow(math.sin(dlon / 2), 2)));

  return d;
}
```

Polygon
- 线性环是具有四个或更多位置的闭合 LineString。
- **第一个和最后一个位置是相同的**，它们必须包含相同的值; 它们的表示也应该相同。
- 线性环是曲面的边界或曲面上孔的边界。
- 线性环必须遵循右手法则，也就是说，**外环为逆时针方向**，孔为顺时针方向。

实际存储结构：

画布大小
1265.3, 682.7 => 1265, 682

原点
119.545605, 39.926231

1 * 10^-5 °/px
0.000010069

~~todo：搜索所有可行简单路径。~~

- [x] 设计你所在学校的校园平面图,所含景点不少于10个。以图中顶点表示校内各景点,存放景点名称、代号、简介等信息;以边表示路径,存放路径长度等相关信息。
- [x] 提供图中任意景点相关信息的查询。
- [x] 查询任意两个景点之间的一条最短的简单路径。 
- [ ] ***可行性存疑*** 求任意两个景点之间的所有路径。
- [x] 求途经这多个景点的最佳 ( 短 )路径。_相邻两个点A Star Serching_
- [x] 扩充道路信息 , 如道路类别 ( 车道、人行道等 ) 、沿途景色等级 , 以至可按客人所需分别查询人行路径或车行路径或观景路径等。
- [x] 扩充每个景点的邻接景点的方向等信息 , 使得路径查询结果能提供详尽的导向信息。实现提示：一般情况下,校园的道路是双向通行的,可设校园平面图是一个无向网。顶点和边均 含有相关信息。

2024/01/08 update: 
#### 路径描述
- [x] 显示道路标号
- [x] 求两条不同道路之间的夹角
- [x] 生成路径描述
- [x] 合并直行路段

2024/01/09 update: 
- [ ] 路径描述页面
- [ ] 路径描述左边显示表示方向的Icon
- [x] 只在交叉路口进行方向判断
