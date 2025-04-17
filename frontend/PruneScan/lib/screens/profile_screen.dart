// screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/colors.dart';
import '../constants/strings.dart';
import '../services/classifier_service.dart';
import '../providers/theme_provider.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ClassifierService _classifierService = ClassifierService();
  int _classificationsCount = 0;
  bool _isDarkMode = false;
  bool _isLoading = true;
  
  @override
  @override
void initState() {
  super.initState();
  // Initialiser _isDarkMode avec la valeur du provider
  _isDarkMode = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
  _loadData();
}
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Charger le nombre de classifications
      final history = await _classifierService.getHistory();
      
      // Charger les préférences
      final prefs = await SharedPreferences.getInstance();
      final isDarkMode = prefs.getBool('dark_mode') ?? false;
      
      setState(() {
        _classificationsCount = history.length;
        _isDarkMode = isDarkMode;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors du chargement des données: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
 Future<void> _toggleDarkMode(bool value) async {
  // Utiliser le provider pour changer le thème
  final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
  await themeProvider.setDarkMode(value);
  
  setState(() {
    _isDarkMode = value;
  });
  
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(value ? 'Mode sombre activé' : 'Mode clair activé'),
      duration: const Duration(seconds: 1),
    ),
  );
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.profile),
        backgroundColor: AppColors.primaryPurple,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar et nom d'utilisateur
                    Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: AppColors.primaryPurple,
                            child: const Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Utilisateur',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Aucune inscription requise',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Statistiques
                    Text(
                      'Statistiques',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            _buildStatItem(
                              context,
                              icon: Icons.camera_alt,
                              title: 'Classifications',
                              value: _classificationsCount.toString(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Préférences
                    Text(
                      'Préférences',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                _buildSwitchItem(
                                  context,
                                  icon: _isDarkMode ? Icons.dark_mode : Icons.light_mode,
                                  title: 'Apparence',  // Changé de "Mode sombre" à "Apparence"
                                  value: _isDarkMode,
                                  onChanged: _toggleDarkMode,
                                ),
                              ],
                            ),
                          ),
                        ),
                                            
                    const SizedBox(height: 32),
                    
                    // À propos
                    Text(
                      'À propos',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            _buildInfoItem(
                              context,
                              icon: Icons.info,
                              title: 'Version',
                              subtitle: '1.0.0',
                            ),
                            const Divider(),
                            _buildInfoItem(
                              context,
                              icon: Icons.code,
                              title: 'Développé pour',
                              subtitle: 'JCIA Hackathon 2025',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
  
  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primaryPurple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppColors.primaryPurple,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const Spacer(),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
  
  Widget _buildSwitchItem(
  BuildContext context, {
  required IconData icon,
  required String title,
  required bool value,
  required ValueChanged<bool> onChanged,
}) {
  return Row(
    children: [
      Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primaryPurple.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: AppColors.primaryPurple,
          size: 24,
        ),
      ),
      const SizedBox(width: 16),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Text(
            value ? 'Mode sombre activé' : 'Mode clair activé',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
      const Spacer(),
      Row(
        children: [
          Icon(
            Icons.light_mode,
            size: 16,
            color: !value ? AppColors.primaryPurple : AppColors.textSecondary,
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primaryPurple,
          ),
          Icon(
            Icons.dark_mode,
            size: 16,
            color: value ? AppColors.primaryPurple : AppColors.textSecondary,
          ),
        ],
      ),
    ],
  );
}
  
  Widget _buildInfoItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primaryPurple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppColors.primaryPurple,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}