
enum Building {
  nadelholzfoerster("Nadelholzförster", 2*60+15, {}, Commodity.nadelholzbaum, 1, true),
  nadelholzfaeller("Nadelholzfäller", 1*60+30, {Commodity.nadelholzbaum: 1}, Commodity.nadelholz, 1, true),
  koehlerei("Köhlerei", 3*60, {Commodity.nadelholz: 2}, Commodity.kohle, 1, true),
  recycling("Recyclingmanufraktur", 3*60, {}, Commodity.kohle, 1, false),
  eisenschmelze("Eisenschmelze", 12*60, {Commodity.kohle: 6, Commodity.eisenerz: 4}, Commodity.eisen, 1, true),
  stahlschmelze("Stahlschmelze", 12*60, {Commodity.kohle: 6, Commodity.eisen: 2}, Commodity.stahl, 1, true),
  stahlwaffenschmiede("Stahlwaffenschmiede", 16*60+40, {Commodity.kohle: 16, Commodity.stahl: 2}, Commodity.stahlschwert, 1, true, true),
  platinschmelze("Platinschmelze", 18*60, {Commodity.kohle: 16, Commodity.platinerz: 2}, Commodity.platin, 1, true),
  platinwaffenschmiede("Platinwaffenschmiede", 38*60, {Commodity.kohle: 32, Commodity.platin: 4}, Commodity.platinschwert, 1, true, true),
  unerschoepflicheEisenmine("Unerschöpfliche Eisenmine", 2*60+24, {}, Commodity.eisenerz, 2, false),
  unerschoepflicheKohlemine("Unerschöpfliche Kohlemine", 30, {}, Commodity.kohle, 2, false),
  ;
  const Building(this.name2, this.basisZeit, this.input, this.output, this.outputAnzahl, this.baugenehmigung, [this.isSchmiede = false]);
  final String name2;
  final int basisZeit;
  final Map<Commodity, int> input;
  final Commodity output;
  final int outputAnzahl;
  final bool baugenehmigung;
  final bool isSchmiede;
}

enum Commodity {
  nadelholzbaum("Nadelholzbaum"),
  nadelholz("Nadelholz"),
  kohle("Kohle"),
  eisen("Eisen"),
  stahl("Stahl"),
  platin("Platin"),
  platinschwert("Platinschwerter"),
  stahlschwert("Stahlschwerter"),
  platinerz("Platinerz"),
  eisenerz("Eisenerz"),
  ;
  const Commodity(this.name2);
  final String name2;
}

class BuildingInstance {
  BuildingInstance({required this.building, this.level = 7, this.quantity = 1, this.buffPercent = 100, this.zoneBuffPercent = 0, this.needPercent = 100});
  Building building;
  int level;
  int quantity;
  late bool fixedQuantity = !building.baugenehmigung;
  int buffPercent;
  int zoneBuffPercent;
  int needPercent;

  double get productionPerDay => cyclesPerDay * building.outputAnzahl * level * ((Player.current.isPff ? 2 : 1) * (1 + buffPercent / 100) + zoneBuffPercent / 100);
  double get productionTime => (building.basisZeit + Player.current.averageWalkingSeconds * 4) * (Player.current.isPff && building.isSchmiede ? 0.5 : 1);
  double get cyclesPerDay => 24 * 60 / ((productionTime) / 60);
  double needsPerDay(Commodity commodity) => (building.input[commodity] ?? 0) * level * cyclesPerDay * needPercent / 100;
}

class Player {
  static Player current = Player();
  bool isPff = true;
  int averageWalkingSeconds = 14;
}
