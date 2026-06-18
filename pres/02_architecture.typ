= Architecture et Implémentation

== Sélection du Schéma (BFV)
- *Schéma BFV (Brakerski-Fan-Vercauteren) :*
  - Arithmétique entière exacte.
  - Idéal pour prouver l'intégrité absolue des données avant corruption.
- *Impact des opérations :*
  - Addition : Croissance linéaire du bruit ($e_1 + e_2$). Coût en budget négligeable.
  - Multiplication : Croissance exponentielle ($e_1 dot e_2$). Coût massif.
- *Profondeur multiplicative :* Détermine le nombre maximal de multiplications séquentielles supportées.

== Ingénierie des Paramètres Cryptographiques
- Utilisation de la bibliothèque *Microsoft SEAL* (C++).
- *Degré du polynôme ($N = 8192$) :* Détermine le niveau de sécurité et le budget de bruit initial.
- *Plain Modulus (Espace des clairs) :* - Ajusté spécifiquement à 45 bits.
  - *Objectif :* Éviter le dépassement d'entier (*overflow* mathématique) lors des puissances, pour isoler strictement l'erreur liée au bruit cryptographique.
- *Relinéarisation :* Réduction de la taille du texte chiffré après chaque multiplication via des clés d'évaluation publiques.

== Architecture Logicielle
- *Modèle asymétrique séparé :*
  - *Client :* Possède les clés privées, chiffre les données, déchiffre les résultats.
  - *Serveur :* Possède uniquement les clés publiques/évaluation, exécute le circuit arithmétique.
- *Pile technologique :* - Moteur cryptographique C++ (Performances).
  - Orchestration Python/Flask (Simulation de l'infrastructure réseau).
