import 'package:flutter/material.dart';

import '../geometry.dart';

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

    if (next.lines.length <= 2) {
      forwardDistance += path[i + 1].distance.toInt();
      forwardLines.add(path[i + 1].lid);
    } else {
      var v1 = path[i].nearestVec(next, Line.vectorIn);
      var v2 = path[i + 1].nearestVec(next, Line.vectorOut);

      var direction = directionFromVecs(v1, v2);

      switch (direction) {
        case Direction.front:
          {
            description.add(DirectionDescription(
              Direction.front,
              "沿 ${forwardLines.join(", ")} 号道路直行 $forwardDistance 米。",
            ));
            forwardDistance = path[i + 1].distance.toInt();
            forwardLines = [path[i + 1].lid];
            description.add(DirectionDescription(direction, "直行通过路口。"));
            break;
          }
        case Direction.left:
          {
            description.add(DirectionDescription(
              Direction.front,
              "沿 ${forwardLines.join(", ")} 号道路直行 $forwardDistance 米。",
            ));
            forwardDistance = path[i + 1].distance.toInt();
            forwardLines = [path[i + 1].lid];
            description.add(DirectionDescription(
              direction,
              "在 ${path[i].lid} 号路尽头左转进入 ${path[i + 1].lid} 号路。",
            ));
            break;
          }
        case Direction.right:
          {
            description.add(DirectionDescription(
              Direction.front,
              "沿 ${forwardLines.join(", ")} 号道路直行 $forwardDistance 米。",
            ));
            forwardDistance = path[i + 1].distance.toInt();
            forwardLines = [path[i + 1].lid];
            description.add(DirectionDescription(
              direction,
              "在 ${path[i].lid} 号路尽头右转进入 ${path[i + 1].lid} 号路。",
            ));
            break;
          }
        case Direction.back:
          {
            description.add(DirectionDescription(
              Direction.front,
              "沿 ${forwardLines.join(", ")} 号道路直行 $forwardDistance 米。",
            ));
            forwardDistance = path[i + 1].distance.toInt();
            forwardLines = [path[i + 1].lid];
            description.add(DirectionDescription(
              direction,
              "在 ${path[i].lid} 号路的尽头掉头。",
            ));
            break;
          }
      }
    }
  }
  description.add(DirectionDescription(
    Direction.front,
    "沿 ${forwardLines.join(", ")} 号道路直行 $forwardDistance 米。\n终点在您附近，本次导航结束。",
  ));

  return description;
}

class PathDetailPage extends StatelessWidget {
  const PathDetailPage(
      {super.key,
      required this.start,
      required this.end,
      required this.pathDescription,
      required this.distance});

  final String start;
  final String end;
  final int distance;
  final List<DirectionDescription> pathDescription;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.arrow_back),
                ),
                const SizedBox(width: 8),
                const Text("路线详情", style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("起点：$start"),
                Text("终点：$end"),
                Text("全程 $distance 米"),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: pathDescription.length,
              itemBuilder: (context, index) {
                IconData direction;
                if (pathDescription[index].direction == Direction.front) {
                  direction = Icons.straight;
                } else if (pathDescription[index].direction == Direction.left) {
                  direction = Icons.turn_left;
                } else if (pathDescription[index].direction ==
                    Direction.right) {
                  direction = Icons.turn_right;
                } else {
                  direction = Icons.u_turn_left;
                }
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Icon(direction),
                      const SizedBox(width: 8.0),
                      Text(pathDescription[index].description),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
