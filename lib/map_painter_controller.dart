import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'geometry.dart';

class MapPainterController with ChangeNotifier {
  /// zeroLon：Ox; plus a num > 0, the map moves right.
  /// zeroLat：Oy; plus a num > 0, the map moves down.
  double zeroLon = 119.544735;
  double zeroLat = 39.926761;

  /// divide a num > 1, the map zooms in.
  /// divide a num < 1, the map zooms out.
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

  /// Singleton Pattern.
  static MapPainterController get instance {
    if (_instance == null) {
      _instance = MapPainterController._internal();
      return _instance!;
    }
    return _instance!;
  }

  /// when drag with mouse_1 down.
  void onMapDrag(double dx, double dy) {
    zeroLon -= measuringScale * dx;
    // print(zeroLon);
    zeroLat += measuringScale * dy;
    notifyListeners();
  }

  /// when press zoomIn button
  void zoomIn() {
    measuringScale = measuringScale / 1.5;
    notifyListeners();
  }

  /// when press zoomOut button
  void zoomOut() {
    measuringScale = measuringScale * 1.5;
    notifyListeners();
  }

  /// use default origin and measuring scale
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

  /// zoom in/out map
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

  void selectPoint(int pid) {
    selectedPoint.value = pid;
    selectedArea.value = -1;
    notifyListeners();
  }

  void selectArea(int areaId) {
    selectedArea.value = areaId;
    selectedPoint.value = -1;
    notifyListeners();
  }
}
