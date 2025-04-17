// screens/history_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/colors.dart';
import '../constants/strings.dart';
import '../services/classifier_service.dart';
import '../models/classification_result.dart';
import '../widgets/result_card.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final ClassifierService _classifierService = ClassifierService();
  List<ClassificationResult>? _history;
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadHistory();
  }
  
  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final history = await _classifierService.getHistory();
      setState(() {
        _history = history;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors du chargement de l\'historique: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  Future<void> _clearHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Effacer l\'historique'),
        content: const Text('Êtes-vous sûr de vouloir effacer tout l\'historique ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Effacer'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        await _classifierService.clearHistory();
        await _loadHistory();
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'effacement de l\'historique: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.history),
        backgroundColor: AppColors.primaryPurple,
        foregroundColor: Colors.white,
        actions: [
          if (_history != null && _history!.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _clearHistory,
              tooltip: 'Effacer l\'historique',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _history == null || _history!.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.history,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppStrings.noHistory,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _history!.length,
                  itemBuilder: (context, index) {
                    // Afficher les résultats du plus récent au plus ancien
                    final result = _history![_history!.length - 1 - index];
                    
                    // Grouper par date
                    final formattedDate = DateFormat('dd MMMM yyyy').format(result.timestamp);
                    final isFirstOfDay = index == 0 || 
                        DateFormat('dd MMMM yyyy').format(_history![_history!.length - 1 - index].timestamp) != formattedDate;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isFirstOfDay) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              formattedDate,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Divider(),
                        ],
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: ResultCard(result: result),
                        ),
                      ],
                    );
                  },
                ),
      floatingActionButton: _history == null || _history!.isEmpty
          ? null
          : FloatingActionButton(
              onPressed: _loadHistory,
              backgroundColor: AppColors.primaryPurple,
              child: const Icon(Icons.refresh),
            ),
    );
  }
}