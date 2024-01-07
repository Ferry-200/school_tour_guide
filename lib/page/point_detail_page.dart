import 'package:flutter/material.dart';
import '../geometry.dart';

import 'direct_page.dart';

class PointDetailPage extends StatelessWidget {
  const PointDetailPage(this.point, {super.key});

  final Point point;

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
              point.name,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          point.aka.isEmpty
              ? const SizedBox()
              : Text(
                  point.aka.join('、'),
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 14,
                  ),
                ),
          point.description.isEmpty
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
          point.description.isEmpty
              ? const SizedBox()
              : Text(
                  point.description,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 14,
                  ),
                ),
          Expanded(
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: FloatingActionButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => DirectPage(
                            end: point,
                            endName: point.name,
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
