// ignore_for_file: unnecessary_this

import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

double toRadians(double num) => num * (math.pi / 180);

/// return path if succeed.
List<Line>? aStarPathFinding(Point start, Point end,
    {required bool onlyCarriageway}) {
  var cameFrom = HashMap<Point, Point>();
  var costSoFar = HashMap<Point, double>();
  var frontier = SplayTreeMap<double, Point>();

  frontier[0] = start;
  cameFrom[start] = start;
  costSoFar[start] = 0;

  while (frontier.isNotEmpty) {
    var current = frontier.remove(frontier.firstKey())!;
    // print(current.pid);

    // Found end.
    if (current == end) {
      if (!cameFrom.containsKey(end)) {
        return null;
      }

      var last = end;
      var secondLast = cameFrom[last]!;
      var path = <Line>[];
      while (last != start) {
        for (var v in last.lines) {
          if (v.points[0] == secondLast || v.points[1] == secondLast) {
            path.add(v);
            break;
          }
        }
        last = secondLast;
        secondLast = cameFrom[last]!;
      }
      return path;
    }

    for (var line in current.lines) {
      if (line.isCarriageway || !onlyCarriageway) {
        var next = line.points.first;
        if (next == current) {
          next = line.points[1];
        }

        double newCost = costSoFar[current]! + line.distance;
        if (!costSoFar.containsKey(next) || (newCost < costSoFar[next]!)) {
          costSoFar[next] = newCost;
          double priorty = newCost +
              Coordinate.getDistance(
                next.coordinate,
                end.coordinate,
              );
          frontier[priorty] = next;
          cameFrom[next] = current;
        }
      }
    }
  }

  return null;
}

class MapData {
  List<Point> visiblePoints;
  List<Point> allPoints;

  List<Line> lines;
  List<Area> areas;

  List<Point> spots;

  static MapData? _instance;

  static MapData get instance {
    return _instance!;
  }

  MapData(
    this.visiblePoints,
    this.allPoints,
    this.lines,
    this.areas,
    this.spots,
  );

  factory MapData.fromJson(String path) {
    var visiblePoints = <Point>[];
    var allPoints = <Point>[];
    var lines = <Line>[];
    var areas = <Area>[];

    List rawFeatures = json.decode(File(path).readAsStringSync())["features"];
    for (Map feature in rawFeatures) {
      if (feature["geometry"]["type"] == "Point") {
        var point = Point(
          allPoints.length,
          feature["properties"]["name"] ?? "",
          feature["properties"]["name"] != null,
          "",
          feature["properties"]["aka"] ?? [],
          feature["properties"]["lines"] ?? [],
          Coordinate(
            feature["geometry"]["coordinates"][0],
            feature["geometry"]["coordinates"][1],
          ),
        );
        allPoints.add(point);
        if (point.visibility) {
          visiblePoints.add(point);
        }
      } else if (feature["geometry"]["type"] == "Polygon") {
        areas.add(Area(
          areas.length,
          feature["properties"]["name"],
          "",
          feature["properties"]["aka"] ?? [],
          feature["properties"]["contains"] ?? [],
          feature["properties"]["entries"] ?? [],
          List<Coordinate>.generate(
            (feature["geometry"]["coordinates"][0] as List).length,
            (index) => Coordinate(
              feature["geometry"]["coordinates"][0][index][0],
              feature["geometry"]["coordinates"][0][index][1],
            ),
          ),
        ));
      } else if (feature["geometry"]["type"] == "LineString") {
        lines.add(Line(
          lines.length,
          feature["properties"]["type"] == 1,
          feature["properties"]["points"] ?? [],
          List<Coordinate>.generate(
            (feature["geometry"]["coordinates"] as List).length,
            (index) => Coordinate(
              feature["geometry"]["coordinates"][index][0],
              feature["geometry"]["coordinates"][index][1],
            ),
          ),
        ));
      }
    }

    for (var point in allPoints) {
      point.lines = List.generate(
        point._lines.length,
        (index) => lines[point._lines[index]],
      );
    }

    for (var line in lines) {
      line.points = List.generate(
        line._points.length,
        (index) => allPoints[line._points[index]],
      );
    }

    for (var area in areas) {
      area.entries = List.generate(
        area._entries.length,
        (index) => allPoints[area._entries[index]],
      );
    }

    var spots = <Point>[
      allPoints[3],
      allPoints[155],
      allPoints[149],
      allPoints[107],
      allPoints[104],
      allPoints[111],
      allPoints[113],
      allPoints[156],
      allPoints[12],
      allPoints[10],
    ];

    _instance = MapData(visiblePoints, allPoints, lines, areas, spots);
    return _instance!;
  }
}

