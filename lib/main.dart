// ignore_for_file: avoid_function_literals_in_foreach_calls
import 'dart:math';
import 'dart:ui';
import 'package:collection/collection.dart';
import 'package:siedlerapp/buildings.dart';
import 'package:siedlerapp/common.dart';
import 'package:siedlerapp/widgets.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DSO',
      scrollBehavior: _MyCustomScrollBehavior(),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override State<MyHomePage> createState() => _MyHomePageState();
}

class CommodityStats {
  double productionPerDay = 0;
  double needsPerDay = 0;
  double get nettoPerDay => productionPerDay - needsPerDay;
}

class _MyHomePageState extends State<MyHomePage> {
  final List<BuildingInstance> _buildings = [
    BuildingInstance(building: Building.unerschoepflicheEisenmine, quantity: 6, buffPercent: 300)..fixedQuantity = true,
    BuildingInstance(building: Building.unerschoepflicheKohlemine, quantity: 3, buffPercent: 300)..fixedQuantity = true,
    BuildingInstance(building: Building.recycling, quantity: 20, buffPercent: 300)..fixedQuantity = true,
    BuildingInstance(building: Building.nadelholzfoerster, buffPercent: 300),
    BuildingInstance(building: Building.nadelholzfaeller),
    BuildingInstance(building: Building.koehlerei),

    BuildingInstance(building: Building.eisenschmelze),
    BuildingInstance(building: Building.stahlschmelze),
    BuildingInstance(building: Building.stahlwaffenschmiede, quantity: 65, zoneBuffPercent: 700)..fixedQuantity = true,

    BuildingInstance(building: Building.platinschmelze),
    BuildingInstance(building: Building.platinwaffenschmiede, quantity: 21, zoneBuffPercent: 700)..fixedQuantity = true,
  ];
  String? _error;
  Map<Commodity, CommodityStats> commodityStats = {};
  final ScrollController _buildingsScrollController = ScrollController();

  void _calculateStatistics() {
    commodityStats = { for (var c in Commodity.values) c: CommodityStats() };
    for (var building in _buildings) {
      final stats = commodityStats[building.building.output]!;
      stats.productionPerDay += building.productionPerDay * building.quantity;
      for (var inputCommodity in building.building.input.keys) {
        commodityStats[inputCommodity]!.needsPerDay += building.needsPerDay(inputCommodity) * building.quantity;
      }
    }
  }

