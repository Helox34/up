import 'package:flutter/foundation.dart';

class UnitsService with ChangeNotifier {
  String _weightUnit = 'kg';
  String _heightUnit = 'cm';

  String get weightUnit => _weightUnit;
  String get heightUnit => _heightUnit;

  void setWeightUnit(String unit) {
    _weightUnit = unit;
    notifyListeners();
  }

  void setHeightUnit(String unit) {
    _heightUnit = unit;
    notifyListeners();
  }

  // Konwersja jednostek
  double convertWeight(double weight) {
    if (_weightUnit == 'kg') {
      return weight;
    } else {
      return weight * 2.20462; // kg to lb
    }
  }

  double convertHeight(double height) {
    if (_heightUnit == 'cm') {
      return height;
    } else {
      return height * 0.393701; // cm to inches
    }
  }

  String getWeightUnitSymbol() {
    return _weightUnit;
  }

  String getHeightUnitSymbol() {
    return _heightUnit;
  }

  String formatWeight(double weight) {
    return '${convertWeight(weight).toStringAsFixed(1)} $weightUnit';
  }

  String formatHeight(double height) {
    return '${convertHeight(height).toStringAsFixed(1)} $heightUnit';
  }
}