class Coordinate {
  /// 经度
  double longitude;

  /// 纬度
  double latitude;

  Coordinate(this.longitude, this.latitude);

  /// 使用半正矢公式（Haversine formula）计算
  static double getDistance(Coordinate coor1, Coordinate coor2) {
    double r = 6378137.0; // earth radius in meter

    var lat2R = toRadians(coor2.latitude);
    var lat1R = toRadians(coor1.latitude);
    var lon2R = toRadians(coor2.longitude);
    var lon1R = toRadians(coor1.longitude);
    double dlat = lat2R - lat1R;
    double dlon = lon2R - lon1R;

    double d = 2 *
        r *
        math.asin(math.sqrt(math.pow(math.sin(dlat / 2), 2) +
            math.cos(lat1R) *
                math.cos(lat2R) *
                math.pow(math.sin(dlon / 2), 2)));

    return d;
  }
}

class Point {
  int pid;
  String name;
  bool visibility;
  String description;

  /// List<String>
  List aka;

  /// List<int>
  final List _lines;
  late List<Line> lines;
  Coordinate coordinate;

  Point(this.pid, this.name, this.visibility, this.description, this.aka,
      this._lines, this.coordinate);

  @override
  String toString() {
    return "Point{id: $pid}";
  }
}

enum LineType {
  footway,
  carriageway,
}

class Line {
  int lid;
  bool isCarriageway;

  /// List<int>
  final List _points;
  late List<Point> points;
  List<Coordinate> coordinates;

  Line(this.lid, this.isCarriageway, this._points, this.coordinates);

  /// 线可以由多个点组成，所以这里的距离是这条线里的所有两点之间距离的总和
  double? _distance;

  double get distance {
    if (_distance == null) {
      double s = 0;
      for (var i = 0; i < (coordinates.length - 1); i++) {
        s += Coordinate.getDistance(coordinates[i], coordinates[i + 1]);
      }
      _distance = s;
      return _distance!;
    }

    return _distance!;
  }

  @override
  String toString() {
    return "Line{id: $lid}";
  }
}

class Area {
  int areaId;
  String name;
  String description;

  /// List<String>
  List aka;

  /// List<String>
  List contains;

  /// List<int>
  final List _entries;
  late List<Point> entries;
  List<Coordinate> coordinates;

  late double minLat;
  late double minLon;
  late double maxLat;
  late double maxLon;

  Area(this.areaId, this.name, this.description, this.aka, this.contains,
      this._entries, this.coordinates) {
    minLat = coordinates.first.latitude;
    minLon = coordinates.first.longitude;

    maxLat = coordinates.first.latitude;
    maxLon = coordinates.first.longitude;
    for (int i = 1; i < coordinates.length; ++i) {
      if (coordinates[i].longitude < minLon) {
        minLon = coordinates[i].longitude;
      }
      if (coordinates[i].latitude < minLat) {
        minLat = coordinates[i].latitude;
      }
      if (coordinates[i].longitude > maxLon) {
        maxLon = coordinates[i].longitude;
      }
      if (coordinates[i].latitude > maxLat) {
        maxLat = coordinates[i].latitude;
      }
    }
  }
}