  @override Widget build(BuildContext context) {
    _calculateStatistics();
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("PFF: "),
                    Checkbox(
                      value: Player.current.isPff,
                      onChanged: (value) => setState(() => Player.current.isPff = value ?? false),
                    ),
                    const SizedBox(width: 20),
                    const Text("⌀ Laufwege: "),
                    MyTextField(
                      onChanged: (value) => setState(() => Player.current.averageWalkingSeconds = int.tryParse(value) ?? 0),
                      initialText: Player.current.averageWalkingSeconds.toString(),
                    ),
                  ],
                ),

                const Padding(padding: EdgeInsets.all(30), child: Divider()),

                DropdownButton<Building>(
                  items: Building.values.map((building) => DropdownMenuItem(value: building, child: Text(building.name2))).toList(),
                  onChanged: (building) => setState(() {
                    _buildings.add(BuildingInstance(building: building!));
                  }),
                  hint: const Text("Füge ein Gebäude hinzu"),
                ),
                RawScrollbar(
                  thumbVisibility: true,//
                  thickness: 10,
                  trackVisibility: true,
                  controller: _buildingsScrollController,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    controller: _buildingsScrollController,
                    child: DataTable(
                      columnSpacing: 45,
                      columns: const [
                        DataColumn(label: Text("Gebäude")),
                        DataColumn(label: Text("Anzahl")),
                        DataColumn(label: Text("Fixiere\nAnzahl")),
                        DataColumn(label: Text("Level")),
                        DataColumn(label: Text("Produktions-\ndauer in m")),
                        DataColumn(label: Text("Zyklen /\nTag")),
                        DataColumn(label: Text("Buff %")),
                        DataColumn(label: Text("Zone\nBuff %")),
                        DataColumn(label: Text("Bedarf %")),

                        DataColumn(label: Text("Bedarf / Tag\nPro Gebäude")),
                        DataColumn(label: Text("Bedarf / Tag\nGesamt")),
                        DataColumn(label: Text("Produktion / Tag\nPro Gebäude")),
                        DataColumn(label: Text("Produktion / Tag\nGesamt")),

                        DataColumn(label: Text("Entfernen")),
                      ],
                      rows: [
                        for (var building in _buildings)
                          DataRow(
                            cells: [
                              DataCell(Text(building.building.name2)),
                              DataCell(MyTextField(
                                initialText: building.quantity.toString(),
                                onChanged: (value) => setState(() => building.quantity = int.tryParse(value) ?? 0),
                              )),
                              DataCell(Checkbox(
                                value: building.fixedQuantity,
                                onChanged: (value) => setState(() => building.fixedQuantity = value ?? false),
                              )),
                              DataCell(MyTextField(
                                initialText: building.level.toString(),
                                onChanged: (value) => setState(() => building.level = int.tryParse(value) ?? 1),
                              )),
                              DataCell(Text((building.productionTime / 60).prettyString(2))),
                              DataCell(Text((building.cyclesPerDay).prettyString(1))),
                              DataCell(MyTextField(
                                initialText: building.buffPercent.toString(),
                                onChanged: (value) => setState(() => building.buffPercent = int.tryParse(value) ?? 0),
                              )),
                              DataCell(MyTextField(
                                initialText: building.zoneBuffPercent.toString(),
                                onChanged: (value) => setState(() => building.zoneBuffPercent = int.tryParse(value) ?? 0),
                              )),
                              DataCell(MyTextField(
                                initialText: building.needPercent.toString(),
                                onChanged: (value) => setState(() => building.needPercent = int.tryParse(value) ?? 0),
                              )),

                              DataCell(Text(building.building.input.keys.map((c) => "${(building.needsPerDay(c))                    .prettyString()} ${c.name2}").join(", "))),
                              DataCell(Text(building.building.input.keys.map((c) => "${(building.needsPerDay(c) * building.quantity).prettyString()} ${c.name2}").join(", "))),
                              DataCell(Text("${                     building.productionPerDay .prettyString()} ${building.building.output.name2}")),
                              DataCell(Text("${(building.quantity * building.productionPerDay).prettyString()} ${building.building.output.name2}")),

                              DataCell(IconButton(icon: const Icon(Icons.delete), onPressed: () => setState(() => _buildings.remove(building)))),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),

                const Padding(padding: EdgeInsets.all(30), child: Divider()),

                Text("${_buildings.sum((entry) => entry.quantity.toDouble()).round()} Gebäude & ${_buildings.sum((entry) => entry.building.baugenehmigung ? entry.quantity.toDouble() : 0).round()} Baugenehmigungen"),
                const SizedBox(height: 10),
                Wrap(
                  children: [
                    ElevatedButton(
                      onPressed: () => setState(() => _buildings.where((b) => !b.fixedQuantity).forEach((b) => b.quantity++)),
                      child: const Text("+ Gebäude"),
                    ),
                    const SizedBox(width: 5),
                    ElevatedButton(
                      onPressed: () => setState(() => _buildings.where((b) => !b.fixedQuantity).forEach((b) => b.quantity = max(0, b.quantity - 1))),
                      child: const Text("- Gebäude"),
                    ),
                    const SizedBox(width: 5),
                    ElevatedButton(
                      onPressed: () => setState(() => _buildings.forEach((b) => b.level = min(7, b.level + 1))),
                      child: const Text("+ Gebäude Level"),
                    ),
                    const SizedBox(width: 5),
                    ElevatedButton(
                      onPressed: () => setState(() => _buildings.forEach((b) => b.level = max(1, b.level - 1))),
                      child: const Text("- Gebäude Level"),
                    ),
                    const SizedBox(width: 5),
                    ElevatedButton(
                      onPressed: () => setState(() => _buildings.where((b) => !b.fixedQuantity).forEach((b) => b.quantity = 0)),
                      child: const Text("Setze Gebäudeanzahl auf 0"),
                    ),
                    const SizedBox(width: 5),
                    ElevatedButton(
                      onPressed: () => setState(() {
                        _error = null;
                        for (var building in _buildings) {
                          if (building.fixedQuantity) continue;
                          building.quantity = 0;
                        }
                        _calculateStatistics();
                        bool needMoreCommodities;
                        do {
                          needMoreCommodities = false;
                          for (var stat in commodityStats.entries) {
                            if (stat.value.nettoPerDay >= 0) continue;
                            var building = _buildings.firstWhereOrNull((e) => e.building.output == stat.key && e.fixedQuantity == false);
                            if (building == null) continue;
                            needMoreCommodities = true;
                            building.quantity++;
                            _calculateStatistics();
                          }
                        } while (needMoreCommodities);
                      }),
                      child: const Text("Setze Gebäudeanzahl automatisch"),
                    ),
                  ],
                ),
                if (_error != null) Text(_error!),

                const Padding(padding: EdgeInsets.all(30), child: Divider()),

                DataTable(
                  columns: const [
                    DataColumn(label: Text("Rohstoff")),
                    DataColumn(label: Text("Produktion / Tag")),
                    DataColumn(label: Text("Bedarf / Tag")),
                    DataColumn(label: Text("Netto / Tag")),
                  ],
                  rows: [
                    for (var stat in commodityStats.entries)
                      DataRow(
                        cells: [
                          DataCell(Text(stat.key.name2)),
                          DataCell(Text(stat.value.productionPerDay.prettyString())),
                          DataCell(Text(stat.value.needsPerDay.prettyString())),
                          DataCell(Text(stat.value.nettoPerDay.prettyString())),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
  };
}
