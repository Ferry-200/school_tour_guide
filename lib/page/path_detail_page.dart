import '../geometry.dart';

/// 描述路线每一步，直行、转弯
/// 方向枚举：左转、右转、直行、掉头
///
/// 沿...路步行/行驶...米
/// 左/右转进入...路
///
/// 向量叉乘 x1*y2-x2*y1; >0: v2在v1的左边; <0: v2在v1的右边

enum Direction {
  /// crossProduct<v1, v2> > 0, 22.5° <= angel<v1, v2> < 157.5°
  left,

  /// 0° <= angel<v1, v2> < 22.5°
  front,

  /// 157.5° <= angel<v1, v2> < 180°
  back,

  /// crossProduct<v1, v2> < 0, 22.5° <= angel<v1, v2> < 157.5°
  right,
}

class DirectionDescription {
  Direction direction;
  String description;

  DirectionDescription(this.direction, this.description);

  @override
  String toString() {
    return {
      "dir": direction,
      "des": description,
    }.toString();
  }
}

/// 返回v2在v1的方位
Direction directionFromVecs(Vector v1, Vector v2) {
  var crossProduct = Vector.crossProduct(v1, v2);
  var angle = Vector.andle(v1, v2);

  if (angle >= 0 && angle < 22.5) {
    return Direction.front;
  } else if (angle >= 22.5 && angle < 157.5) {
    return crossProduct > 0 ? Direction.left : Direction.right;
  } else {
    return Direction.back;
  }
}

List<DirectionDescription> pathDescription(List<Line> path, Point start) {
  List<DirectionDescription> description = [];
  Point next = start;
  int forwardDistance = path.first.distance.toInt();
  List<int> forwardLines = [path.first.lid];

  for (var i = 0; i < path.length - 1; i++) {
    next = path[i].forward(next);
    var v1 = path[i].nearestVec(next, Line.vectorIn);
    var v2 = path[i + 1].nearestVec(next, Line.vectorOut);

    var direction = directionFromVecs(v1, v2);

    switch (direction) {
      case Direction.front:
        forwardDistance += path[i + 1].distance.toInt();
        forwardLines.add(path[i + 1].lid);
        break;
      case Direction.left:
        {
          if (forwardDistance != 0) {
            description.add(DirectionDescription(
              Direction.front,
              "沿 ${forwardLines.join(", ")} 号道路直行 $forwardDistance 米。",
            ));
            forwardDistance = path[i + 1].distance.toInt();
            forwardLines = [path[i + 1].lid];
          }
          description.add(DirectionDescription(
            direction,
            "在 ${path[i].lid} 号路尽头左转进入 ${path[i + 1].lid} 号路。",
          ));
          break;
        }
      case Direction.right:
        {
          if (forwardDistance != 0) {
            description.add(DirectionDescription(
              Direction.front,
              "沿 ${forwardLines.join(", ")} 号道路直行 $forwardDistance 米。",
            ));
            forwardDistance = path[i + 1].distance.toInt();
            forwardLines = [path[i + 1].lid];
          }
          description.add(DirectionDescription(
            direction,
            "在 ${path[i].lid} 号路尽头右转进入 ${path[i + 1].lid} 号路。",
          ));
          break;
        }
      case Direction.back:
        {
          if (forwardDistance != 0) {
            description.add(DirectionDescription(
              Direction.front,
              "沿 ${forwardLines.join(", ")} 号道路直行 $forwardDistance 米。",
            ));
            forwardDistance = path[i + 1].distance.toInt();
            forwardLines = [path[i + 1].lid];
          }
          description.add(DirectionDescription(
            direction,
            "在 ${path[i + 1].lid} 号路的尽头掉头。",
          ));
          break;
        }
    }
  }
  description.add(DirectionDescription(
    Direction.front,
    "沿 ${forwardLines.join(", ")} 号道路直行 $forwardDistance 米。\n终点在您附近，本次导航结束。",
  ));

  return description;
}
