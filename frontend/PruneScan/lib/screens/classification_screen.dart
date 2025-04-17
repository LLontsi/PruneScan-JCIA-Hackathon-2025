// screens/classification_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../constants/colors.dart';
import '../constants/strings.dart';
import '../services/classifier_service.dart';
import '../models/classification_result.dart';
import '../widgets/custom_button.dart';
import '../widgets/result_card.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class ClassificationScreen extends StatefulWidget {
  const ClassificationScreen({Key? key}) : super(key: key);

  @override
  _ClassificationScreenState createState() => _ClassificationScreenState();
}

class _ClassificationScreenState extends State<ClassificationScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _image;
  bool _isProcessing = false;
  ClassificationResult? _result;
  final ClassifierService _classifierService = ClassifierService();
  
  Future<void> _getImage(ImageSource source) async {
    // Vérifier et demander les permissions nécessaires
    bool permissionGranted = false;
    
    if (source == ImageSource.camera) {
      // Permission pour la caméra
      var status = await Permission.camera.status;
      if (status.isDenied) {
        status = await Permission.camera.request();
      }
      permissionGranted = status.isGranted;
      
      if (status.isPermanentlyDenied) {
        _showPermissionDialog("caméra");
        return;
      }
    } else {
      // Permission pour la galerie
      var status = await Permission.storage.status;
      if (status.isDenied) {
        status = await Permission.storage.request();
      }
      
      // Pour Android 13+, vérifier également READ_MEDIA_IMAGES
      if (Platform.isAndroid) {
        var mediaStatus = await Permission.photos.status;
        if (mediaStatus.isDenied) {
          mediaStatus = await Permission.photos.request();
        }
        permissionGranted = status.isGranted || mediaStatus.isGranted;
        
        if (status.isPermanentlyDenied && mediaStatus.isPermanentlyDenied) {
          _showPermissionDialog("galerie");
          return;
        }
      } else {
        permissionGranted = status.isGranted;
        
        if (status.isPermanentlyDenied) {
          _showPermissionDialog("galerie");
          return;
        }
      }
    }
    
    // Si la permission est accordée, procéder à la sélection d'image
    if (permissionGranted) {
      try {
        final XFile? pickedFile = await _picker.pickImage(
          source: source,
          maxWidth: 224,
          maxHeight: 224,
        );
        
        if (pickedFile != null) {
          setState(() {
            _image = File(pickedFile.path);
            _result = null;
            _isProcessing = true;
          });
          
          // Classifier l'image
          try {
            final result = await _classifierService.classifyImage(_image!);
            setState(() {
              _result = result;
              _isProcessing = false;
            });
          } catch (e) {
            setState(() {
              _isProcessing = false;
            });
            _showErrorSnackBar('Erreur lors de la classification: $e');
          }
        }
      } catch (e) {
        _showErrorSnackBar('Erreur lors de la sélection de l\'image: $e');
      }
    } else {
      _showErrorSnackBar(
        source == ImageSource.camera
            ? 'Permission d\'accès à la caméra refusée'
            : 'Permission d\'accès à la galerie refusée'
      );
    }
  }
  
  void _showPermissionDialog(String permissionType) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Permission requise'),
        content: Text(
          'Cette application a besoin d\'accéder à votre $permissionType pour fonctionner. '
          'Veuillez autoriser l\'accès dans les paramètres de l\'application.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: const Text('Ouvrir les paramètres'),
          ),
        ],
      ),
    );
  }
  
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.classification),
        backgroundColor: AppColors.primaryPurple,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Zone d'image
                Container(
                  width: double.infinity,
                  height: 300,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.grey[300]!,
                      width: 2,
                    ),
                  ),
                  child: _image == null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image,
                                size: 80,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                AppStrings.classifyPrompt,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.file(
                            _image!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                ),
                
                const SizedBox(height: 24),
                
                // Boutons pour prendre/choisir une image
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'Appareil photo',
                        onPressed: () => _getImage(ImageSource.camera),
                        backgroundColor: AppColors.primaryPurple,
                        icon: Icons.camera_alt,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomButton(
                        text: 'Galerie',
                        onPressed: () => _getImage(ImageSource.gallery),
                        backgroundColor: AppColors.darkPurple,
                        icon: Icons.photo_library,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Affichage du résultat ou indicateur de chargement
                if (_isProcessing)
                  Column(
                    children: [
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryPurple),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppStrings.processing,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  )
                else if (_result != null)
                  ResultCard(result: _result!),
              ],
            ),
          ),
        ),
      ),
    );
  }
}