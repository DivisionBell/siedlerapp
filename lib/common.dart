

extension IterableExtension<T> on Iterable<T> {
  double sum(double Function(T entry) getValue) {
    double value = 0;
    for (T entry in this) {
      value += getValue(entry);
    }
    return value;
  }
}

extension NumExtension on num {
  String prettyString([int fractions = 0]) {
    if (this > 10000) {
      return "${(this / 1000).round()}k";
    } else {
      if (fractions == 0) return round().toString();
      return toStringAsFixed(fractions);
    }
  }
}
