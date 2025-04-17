// screens/home_screen.dart
import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/strings.dart';
import '../widgets/custom_button.dart';
import 'classification_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  
  final List<Widget> _screens = [
    const HomeContent(),
    const ClassificationScreen(),
    const HistoryScreen(),
    const ProfileScreen(),
  ];
  
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: AppColors.primaryPurple,
        unselectedItemColor: AppColors.textSecondary,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: AppStrings.homePage,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: AppStrings.classification,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: AppStrings.history,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: AppStrings.profile,
          ),
        ],
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bonjour!',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      Text(
                        'Bienvenue sur PruneScan',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  CircleAvatar(
                    backgroundColor: AppColors.primaryPurple,
                    radius: 24,
                    child: Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Carte principale
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryPurple,
                        AppColors.darkPurple,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Classifier une prune',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Prenez une photo ou sélectionnez une image pour classifier votre prune',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: 24),
                      CustomButton(
                        text: 'Commencer',
                        onPressed: () {
                          // Naviguer vers l'écran de classification
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ClassificationScreen(),
                            ),
                          );
                        },
                        backgroundColor: Colors.white,
                        textColor: AppColors.primaryPurple,
                        icon: Icons.camera_alt,
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Catégories de prunes
              Text(
                'Catégories de prunes',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Grille des catégories
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _buildCategoryCard(
                    context,
                    title: AppStrings.unaffected,
                    color: AppColors.goodQuality,
                    icon: Icons.check_circle,
                  ),
                  _buildCategoryCard(
                    context,
                    title: AppStrings.unripe,
                    color: AppColors.unripe,
                    icon: Icons.access_time,
                  ),
                  _buildCategoryCard(
                    context,
                    title: AppStrings.spotted,
                    color: AppColors.spotted,
                    icon: Icons.blur_on,
                  ),
                  _buildCategoryCard(
                    context,
                    title: AppStrings.cracked,
                    color: AppColors.cracked,
                    icon: Icons.broken_image,
                  ),
                  _buildCategoryCard(
                    context,
                    title: AppStrings.bruised,
                    color: AppColors.bruised,
                    icon: Icons.bubble_chart,
                  ),
                  _buildCategoryCard(
                    context,
                    title: AppStrings.rotten,
                    color: AppColors.rotten,
                    icon: Icons.warning,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildCategoryCard(
    BuildContext context, {
    required String title,
    required Color color,
    required IconData icon,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Afficher des informations sur cette catégorie
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Catégorie: $title'),
              duration: const Duration(seconds: 1),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: color,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}