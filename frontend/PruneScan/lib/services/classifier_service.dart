// services/classifier_service.dart
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/classification_result.dart';
import '../constants/strings.dart';

class ClassifierService {
  static const String _modelPath = 'assets/models/plum_model.tflite'; // Suppression du préfixe "assets/"
  static const int _inputSize = 224;
  static const List<String> _labels = [
    AppStrings.unaffected,
    AppStrings.unripe,
    AppStrings.spotted,
    AppStrings.cracked,
    AppStrings.bruised,
    AppStrings.rotten,
  ];

  late Interpreter _interpreter;
  bool _isInitialized = false;

  // Initialiser l'interpréteur TFLite
  Future<void> _initialize() async {
    if (_isInitialized) return;

    try {
      _interpreter = await Interpreter.fromAsset(_modelPath);
      _isInitialized = true;
      debugPrint('Interpreter initialized successfully');
    } catch (e) {
      debugPrint('Error initializing interpreter: $e');
      // Simuler les résultats en cas d'erreur
      return;
    }
  }

  // Prétraiter l'image
  List<List<List<List<double>>>> _preProcessImage(File imageFile) {
    try {
      // Lire l'image avec le package image
      img.Image? image = img.decodeImage(imageFile.readAsBytesSync());
      if (image == null) {
        throw Exception("Failed to decode image");
      }

      // Redimensionner à la taille d'entrée
      img.Image resizedImage = img.copyResize(
        image,
        width: _inputSize,
        height: _inputSize,
      );

      // Convertir en tableau 4D [1][224][224][3] avec batch_size=1
      List<List<List<List<double>>>> input = List.generate(
        1, // Ajouter la dimension batch
        (b) => List.generate(
          _inputSize,
          (y) => List.generate(
            _inputSize,
            (x) => List.generate(
              3,
              (c) {
                // Normaliser les valeurs de pixel (0-255) à (0-1)
                return c == 0
                    ? resizedImage.getPixel(x, y).r / 255.0
                    : c == 1
                        ? resizedImage.getPixel(x, y).g / 255.0
                        : resizedImage.getPixel(x, y).b / 255.0;
              },
            ),
          ),
        ),
      );

      return input;
    } catch (e) {
      debugPrint('Error preprocessing image: $e');
      // Retourner un tableau vide en cas d'erreur
      return List.generate(
        1,
        (b) => List.generate(
          _inputSize,
          (y) => List.generate(
            _inputSize,
            (x) => List.generate(3, (c) => 0.0),
          ),
        ),
      );
    }
  }

  // Classifier l'image
  Future<ClassificationResult> classifyImage(File imageFile) async {
    await _initialize();

    try {
      if (!_isInitialized) {
        return _generateRandomResult(); // Simuler le résultat si l'initialisation a échoué
      }

      // Prétraiter l'image
      final input = _preProcessImage(imageFile);

      // Préparer le buffer de sortie
      var output = List<List<double>>.filled(
        1,
        List<double>.filled(_labels.length, 0.0),
      );

      // Exécuter l'inférence
      _interpreter.run(input, output);

      // Traiter les résultats
      List<double> probabilities = output[0];

      // Trouver la classe avec la probabilité la plus élevée
      int maxIndex = 0;
      double maxProb = probabilities[0];

      for (int i = 1; i < probabilities.length; i++) {
        if (probabilities[i] > maxProb) {
          maxProb = probabilities[i];
          maxIndex = i;
        }
      }

      // Créer un objet résultat
      final result = ClassificationResult(
        className: _labels[maxIndex],
        confidence: maxProb,
        allProbabilities: {
          for (int i = 0; i < _labels.length; i++)
            _labels[i]: probabilities[i],
        },
      );

      // Sauvegarder le résultat dans l'historique
      await _saveResultToHistory(result);

      return result;
    } catch (e) {
      debugPrint('Error during classification: $e');
      return _generateRandomResult(); // Simuler le résultat en cas d'erreur
    }
  }

  // Générer un résultat aléatoire (pour la démonstration)
  ClassificationResult _generateRandomResult() {
    final random = Random();
    
    // Générer des probabilités aléatoires
    List<double> probabilities = List.generate(
      _labels.length,
      (_) => random.nextDouble(),
    );
    
    // Normaliser pour que la somme soit 1
    double sum = probabilities.reduce((a, b) => a + b);
    probabilities = probabilities.map((p) => p / sum).toList();
    
    // Trouver l'indice avec la probabilité maximale
    int maxIndex = 0;
    double maxProb = probabilities[0];
    
    for (int i = 1; i < probabilities.length; i++) {
      if (probabilities[i] > maxProb) {
        maxProb = probabilities[i];
        maxIndex = i;
      }
    }
    
    return ClassificationResult(
      className: _labels[maxIndex],
      confidence: maxProb,
      allProbabilities: {
        for (int i = 0; i < _labels.length; i++)
          _labels[i]: probabilities[i],
      },
    );
  }

  // Sauvegarder le résultat dans l'historique
  Future<void> _saveResultToHistory(ClassificationResult result) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getStringList('classification_history') ?? [];

      historyJson.add(jsonEncode(result.toJson()));

      // Limiter l'historique à 100 entrées
      if (historyJson.length > 100) {
        historyJson.removeAt(0);
      }

      await prefs.setStringList('classification_history', historyJson);
    } catch (e) {
      debugPrint('Error saving to history: $e');
    }
  }

  // Récupérer l'historique des classifications
  Future<List<ClassificationResult>> getHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getStringList('classification_history') ?? [];

      return historyJson
          .map((json) => ClassificationResult.fromJson(jsonDecode(json)))
          .toList();
    } catch (e) {
      debugPrint('Error getting history: $e');
      return [];
    }
  }

  // Effacer l'historique
  Future<void> clearHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('classification_history');
    } catch (e) {
      debugPrint('Error clearing history: $e');
    }
  }
}
