// services/units_service.dart - PEŁNA WERSJA Z SHARED_PREFERENCES
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UnitsService extends ChangeNotifier {
  static const String _weightUnitKey = 'weight_unit';
  static const String _heightUnitKey = 'height_unit';

  String _weightUnit = 'kg';
  String _heightUnit = 'cm';

  UnitsService() {
    _loadPreferences();
  }

  String get weightUnit => _weightUnit;
  String get heightUnit => _heightUnit;

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _weightUnit = prefs.getString(_weightUnitKey) ?? 'kg';
      _heightUnit = prefs.getString(_heightUnitKey) ?? 'cm';
      notifyListeners();
      print('✅ Załadowano preferencje jednostek: waga=$_weightUnit, wzrost=$_heightUnit');
    } catch (e) {
      print('❌ Błąd ładowania preferencji jednostek: $e');
    }
  }

  Future<void> setWeightUnit(String unit) async {
    _weightUnit = unit;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_weightUnitKey, unit);
      print('✅ Zapisano jednostkę wagi: $unit');
    } catch (e) {
      print('❌ Błąd zapisywania jednostki wagi: $e');
    }
  }

  Future<void> setHeightUnit(String unit) async {
    _heightUnit = unit;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_heightUnitKey, unit);
      print('✅ Zapisano jednostkę wzrostu: $unit');
    } catch (e) {
      print('❌ Błąd zapisywania jednostki wzrostu: $e');
    }
  }

  double convertWeight(double weight) {
    if (_weightUnit == 'kg') return weight;
    return weight * 2.20462; // kg to lbs
  }

  double convertHeight(double height) {
    if (_heightUnit == 'cm') return height;
    return height * 0.393701; // cm to inches
  }

  String formatWeight(double weight) {
    final convertedWeight = convertWeight(weight);
    return '${convertedWeight.toStringAsFixed(1)} $_weightUnit';
  }

  String formatHeight(double height) {
    final convertedHeight = convertHeight(height);
    return '${convertedHeight.toStringAsFixed(1)} $_heightUnit';
  }

  // Metody do konwersji z powrotem
  double toKg(double weight) {
    if (_weightUnit == 'kg') return weight;
    return weight * 0.453592; // lbs to kg
  }

  double toCm(double height) {
    if (_heightUnit == 'cm') return height;
    return height * 2.54; // inches to cm
  }
}