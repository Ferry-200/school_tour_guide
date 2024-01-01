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

class DirectPage extends StatefulWidget {
  const DirectPage({super.key, required this.end, required this.endName});

  final Point end;
  final String endName;

  @override
  State<DirectPage> createState() => _DirectPageState();
}

class _DirectPageState extends State<DirectPage> {
  var textEditingController = TextEditingController();
  double startSelectFieldHeight = 56;
  Area? selectedArea;
  Point? selectedStart;
  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;
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
                const Text("路线", style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 4, left: 12),
            child: Text(
              "终点",
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: Text(
              widget.endName,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 16,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 4, left: 12),
            child: Text(
              "起点",
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: SizedBox(
              height: startSelectFieldHeight,
              child: Column(
                children: [
                  TextField(
                    controller: textEditingController,
                    onTap: () {
                      startSelectFieldHeight = 164;
                      setState(() {});
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                  Expanded(
                    child: SearchSuggetionView(
                      textEditingController: textEditingController,
                      whenAreaSelected: (area) {
                        selectedArea = area;
                        startSelectFieldHeight = 56;
                        textEditingController.text = area.name;
                        setState(() {});
                      },
                      whenPointSelected: (point) {
                        selectedStart = point;
                        selectedArea = null;
                        startSelectFieldHeight = 56;
                        textEditingController.text = point.name;
                        setState(() {});
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
          selectedArea != null
              ? Padding(
                  padding: const EdgeInsets.only(top: 4.0, left: 12, right: 12),
                  child: SingleChildScrollView(
                    child: Wrap(
                      spacing: 8,
                      children: List.generate(
                        selectedArea!.entries.length,
                        (index) => ChoiceChip(
                          label: Text("出口 $index"),
                          selected:
                              selectedStart == selectedArea!.entries[index],
                          onSelected: (value) {
                            selectedStart = selectedArea!.entries[index];
                            setState(() {});
                            var mapController = MapPainterController.instance;
                            mapController.locateToPoint(selectedStart!);
                          },
                        ),
                      ),
                    ),
                  ),
                )
              : const SizedBox(),
          Expanded(
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16.0, right: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        directionRun(context),
                        const SizedBox(width: 16),
                        directionCar(context),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  FloatingActionButton directionCar(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        if (selectedStart != null) {
          var path = aStarPathFinding(
            selectedStart!,
            widget.end,
            onlyCarriageway: true,
          );
          if (path != null) {
            double distance = 0;
            for (var line in path) {
              distance += line.distance;
            }
            MapPainterController.instance.updateBestPath(path);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("路径规划成功，全程 ${distance.round()} 米"),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("可行路径不存在")),
            );
            MapPainterController.instance.updateBestPath([]);
          }
        } else if (selectedArea != null) {
          var path = aStarPathFinding(
            selectedArea!.entries.first,
            widget.end,
            onlyCarriageway: true,
          );
          if (path != null) {
            double distance = 0;
            for (var line in path) {
              distance += line.distance;
            }
            MapPainterController.instance.updateBestPath(path);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("路径规划成功，全程 ${distance.round()} 米"),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("可行路径不存在")),
            );
            MapPainterController.instance.updateBestPath([]);
          }
        }
      },
      child: const Icon(Icons.directions_car),
    );
  }

  FloatingActionButton directionRun(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        if (selectedStart != null) {
          var path = aStarPathFinding(
            selectedStart!,
            widget.end,
            onlyCarriageway: false,
          );
          if (path != null) {
            double distance = 0;
            for (var line in path) {
              distance += line.distance;
            }
            MapPainterController.instance.updateBestPath(path);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("路径规划成功，全程 ${distance.round()} 米"),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("可行路径不存在")),
            );
            MapPainterController.instance.updateBestPath([]);
          }
        } else if (selectedArea != null) {
          var path = aStarPathFinding(
            selectedArea!.entries.first,
            widget.end,
            onlyCarriageway: false,
          );
          if (path != null) {
            double distance = 0;
            for (var line in path) {
              distance += line.distance;
            }
            MapPainterController.instance.updateBestPath(path);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("路径规划成功，全程 ${distance.round()} 米"),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("可行路径不存在")),
            );
            MapPainterController.instance.updateBestPath([]);
          }
        }
      },
      child: const Icon(Icons.directions_run),
    );
  }
}
