import 'package:flutter/material.dart';
import 'search_field.dart';
import '../geometry.dart';
import '../map_painter_controller.dart';
import '../page/area_detail_page.dart';
import '../page/point_detail_page.dart';
import 'dart:ui' as ui;

class SidePanel extends StatelessWidget {
  const SidePanel({super.key});

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;
    var mainWindow = ui.PlatformDispatcher.instance.views.first;
    var size = mainWindow.physicalSize / 1.5;
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 80, bottom: 16),
      child: SizedBox(
        width: 364,
        height: size.height - 96,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: colorScheme.surface,
            boxShadow: kElevationToShadow[4],
          ),
          child: Navigator(
            onGenerateRoute: (settings) {
              return MaterialPageRoute(
                builder: (context) {
                  return ListenableBuilder(
                    listenable: Listenable.merge([
                      MapPainterController.instance.selectedPoint,
                      MapPainterController.instance.selectedArea,
                    ]),
                    builder: (context, child) {
                      var mapController = MapPainterController.instance;
                      var mapData = MapData.instance;
                      dynamic select;
                      if (mapController.selectedPoint.value != -1) {
                        select = mapData
                            .allPoints[mapController.selectedPoint.value];
                        return PointDetailPage(select);
                      } else if (mapController.selectedArea.value != -1) {
                        select =
                            mapData.areas[mapController.selectedArea.value];
                        return AreaDetailPage(select);
                      }

                      return const Center(child: Text("Error Occurs"));
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
