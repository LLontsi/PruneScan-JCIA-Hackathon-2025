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


### Modèle

Le cœur du projet repose sur un modèle de classification d'images basé sur l'architecture **MobileNetV2**, pré-entraînée sur ImageNet. Le modèle a été modifié et entraîné pour classer des images de prunes africaines selon leur qualité ou leurs défauts.

## 🔧 Architecture
* **Base** : `MobileNetV2` (poids pré-entraînés sur ImageNet, sans la couche de classification finale)
* **Couches personnalisées** :
   * `GlobalAveragePooling2D`
   * `Dense(256)` + `BatchNormalization` + `Dropout(0.6)`
   * `Dense(128)` + `BatchNormalization` + `Dropout(0.4)`
   * `Dense(nb_classes, activation='softmax')` (couche de sortie)

L'ensemble du modèle est régularisé avec `L1/L2` pour éviter l'overfitting.

## ⚙️ Prétraitement et Augmentation
Les données sont chargées avec `ImageDataGenerator`, incluant :
* Normalisation (`rescale=1./255`)
* Augmentations : rotation, translation, zoom, flips horizontaux
* Validation split automatique (20%)

## 📉 Fonction de perte
Utilisation de la **Focal Loss** (avec `gamma=2.0`) pour mieux gérer le déséquilibre des classes, en concentrant l'apprentissage sur les classes minoritaires.

## ⚖️ Gestion du déséquilibre des classes
Des **poids de classes** sont calculés dynamiquement pour renforcer l'importance des classes sous-représentées (`bruised`, `cracked`, etc.), en utilisant une pondération ajustée à l'aide d'une exponentiation (`^1.5`) sur les classes les plus rares.

## 🧠 Stratégie d'entraînement
L'entraînement est réalisé en trois phases :

1. **Entraînement initial**
   * Couches personnalisées uniquement (MobileNetV2 gelé)
   * `75 epochs`
   * Optimiseur : `Adam`, avec LR réduit
   * Callbacks : `EarlyStopping`, `ReduceLROnPlateau`, `ModelCheckpoint`

2. **Fine-tuning partiel**
   * Dégel des **30 dernières couches** de MobileNetV2
   * Recompilation du modèle
   * `35 epochs`

3. **Fine-tuning complet**
   * Dégel complet de MobileNetV2
   * Recompilation finale
   * `25 epochs`

Chaque phase conserve les meilleurs poids grâce à `ModelCheckpoint`.

## 📊 Évaluation et métriques
Pendant l'entraînement, les métriques suivantes sont surveillées :
* `Accuracy`
* `AUC`
* `Precision`
* `Recall`

Un graphique est généré pour visualiser les **poids de classe** appliqués, illustrant leur importance dans le traitement du déséquilibre.

## 💾 Modèle final
Le meilleur modèle est sauvegardé automatiquement sous le nom : `best_plum_model.h5`



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
-Nous avons choisi MobileNetV2 comme modèle de base pour le transfert learning car il a déjà été entraîné sur un dataset de classification de fruits contenant 14 classes, dont celle des prunes. Selon l’article "Fruit Image Classification Model Based on MobileNetV2 with Deep Transfer Learning Technique" (publié le 19 janvier 2023), MobileNetV2 a surpassé des modèles populaires tels que ResNet, InceptionV3, AlexNet et VGG16 en termes de taux de précision, justifiant ainsi son efficacité pour ce type de tâche.
- Performances élevées dans les tâches de classification d'images
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
