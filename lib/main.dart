import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'geometry.dart';
import 'component/map_painter_container.dart';

void main() {
  MapData.fromJson("raw_map_data/all_features.json");
  runApp(const Entry());
}

class Entry extends StatelessWidget {
  const Entry({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate
      ],
      supportedLocales: const [
        Locale("zh", "CN"),
        Locale("en", "US"),
      ],
      theme: ThemeData(useMaterial3: true),
      home: const Scaffold(
        body: MapPainterContainer(),
      ),
    );
  }
}
