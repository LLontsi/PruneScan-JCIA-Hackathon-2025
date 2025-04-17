// models/classification_result.dart
class ClassificationResult {
  final String className;
  final double confidence;
  final Map<String, double> allProbabilities;
  final DateTime timestamp;

  ClassificationResult({
    required this.className,
    required this.confidence,
    required this.allProbabilities,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
  
  // Pour stocker le résultat localement
  Map<String, dynamic> toJson() {
    return {
      'className': className,
      'confidence': confidence,
      'allProbabilities': allProbabilities,
      'timestamp': timestamp.toIso8601String(),
    };
  }
  
  // Pour recréer un objet à partir des données stockées
  factory ClassificationResult.fromJson(Map<String, dynamic> json) {
    Map<String, double> probMap = {};
    (json['allProbabilities'] as Map<String, dynamic>).forEach((key, value) {
      probMap[key] = value.toDouble();
    });
    
    return ClassificationResult(
      className: json['className'],
      confidence: json['confidence'],
      allProbabilities: probMap,
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}