import 'package:flutter/foundation.dart';

class FormNotifier extends ChangeNotifier {
  static final FormNotifier _instance = FormNotifier._internal();

  factory FormNotifier() => _instance;

  FormNotifier._internal();

  void notifyFormSubmitted() {
    notifyListeners();
  }

  void notifyFormDeleted() {
    notifyListeners();
  }

  void notifyMascotaRegistrada() {
    notifyListeners();
  }

  void notifyMascotaEliminada() {
    notifyListeners();
  }

  void notifyMascotaActualizada() {
    notifyListeners();
  }
}
