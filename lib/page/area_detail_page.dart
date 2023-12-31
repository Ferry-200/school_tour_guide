import 'package:flutter/material.dart';
import '../component/side_panel.dart';

import '../geometry.dart';
import '../map_painter_controller.dart';

class AreaDetailPage extends StatefulWidget {
  const AreaDetailPage(this.area, {super.key});

  final Area area;

  @override
  State<AreaDetailPage> createState() => _AreaDetailPageState();
}

class _AreaDetailPageState extends State<AreaDetailPage> {
  Point? selectedEntry;
  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 12.0, bottom: 4.0),
            child: Text(
              widget.area.name,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          widget.area.aka.isEmpty
              ? const SizedBox()
              : Text(
                  widget.area.aka.join('、'),
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 14,
                  ),
                ),
          widget.area.description.isEmpty
              ? const SizedBox()
              : Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 4),
                  child: Text(
                    "简介",
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
          widget.area.description.isEmpty
              ? const SizedBox()
              : Text(
                  widget.area.description,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 14,
                  ),
                ),
          widget.area.contains.isEmpty
              ? const SizedBox()
              : Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 4),
                  child: Text(
                    "包含",
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
          widget.area.contains.isEmpty
              ? const SizedBox()
              : Text(
                  widget.area.contains.join('、'),
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 14,
                  ),
                ),
          Expanded(
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Wrap(
                        spacing: 8.0,
                        children: List<ChoiceChip>.generate(
                          widget.area.entries.length,
                          (index) => ChoiceChip(
                            label: Text("入口 $index"),
                            selected:
                                selectedEntry == widget.area.entries[index],
                            onSelected: (value) {
                              selectedEntry = widget.area.entries[index];
                              setState(() {});
                              var mapController = MapPainterController.instance;
                              mapController.locateToPoint(selectedEntry!);
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 56),
                    child: FloatingActionButton(
                      onPressed: () {
                        var select = selectedEntry ?? widget.area.entries.first;
                        var index = widget.area.entries.indexOf(select);
                        var mapController = MapPainterController.instance;
                        mapController.locateToPoint(select);
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => DirectPage(
                            end: select,
                            endName: "${widget.area.name} 入口 $index",
                          ),
                        ));
                      },
                      child: const Icon(Icons.directions),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
