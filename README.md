# PruneScan - JCIA Hackathon 2025
# Tri Automatique des Prunes

Ce projet présente un système de classification d'images de prunes basé sur le deep learning pour trier automatiquement les prunes africaines selon leur qualité.

## Équipe
- LONTSI LAMBOU Ronaldino - lontsilambou@gmail.com
- FETUE FOKO Nathanael - nathanaelfetue1237@gmail.com
- TCHIAZE FOUOSSO Romero - romerotchiazefouosso@gmail.com

## Structure du Repository
```
repository/
├── backend/
│   ├── african_plums_dataset/
│   ├── prune.ipynb
│   └── best_plum_model.h5
└── frontend/
    └── [application Flutter]
```

## Guide d'exécution rapide

### Backend

Le backend est implémenté sous forme de notebook Jupyter qui génère un modèle entraîné (`best_plum_model.h5`).

1. **Installer les dépendances**:
```bash
pip install tensorflow opencv-python pandas numpy matplotlib seaborn scikit-learn tqdm jupyter
```

2. **Télécharger le dataset**:
   - Téléchargez le dataset depuis Kaggle: [African Plums Quality Dataset](https://www.kaggle.com/datasets/arnaudfadja/african-plums-quality-and-defect-assessment-data)
   - Placez-le dans le dossier `backend/`

3. **Exécuter le notebook**:
```bash
cd backend
jupyter notebook
# Ouvrez et exécutez notebook.ipynb
```

### Frontend
1. **Installation de Flutter**:
Assurez-vous que Flutter est installé sur votre système. Si ce n'est pas le cas, suivez les instructions sur flutter.dev.
2. **Installation des dépendances**

```bash 
cd PruneScan
flutter pub get
```
3. **Exécuter l'application Flutter**:
```bash
flutter run
```

## Résultats obtenus

Notre modèle a atteint d'excellentes performances sur l'ensemble de test:

### Métriques globales:
- **Accuracy**: 0.8419
- **AUC**: 0.9712
- **Precision**: 0.8641
- **Recall**: 0.8168

### Précision par classe:
- **bruised**: 0.7222
- **cracked**: 0.6486
- **rotten**: 0.9792
- **spotted**: 0.6531
- **unaffected**: 0.9267
- **unripe**: 0.9189

### Échantillons correctement classifiés:
- **bruised**: 39 sur 48 échantillons
- **cracked**: 24 sur 24 échantillons
- **rotten**: 94 sur 108 échantillons
- **spotted**: 96 sur 114 échantillons
- **unaffected**: 215 sur 259 échantillons
- **unripe**: 102 sur 124 échantillons

## Détails du projet

### Compréhension du problème

Notre projet répond au défi du tri automatique des prunes africaines. Les challenges spécifiques incluent:
- La détection précise de 6 catégories différentes de prunes (saines, non mûres, tachetées, pourries, meurtries, fissurées)
- Le déséquilibre important entre les classes (certains défauts étant rares dans le dataset)
- La nécessité d'un modèle suffisamment léger pour être déployé dans un environnement de production

### Modèle choisi

Nous avons opté pour une architecture basée sur **MobileNetV2** pour les raisons suivantes:
- Performances élevées dans les tâches de classification d'images
- Possibilité de transfert d'apprentissage à partir de poids pré-entraînés sur ImageNet
- Efficacité computationnelle (adapté pour le déploiement sur des appareils à ressources limitées)
- 
Notre architecture du modele comprend:
- MobileNetV2 comme modèle de base
- Couches supplémentaires personnalisées avec régularisation L1-L2
- Normalisation par lots et dropout pour réduire le surapprentissage
- Fonction de perte Focal Loss pour gérer le déséquilibre des classes

### Méthodologie

#### Prétraitement des données
- Redimensionnement des images à 324×324 pixels
- Normalisation des valeurs de pixel (0-1)
- Augmentation de données agressive pour les classes minoritaires (rotation, translation, cisaillement, zoom, retournement, variation de luminosité)

#### Division des données
- 70% pour l'entraînement
- 15% pour la validation
- 15% pour le test
- Division stratifiée pour maintenir la distribution des classes

#### Gestion du déséquilibre
- Surreprésentation des classes minoritaires dans l'ensemble d'entraînement
- Pondération des classes avec une puissance de 1.5 pour les classes 'bruised' et 'cracked'
- Focal Loss avec gamma=2.0 pour se concentrer sur les exemples difficiles

#### Stratégie d'entraînement faite
- Entraînement en trois phases:
  1. Entraînement initial des couches supérieures (75 époques)
  2. Premier fine-tuning avec les 30 dernières couches de MobileNetV2 dégelées (35 époques)
  3. Deuxième fine-tuning avec toutes les couches dégelées (25 époques)
- Utilisation de callbacks pour:
  - Sauvegarde du meilleur modèle (ModelCheckpoint)
  - Arrêt précoce pour éviter le surapprentissage (EarlyStopping)
  - Réduction du taux d'apprentissage en plateau (ReduceLROnPlateau)

## Contact

Pour toute question concernant ce projet, veuillez contacter les membres de l'équipe aux adresses email fournies ci-dessus.
