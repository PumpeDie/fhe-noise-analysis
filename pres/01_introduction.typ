= Introduction et Problématique

== Contexte Technologique et Cryptographique
- *Le chaînon manquant de la confidentialité :* Les données sont protégées au repos (AES) et en transit (TLS), mais exposées en clair *en cours d'utilisation*.
- *Modèle de menace cloud :* Serveur *Honest-but-curious* (honnête mais curieux). Nécessité d'opérer sur les données à l'aveugle.
- *Menace quantique (Algorithme de Shor) :* Vulnérabilité des systèmes asymétriques classiques basés sur la factorisation et le logarithme discret (RSA, ECC).
- *Cryptographie Post-Quantique (PQC) :* Standardisation d'algorithmes basés sur les problèmes de réseaux euclidiens (Lattice-based cryptography), intrinsèquement résistants aux attaques quantiques.

== Chiffrement Homomorphe Complet (FHE)
#grid(
  columns: (1fr, 1.2fr),
  gutter: 1em,
  [
    - *Définition :* Homomorphisme d'anneaux entre l'espace des messages clairs et des textes chiffrés.
    - *Propriétés :*
      - Addition : $"Dec"("Enc"(x) ⊕ "Enc"(y)) = x + y$
      - Multiplication : $"Dec"("Enc"(x) ⊗ "Enc"(y)) = x dot y$
    - *Évolution :* PHE (Partiel) $->$ SWHE (Limité) $->$ FHE (Profondeur infinie).
  ],
  [
    #align(center)[
      #box(stroke: 1pt + luma(200), inset: 10pt, radius: 4pt)[
        #grid(
          columns: (4.5em, 3.5em, 4.5em),
          align: center + horizon,
          row-gutter: 8pt,
          text(weight: "bold")[Client], [], text(weight: "bold")[Serveur],
          v(2pt), [], v(2pt),
          rect(fill: rgb("#eaf2d6"), radius: 3pt, width: 100%)[$x$], [], [],
          [$arrow.b$ #text(size: 0.7em)[Chiffrer]], [], [],
          rect(fill: luma(230), radius: 3pt, width: 100%)[$"Enc"(x)$], 
          [$arrow.r^"Réseau"$], 
          rect(fill: luma(230), radius: 3pt, width: 100%)[$"Enc"(x)$],
          [], [], [$arrow.b$ #text(size: 0.7em)[Éval($f$)]],
          rect(fill: luma(230), radius: 3pt, width: 100%)[$"Enc"(f(x))$], 
          [$arrow.l^"Réseau"$], 
          rect(fill: luma(230), radius: 3pt, width: 100%)[$"Enc"(f(x))$],
          [$arrow.b$ #text(size: 0.7em)[Déchiffrer]], [], [],
          rect(fill: rgb("#eaf2d6"), radius: 3pt, width: 100%)[$f(x)$], [], []
        )
      ]
    ]
  ]
)

== Base Théorique : Apprentissage avec Erreurs (LWE)
- Problème introduit par Regev (2005), sécurisé par réduction aux réseaux (SVP, CVP).
- *Formulation algébrique :* $bold(b) = bold(A) bold(s) + bold(e) quad (mod q)$

#align(center)[
  #grid(
    columns: 7,
    align: center + horizon,
    row-gutter: 8pt,
    column-gutter: 10pt,
    
    // Ligne 1 : Les matrices
    rect(width: 1.5em, height: 4em, fill: rgb("#6e8b15").lighten(50%), radius: 2pt)[$bold(b)$],
    [$=$],
    rect(width: 4em, height: 4em, fill: luma(230), radius: 2pt)[$bold(A)$],
    [$times$],
    rect(width: 1.5em, height: 3em, fill: luma(200), radius: 2pt)[$bold(s)$],
    [$+$],
    rect(width: 1.5em, height: 4em, fill: red.lighten(50%), radius: 2pt)[$bold(e)$],
    
    // Ligne 2 : Les dimensions strictement alignées
    text(size: 0.7em, fill: luma(100))[$m times 1$], [],
    text(size: 0.7em, fill: luma(100))[$m times n$], [],
    text(size: 0.7em, fill: luma(100))[$n times 1$], [],
    text(size: 0.7em, fill: luma(100))[$m times 1$]
  )
]

- *Nécessité cryptographique :* Sans l'injection du bruit probabiliste $bold(e)$, le système de $m$ équations à $n$ inconnues est trivialement résoluble par pivot de Gauss.

== La Problématique du Bruit (Noise Budget)
- *Le paradoxe LWE :* Le bruit garantit la sécurité sémantique (IND-CPA), mais dégrade l'intégrité de la structure algébrique lors des calculs.
- *Condition d'échec (Cliff Effect) :* Échec de déchiffrement si le bruit (situé dans les bits de poids faible) déborde sur le message (bits de poids fort).

#align(center)[
  #grid(
    columns: 3,
    gutter: 2em,
    align(center, stack(spacing: 8pt,
      text(weight: "bold", size: 0.9em)[Texte chiffré frais],
      rect(width: 8em, height: 1.5em, stroke: 1pt, radius: 2pt, inset: 0pt)[
        #grid(columns: (2.5em, 1fr, 1.2em), rows: (100%),
          rect(width:100%, height:100%, fill: rgb("#eaf2d6"), stroke:none)[Msg],
          [],
          rect(width:100%, height:100%, fill: red.lighten(50%), stroke:none)[$e$]
        )
      ]
    )),
    align(center, stack(spacing: 8pt,
      text(weight: "bold", size: 0.9em)[Après opérations],
      rect(width: 8em, height: 1.5em, stroke: 1pt, radius: 2pt, inset: 0pt)[
        #grid(columns: (2.5em, 1fr, 4em), rows: (100%),
          rect(width:100%, height:100%, fill: rgb("#eaf2d6"), stroke:none)[Msg],
          [],
          rect(width:100%, height:100%, fill: red.lighten(50%), stroke:none)[$e'$]
        )
      ]
    )),
    align(center, stack(spacing: 8pt,
      text(weight: "bold", size: 0.9em, fill: red)[Effet Falaise],
      rect(width: 8em, height: 1.5em, stroke: 2pt+red, radius: 2pt, inset: 0pt)[
        #grid(columns: (100%), rows: (100%),
          rect(width:100%, height:100%, fill: red.lighten(30%), stroke:none)[*Corruption*]
        )
      ]
    ))
  )
]
