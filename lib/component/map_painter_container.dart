import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../geometry.dart';

import 'map_painter.dart';
import 'search_field.dart';
import 'side_panel.dart';

import '../map_painter_controller.dart';
import 'tour_dialog.dart';

class MapPainterContainer extends StatefulWidget {
  const MapPainterContainer({super.key});

  @override
  State<MapPainterContainer> createState() => _MapPainterContainerState();
}

class _MapPainterContainerState extends State<MapPainterContainer> {
  final MapPainterController controller = MapPainterController.instance;
  var left = ValueNotifier<double>(-380);

  void openRestoreDrawer() {
    left.value = left.value == -380 ? 0 : -380;
  }

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onPanUpdate: (details) {
        controller.onMapDrag(details.delta.dx, details.delta.dy);
      },
      onSecondaryTapDown: selectFromMap,
      child: Listener(
        onPointerSignal: (event) {
          GestureBinding.instance.pointerSignalResolver.register(
            event,
            (PointerSignalEvent event) {
              controller.onMouseWheeling(
                (event as PointerScrollEvent).scrollDelta.dy,
              );
            },
          );
        },
        child: CustomPaint(
          painter: MapPainter(controller),
          child: Stack(
            children: [
              const ZoomToolkits(),
              Positioned(
                left: 396,
                top: 16,
                child: tourDialogBtn(context, colorScheme),
              ),
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SearchField(openDrawer: openRestoreDrawer),
                ),
              ),
              ValueListenableBuilder(
                valueListenable: left,
                builder: (context, value, child) => AnimatedPositioned(
                  left: value,
                  duration: const Duration(milliseconds: 150),
                  curve: Curves.fastOutSlowIn,
                  child: const SidePanel(),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: drawerButton(),
              )
            ],
          ),
        ),
      ),
    );
  }

  void selectFromMap(TapDownDetails details) {
    var mapData = MapData.instance;

    var targetLon = details.localPosition.dx * controller.measuringScale +
        controller.zeroLon;
    var targetLat = controller.zeroLat -
        details.localPosition.dy * controller.measuringScale;
    var targetCoor = Coordinate(targetLon, targetLat);

    dynamic mostNear = mapData.visiblePoints.first;
    var minDistance = Coordinate.getDistance(targetCoor, mostNear.coordinate);

    for (var i = 1; i < mapData.visiblePoints.length; ++i) {
      var distance = Coordinate.getDistance(
        targetCoor,
        mapData.visiblePoints[i].coordinate,
      );
      if (distance < minDistance) {
        mostNear = mapData.visiblePoints[i];
        minDistance = distance;
      }
    }

    for (var area in mapData.areas) {
      for (var entry in area.entries) {
        var distance = Coordinate.getDistance(
          targetCoor,
          entry.coordinate,
        );
        if (distance < minDistance) {
          mostNear = area;
          minDistance = distance;
        }
      }
    }

    if (mostNear is Area) {
      controller.selectArea(mostNear.areaId);
      if (left.value == -380) {
        openRestoreDrawer();
      }
    } else if (mostNear is Point) {
      controller.selectPoint(mostNear.pid);
      if (left.value == -380) {
        openRestoreDrawer();
      }
    }
  }

  FloatingActionButton tourDialogBtn(
      BuildContext context, ColorScheme colorScheme) {
    return FloatingActionButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => const TourDialog(),
        );
      },
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      backgroundColor: colorScheme.surfaceVariant,
      foregroundColor: colorScheme.onSurface,
      child: const Icon(Icons.tour),
    );
  }

  SizedBox drawerButton() {
    return SizedBox(
      height: 128,
      width: 16,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.75),
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
        ),
        child: InkWell(
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
          onTap: () {
            // Scaffold.of(context).openDrawer();
            if (controller.selectedArea.value != -1 ||
                controller.selectedPoint.value != -1) {
              openRestoreDrawer();
              setState(() {});
            }
          },
          child: Center(
            child: Icon(
              left.value == -380 ? Icons.chevron_right : Icons.chevron_left,
              color: Colors.white,
              size: 16,
            ),
          ),
        ),
      ),
    );
  }
}

class ZoomToolkits extends StatelessWidget {
  const ZoomToolkits({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Wrap(
          spacing: 8.0,
          children: [
            IconButton(
              onPressed: () {
                MapPainterController.instance.zoomIn();
              },
              icon: const Icon(Icons.zoom_in),
            ),
            IconButton(
              onPressed: () {
                MapPainterController.instance.zoomOut();
              },
              icon: const Icon(Icons.zoom_out),
            ),
            IconButton(
              onPressed: () {
                MapPainterController.instance.restore();
              },
              icon: const Icon(Icons.settings_backup_restore),
            ),
          ],
        ),
      ),
    );
  }
}
