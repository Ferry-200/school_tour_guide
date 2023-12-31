import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'geometry.dart';

class MapPainterController with ChangeNotifier {
  /// 右移：图向左移
  /// 上移：图向下移
  double zeroLon = 119.544735;
  double zeroLat = 39.926761;

  /// °/px
  /// 除一个大于一的数 => 放大
  /// 除一个小于一的数 => 缩小
  double measuringScale = 0.0000120828;

  ValueNotifier<int> selectedPoint = ValueNotifier<int>(-1);
  ValueNotifier<int> selectedArea = ValueNotifier<int>(-1);

  int secondarySelectPoint = -1;

  List<Line> bestPath = [];

  double get defaultZeroLon => 119.544735;
  double get defaultZeroLat => 39.926761;
  double get defaultMeasuringScale => 0.0000120828;

  MapPainterController._internal();

  static MapPainterController? _instance;

  static MapPainterController get instance {
    if (_instance == null) {
      _instance = MapPainterController._internal();
      return _instance!;
    }
    return _instance!;
  }

  void onMapDrag(double dx, double dy) {
    zeroLon -= measuringScale * dx;
    // print(zeroLon);
    zeroLat += measuringScale * dy;
    notifyListeners();
  }

  void zoomIn() {
    measuringScale = measuringScale / 1.5;
    notifyListeners();
  }

  void zoomOut() {
    measuringScale = measuringScale * 1.5;
    notifyListeners();
  }

  void restore() {
    zeroLat = defaultZeroLat;
    zeroLon = defaultZeroLon;
    measuringScale = defaultMeasuringScale;
    notifyListeners();
  }

  void updateBestPath(List<Line> newBest) {
    bestPath = newBest;
    notifyListeners();
  }

  /// 使用滚轮放大/缩小
  void onMouseWheeling(double dy) {
    measuringScale = measuringScale * (1 + dy / 1000);
    notifyListeners();
  }

  void locateToPoint(Point p) {
    var mainWindow = ui.PlatformDispatcher.instance.views.first;
    var size = mainWindow.physicalSize / 1.5;

    measuringScale = defaultMeasuringScale / 3.375;
    zeroLon =
        p.coordinate.longitude - measuringScale * ((size.width + 380) / 2);
    zeroLat = p.coordinate.latitude + measuringScale * (size.height / 2);
    secondarySelectPoint = p.pid;
    notifyListeners();
  }

  void locateToArea(Area area) {
    var mainWindow = ui.PlatformDispatcher.instance.views.first;
    var size = mainWindow.physicalSize / 1.5;

    var lon = (area.maxLon + area.minLon) / 2;
    var lat = (area.maxLat + area.minLat) / 2;

    measuringScale = defaultMeasuringScale / 3.375;
    zeroLon = lon - measuringScale * ((size.width + 380) / 2);
    zeroLat = lat + measuringScale * (size.height / 2);
    notifyListeners();
  }

  void selectPoint(int pid){
    selectedPoint.value = pid;
    selectedArea.value = -1;
    notifyListeners();
  }

  void selectArea(int areaId){
    selectedArea.value = areaId;
    selectedPoint.value = -1;
    notifyListeners();
  }
}
