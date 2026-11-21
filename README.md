# MathArthur - Le Royaume des Mathématiques

Jeu éducatif 3D pour les élèves de CM2 (Cours Moyen 2), développé avec **Godot 4** et des assets créés avec **Blender**.

## Objectif pédagogique

MathArthur intègre le **programme complet de mathématiques de CM2** (France) :
- Nombres et calculs (grands nombres, multiples/diviseurs, fractions, opérations)
- Géométrie (droites, angles, polygones, symétrie, périmètres, aires)
- Grandeurs et mesures (conversions, durées, aires, volumes)
- Organisation et gestion de données (tableaux, moyenne, médiane, probabilités)

L'accent est mis sur **l'apprentissage**, pas sur le jeu : c'est la réussite scolaire qui débloque le jeu.

## Fonctionnalités

- **Adaptive learning** respectant la Zone Proximale de Développement (ZPD) de Vygotsky : questions ni trop faciles ni trop difficiles, avec scaffolding (indices progressifs).
- **Porte-monnaie** : les bonnes réponses rapportent des pièces qui permettent de personnaliser le personnage.
- **Explication orale** via la synthèse vocale (Web Speech / DisplayServer TTS).
- **Explication vidéo** : liens vers des vidéos éducatives.
- **Mots d'encouragement** réguliers et feedback positif.
- **Addictivité saine** : streaks, combos, badges, niveaux, XP, confettis, défis quotidiens.
- **Mise en situation de réussite** : feedback immédiat, indices, possibilité de passer.
- **Mode multijoueur** débloqué uniquement avec 500 🪙 dans le porte-monnaie.
- **Interface 3D** agréable (Godot Forward+), rendu soigné.

## Structure du projet

```
matharthur/
├── project.godot
├── scenes/          # Scènes Godot (MainMenu, Game, Customize, Multiplayer)
├── scripts/         # GDScript (autoloads, UI, data)
├── assets/          # Textures, audio, modèles 3D (GLB)
├── blender/         # Scripts Python pour générer les modèles
├── data/            # Données (optionnel)
└── export/          # Builds exportés (web, desktop)
```

## Lancer le projet

1. Installer [Godot 4.3+](https://godotengine.org/download).
2. Ouvrir `project.godot` dans Godot.
3. Appuyer sur F5 pour lancer.

## Générer les modèles 3D (Blender)

```bash
blender --background --python blender/blender_generate.py
```
Les fichiers `.glb` sont exportés dans `assets/models/`.

## Multi-plateforme (téléphone, tablette, PC)

MathArthur est conçu pour être jouable sur **téléphone, tablette et PC** :
- **Web (PWA)** : export HTML5, installable sur mobile et desktop, interface responsive (containers adaptatifs, scroll, HFlow).
- **Windows / macOS / Linux** : export desktop natif.
- **Android** : export APK (preset fourni dans `export_presets.cfg`).
- **iOS** : export possible depuis un Mac avec Xcode.

Les scènes utilisent des `MarginContainer`, `ScrollContainer`, `HFlowContainer` et `GridContainer` pour s'adapter à toutes les tailles d'écran.

## Export web (GitHub Pages)

Dans Godot : Projet > Exporter > Web (HTML5). Le workflow GitHub Actions (`.github/workflows/build.yml`) automatise l'export et le déploiement sur GitHub Pages : https://monsieurhage.github.io/matharthur/

## Dépôt

Ce projet est destiné à être déposé sur GitHub, puis éventuellement hébergé sur un site indépendant.

## Licence

Projet éducatif - usage libre pour l'apprentissage.
