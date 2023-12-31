import 'package:flutter/material.dart';

import '../geometry.dart';
import '../map_painter_controller.dart';

class TourDialog extends StatefulWidget {
  const TourDialog({super.key});

  @override
  State<TourDialog> createState() => _TourDialogState();
}

class _TourDialogState extends State<TourDialog> {
  final tourList = MapData.instance.spots;
  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;
    return Dialog(
      child: SizedBox(
        height: 400,
        width: 364,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: colorScheme.surfaceVariant,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(
                  left: 12,
                  top: 12,
                  bottom: 8,
                ),
                child: Text(
                  "环游",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                child: CustomScrollView(
                  /// Build point and area selectable list separately here.
                  slivers: [
                    pointSlivers(),
                    areaSlivers(),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    planPath(context),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  TextButton planPath(BuildContext context) {
    return TextButton(
      onPressed: () {
        var path = <Line>[];
        for (var i = 0; i < tourList.length - 1; ++i) {
          path.addAll(
            aStarPathFinding(
                  tourList[i],
                  tourList[i + 1],
                  onlyCarriageway: false,
                ) ??
                [],
          );
        }
        MapPainterController.instance.updateBestPath(path);
        Navigator.of(context).pop();
      },
      child: const Text("规划路线"),
    );
  }

  SliverList areaSlivers() {
    return SliverList.builder(
      itemCount: MapData.instance.areas.length,
      itemBuilder: (context, index) {
        var area = MapData.instance.areas[index];
        return ListTile(
          title: Text(area.name),
          trailing: Wrap(
            spacing: 4,
            children: List<Column>.generate(
              area.entries.length,
              (index) => Column(
                children: [
                  Text(
                    "$index",
                    style: const TextStyle(fontSize: 10),
                  ),
                  Checkbox(
                    value: tourList.contains(area.entries[index]),
                    onChanged: tourList.contains(area.entries[index])
                        ? (value) {
                            tourList.remove(area.entries[index]);
                            setState(() {});
                          }
                        : (value) {
                            tourList.add(area.entries[index]);
                            setState(() {});
                          },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  SliverList pointSlivers() {
    return SliverList.builder(
      itemCount: MapData.instance.visiblePoints.length,
      itemBuilder: (context, index) {
        var point = MapData.instance.visiblePoints[index];
        return ListTile(
          title: Text(point.name),
          trailing: Checkbox(
            value: tourList.contains(point),
            onChanged: tourList.contains(point)
                ? (value) {
                    tourList.remove(point);
                    setState(() {});
                  }
                : (value) {
                    tourList.add(point);
                    setState(() {});
                  },
          ),
        );
      },
    );
  }
}
