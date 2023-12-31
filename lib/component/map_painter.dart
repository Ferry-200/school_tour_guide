import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../geometry.dart';
import '../map_painter_controller.dart';

class MapPainter extends CustomPainter {
  final MapPainterController controller;

  MapPainter(this.controller) : super(repaint: controller);

  final mapData = MapData.instance;

  final pointPainter = Paint()
    ..color = Colors.blueAccent
    ..style = PaintingStyle.fill
    ..strokeWidth = 2;

  final selectedPointPainter = Paint()
    ..color = Colors.redAccent
    ..style = PaintingStyle.fill
    ..strokeWidth = 2;

  final linePainter = Paint()
    ..color = Colors.grey
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;

  final carriageLinePainter = Paint()
    ..color = Colors.grey
    ..style = PaintingStyle.stroke
    ..strokeWidth = 4;

  final areaPainter = Paint()
    ..color = Colors.brown
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;

  final selectedAreaPainter = Paint()
    ..color = Colors.redAccent
    ..style = PaintingStyle.stroke
    ..strokeWidth = 4;

  final bestPathPainter = Paint()
    ..color = Colors.green
    ..style = PaintingStyle.stroke
    ..strokeWidth = 4;

  /// 119.544735, 39.926761
  double latToLocalY(double lat) =>
      (controller.zeroLat - lat) / controller.measuringScale;

  double lonToLocalX(double lon) =>
      (lon - controller.zeroLon) / controller.measuringScale;

  @override
  void paint(Canvas canvas, Size size) {
    drawLines(canvas);
    drawAreas(canvas, controller.selectedArea.value);
    drawPoints(canvas, controller.selectedPoint.value);
    drawBestPath(canvas, controller.bestPath);
  }

  void drawLines(Canvas canvas) {
    for (var line in mapData.lines) {
      var localLon1 = lonToLocalX(line.coordinates.first.longitude);
      var localLat1 = latToLocalY(line.coordinates.first.latitude);
      var path = Path()..moveTo(localLon1, localLat1);

      for (int i = 1; i < line.coordinates.length; ++i) {
        path.lineTo(
          lonToLocalX(line.coordinates[i].longitude),
          latToLocalY(line.coordinates[i].latitude),
        );
      }
      if (line.isCarriageway) {
        canvas.drawPath(path, carriageLinePainter);
      } else {
        canvas.drawPath(path, linePainter);
      }
    }
  }

  void drawAreas(Canvas canvas, int select) {
    for (var area in mapData.areas) {
      var path = Path()
        ..moveTo(
          lonToLocalX(area.coordinates.first.longitude),
          latToLocalY(area.coordinates.first.latitude),
        );

      for (int i = 1; i < area.coordinates.length; ++i) {
        path.lineTo(
          lonToLocalX(area.coordinates[i].longitude),
          latToLocalY(area.coordinates[i].latitude),
        );
      }
      canvas.drawPath(
        path,
        area.areaId == select ? selectedAreaPainter : areaPainter,
      );

      var builder = ui.ParagraphBuilder(ui.ParagraphStyle());
      builder.pushStyle(ui.TextStyle(
        color: Colors.black,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ));
      builder.addText(area.name);

      var para = builder.build();
      para.layout(ui.ParagraphConstraints(width: area.name.length * 12));

      if (area.areaId == select ||
          (lonToLocalX(area.maxLon) - lonToLocalX(area.minLon) > para.width &&
              latToLocalY(area.minLat) - latToLocalY(area.maxLat) >
                  para.height)) {
        canvas.drawParagraph(
          para,
          Offset(
            lonToLocalX((area.minLon + area.maxLon) / 2) - (para.width / 2),
            latToLocalY((area.minLat + area.maxLat) / 2) - (para.height / 2),
          ),
        );
      }
    }
  }

  void drawPoints(Canvas canvas, int select) {
    for (var point in mapData.allPoints) {
      if (point.visibility ||
          point.pid == controller.selectedPoint.value ||
          point.pid == controller.secondarySelectPoint) {
        var localLon = lonToLocalX(point.coordinate.longitude);
        var localLat = latToLocalY(point.coordinate.latitude);
        canvas.drawCircle(
          Offset(localLon, localLat),
          4,
          point.pid == select ? selectedPointPainter : pointPainter,
        );

        if (controller.measuringScale <=
            controller.defaultMeasuringScale / 2.25) {
          var builder = ui.ParagraphBuilder(ui.ParagraphStyle());
          builder.pushStyle(ui.TextStyle(
            color: point.pid == select ? Colors.redAccent : Colors.blue,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ));
          builder.addText(point.name);

          var para = builder.build();
          para.layout(ui.ParagraphConstraints(width: point.name.length * 12));
          canvas.drawParagraph(
            para,
            Offset(
              localLon - (para.width / 2),
              localLat + 4,
            ),
          );
        }
      }
    }
  }

  void drawBestPath(Canvas canvas, List<Line> bestPath) {
    for (var line in bestPath) {
      var path = Path()
        ..moveTo(
          lonToLocalX(line.coordinates.first.longitude),
          latToLocalY(line.coordinates.first.latitude),
        );

      for (int i = 1; i < line.coordinates.length; ++i) {
        path.lineTo(
          lonToLocalX(line.coordinates[i].longitude),
          latToLocalY(line.coordinates[i].latitude),
        );
      }
      canvas.drawPath(path, bestPathPainter);
    }
  }

  @override
  bool shouldRepaint(MapPainter oldDelegate) => false;

  @override
  bool shouldRebuildSemantics(MapPainter oldDelegate) => false;
}