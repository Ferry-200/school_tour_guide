import 'package:flutter/material.dart';
import '../geometry.dart';

import '../map_painter_controller.dart';

class SearchField extends StatefulWidget {
  const SearchField({super.key, required this.openDrawer});

  final Function() openDrawer;

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  final controller = TextEditingController();
  double columnHeight = 56;
  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;

    return PhysicalModel(
      color: colorScheme.surfaceVariant,
      borderRadius: BorderRadius.circular(12),
      elevation: 4.0,
      child: AnimatedSize(
        alignment: Alignment.topCenter,
        curve: Curves.fastOutSlowIn,
        duration: const Duration(milliseconds: 150),
        child: SizedBox(
          height: columnHeight,
          child: Column(
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints.expand(
                  width: 364,
                  height: 56,
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 12, right: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: TextField(
                          cursorColor: colorScheme.onSurface,
                          controller: controller,
                          decoration: const InputDecoration(
                            hintText: "搜索地点",
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          ),
                          onTap: () {
                            columnHeight = 456;
                            setState(() {});
                          },
                          onTapOutside: (event) {
                            if (event.position.dy > 464 ||
                                event.position.dx > 380) {
                              columnHeight = 56;
                              controller.clear();
                              setState(() {});
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.search),
                    ],
                  ),
                ),
              ),
              SearchSuggetionView(
                textEditingController: controller,
                whenPointSelected: (point) {
                  var mapController = MapPainterController.instance;
                  mapController.selectPoint(point.pid);
                  mapController.locateToPoint(point);
                  controller.clear();
                  columnHeight = 56;
                  setState(() {});
                  // Scaffold.of(context).openDrawer();
                  widget.openDrawer();
                },
                whenAreaSelected: (area) {
                  var mapController = MapPainterController.instance;
                  mapController.selectArea(area.areaId);
                  mapController.locateToArea(area);
                  controller.clear();
                  columnHeight = 56;
                  setState(() {});
                  // Scaffold.of(context).openDrawer();
                  widget.openDrawer();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SearchSuggetionView extends StatefulWidget {
  const SearchSuggetionView({
    super.key,
    required this.textEditingController,
    required this.whenAreaSelected,
    required this.whenPointSelected,
  });

  final TextEditingController textEditingController;

  final Function(Area area) whenAreaSelected;
  final Function(Point point) whenPointSelected;

  @override
  State<SearchSuggetionView> createState() => _SearchSuggetionViewState();
}

class _SearchSuggetionViewState extends State<SearchSuggetionView> {
  void listener() {
    suggetions = buildSuggetions();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    widget.textEditingController.addListener(listener);
  }

  @override
  void didUpdateWidget(SearchSuggetionView oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget.textEditingController.removeListener(listener);
    widget.textEditingController.addListener(listener);
  }

  @override
  void dispose() {
    widget.textEditingController.removeListener(listener);
    super.dispose();
  }

  List<ListTile> suggetions = [];

  List<ListTile> buildSuggetions() {
    if (widget.textEditingController.text.trim().isEmpty) {
      return [];
    }
    var mapData = MapData.instance;
    List<ListTile> suggetions = [];
    for (var point in mapData.visiblePoints) {
      if (point.name.contains(widget.textEditingController.text)) {
        suggetions.add(ListTile(
          title: Text(point.name),
          onTap: () {
            widget.whenPointSelected(point);
          },
        ));
      }

      for (String akaItem in point.aka) {
        if (akaItem.contains(widget.textEditingController.text)) {
          suggetions.add(ListTile(
            title: Text(akaItem),
            subtitle: Text(point.name),
            onTap: () {
              widget.whenPointSelected(point);
            },
          ));
        }
      }
    }

    for (var area in mapData.areas) {
      if (area.name.contains(widget.textEditingController.text)) {
        suggetions.add(ListTile(
          title: Text(area.name),
          onTap: () {
            widget.whenAreaSelected(area);
          },
        ));
      }

      for (String item in area.contains) {
        if (item.contains(widget.textEditingController.text)) {
          suggetions.add(ListTile(
            title: Text(item),
            subtitle: Text(area.name),
            onTap: () {
              widget.whenAreaSelected(area);
            },
          ));
        }
      }

      for (String akaItem in area.aka) {
        if (akaItem.contains(widget.textEditingController.text)) {
          suggetions.add(ListTile(
            title: Text(akaItem),
            subtitle: Text(area.name),
            onTap: () {
              widget.whenAreaSelected(area);
            },
          ));
        }
      }
    }
    return suggetions;
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints.expand(width: 364, height: 400),
      child: Material(
        color: Colors.transparent,
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          children: suggetions,
        ),
      ),
    );
  }
}
