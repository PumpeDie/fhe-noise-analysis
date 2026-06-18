= Introduction et Problématique

== Contexte Technologique et Cryptographique
- *Informatique en nuage (Cloud) :* Externalisation massive des calculs.
- *Vulnérabilité classique :* Nécessité de déchiffrer en mémoire côté serveur pour manipuler les données (ex: santé, finance).
- *Menace quantique :* Vulnérabilité des standards asymétriques actuels (RSA, ECC) face à l'algorithme de Shor.
- *Transition PQC :* Adoption de la cryptographie post-quantique, notamment basée sur les réseaux euclidiens.

== Chiffrement Homomorphe (FHE)
- *Définition :* Capacité d'évaluer une fonction arbitraire directement sur des textes chiffrés.
- *Propriété fondamentale :* $"Dec"("Enc"(x) dot "Enc"(y)) = x dot y$
- Permet l'externalisation sécurisée : le serveur traite les données à l'aveugle, sans jamais posséder la clé privée.

== Base Théorique : Apprentissage avec Erreurs (LWE)
- Socle mathématique de nombreux schémas post-quantiques.
- *Équation :* $b = A s + e (mod q)$
  - $s$ : Vecteur secret
  - $A$ : Matrice publique aléatoire
  - $e$ : Erreur probabiliste (*le bruit*)
- *Rôle de l'erreur :* Sans l'injection du bruit $e$, le système est trivialement résoluble par algèbre linéaire (pivot de Gauss).

== La Problématique du Bruit
- *Le paradoxe :* Le bruit est indispensable pour la sécurité (masque la structure algébrique), mais destructeur pour le calcul.
- *Croissance lors des opérations :* Chaque opération homomorphe augmente l'amplitude du bruit.
- *Condition d'échec :* Si le bruit déborde sur les bits de poids fort du texte chiffré, le déchiffrement échoue irréversiblement.
