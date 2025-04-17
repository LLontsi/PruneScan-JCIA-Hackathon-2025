// widgets/result_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/colors.dart';
import '../models/classification_result.dart';

class ResultCard extends StatelessWidget {
  final ClassificationResult result;
  
  const ResultCard({
    Key? key,
    required this.result,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Formater la date
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final formattedDate = dateFormat.format(result.timestamp);
    
    // Obtenir la couleur associée à la classe
    Color classColor = _getColorForClass(result.className);
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec le résultat principal
            Row(
              children: [
                Icon(
                  _getIconForClass(result.className),
                  color: classColor,
                  size: 40,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Résultat',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        result.className,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: classColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${(result.confidence * 100).toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: classColor,
                  ),
                ),
              ],
            ),
            
            const Divider(height: 32),
            
            // Date de classification
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Classifié le $formattedDate',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Diagramme des probabilités
            Text(
              'Probabilités par classe',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Créer une barre de progression pour chaque classe
            ...result.allProbabilities.entries.map((entry) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 100,
                        child: Text(
                          entry.key,
                          style: Theme.of(context).textTheme.bodyMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Expanded(
                        child: LinearProgressIndicator(
                          value: entry.value,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(_getColorForClass(entry.key)),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        '${(entry.value * 100).toStringAsFixed(1)}%',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
  
  // Obtenir la couleur associée à chaque classe
  Color _getColorForClass(String className) {
    switch (className) {
      case 'Unaffected':
        return AppColors.goodQuality;
      case 'Unripe':
        return AppColors.unripe;
      case 'Spotted':
        return AppColors.spotted;
      case 'Cracked':
        return AppColors.cracked;
      case 'Bruised':
        return AppColors.bruised;
      case 'Rotten':
        return AppColors.rotten;
      default:
        return Colors.grey;
    }
  }
  
  // Obtenir l'icône associée à chaque classe
  IconData _getIconForClass(String className) {
    switch (className) {
      case 'unaffected':
        return Icons.check_circle;
      case 'Unripe':
        return Icons.access_time;
      case 'Spotted':
        return Icons.blur_on;
      case 'Cracked':
        return Icons.broken_image;
      case 'Bruised':
        return Icons.bubble_chart;
      case 'Rotten':
        return Icons.warning;
      default:
        return Icons.help;
    }
  }
}