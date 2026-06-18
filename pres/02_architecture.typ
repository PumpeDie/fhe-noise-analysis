#import "@preview/touying:0.7.4": *

= Architecture et Implémentation

== Sélection du Schéma (BFV)
- *Schéma BFV (Brakerski-Fan-Vercauteren) :*
  - Arithmétique entière exacte (idéal pour intégrité).
  - Basé sur la difficulté du problème RLWE (*Ring Learning With Errors*).
- *Gestion de la croissance du bruit :*
  - Addition : Croissance linéaire ($e_1 + e_2$).
  - Multiplication : Croissance quasi-exponentielle (nécessite une procédure de relinéarisation).
- *Profondeur multiplicative :* Nombre de multiplications autorisées avant que le bruit $e$ ne corrompe les bits de poids fort du message.

#align(center)[
  #grid(columns: 2, gutter: 2em,
    align(center, box(stroke: 1pt, inset: 8pt, radius: 2pt)[
      #grid(columns: 2, align: horizon, gutter: 1em,
        [Addition], [Croissance #text(fill: blue)[Linéaire]]
      )
    ]),
    align(center, box(stroke: 1pt, inset: 8pt, radius: 2pt)[
      #grid(columns: 2, align: horizon, gutter: 1em,
        [Multiplication], [Croissance #text(fill: red)[Exponentielle]]
      )
    ])
  )
]

== Ingénierie des Paramètres Cryptographiques
- *Degré du polynôme ($N = 8192$) :* Définit l'espace des coefficients. Assure un niveau de sécurité NIST standard ($> 128$ bits).
- *Plain Modulus ($t = 2^45$) :*
  - Choisi pour éviter les dépassements (*overflows*) lors de calculs polynomiaux complexes.
  - Permet d'isoler l'erreur cryptographique de l'erreur de calcul arithmétique.
- *Relinéarisation :* Réduction de la taille du texte chiffré (qui double après une multiplication) via des *Evaluation Keys* publiques.

== Architecture Logicielle
- *Séparation des privilèges :*
  - *Client :* Déteneur de la clé secrète. Unique entité capable de déchiffrer.
  - *Serveur :* Exécute les opérateurs homomorphes via des clés publiques.

#align(center)[
  #grid(columns: 3, gutter: 1em, align: horizon,
    box(stroke: 1pt, inset: 10pt, radius: 2pt)[Client \ (Privé)],
    $arrow.r.double.long.bar$,
    box(stroke: 1pt, inset: 10pt, radius: 2pt)[Serveur \ (Public/Eval)]
  )
]

- *Optimisation :* Moteur C++ (Microsoft SEAL) pour la manipulation des grands entiers, encapsulé par une API Python/Flask.
