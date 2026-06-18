= Démonstration et Analyse

== La Preuve de Concept (POC)
- *Scénario :* Traitement d'image délégué (80x80 pixels).
- *Opération 1 : Addition (Luminosité)*
  - Ajout d'une constante en clair.
  - Consommation de bruit quasi nulle.
- *Opération 2 : Multiplication (Correction Gamma)*
  - Évaluation polynomiale : $y = x^gamma$.
  - Multiplications successives (*Chiffré-Chiffré*).
  - Consommation massive du budget de bruit.

== Analyse des Observations Empiriques
- *L'Effet Falaise (Cliff Effect) :*
  - Intégrité parfaite tant que le budget $> 0$.
  - Corruption instantanée (bruit blanc) dès l'épuisement.

#align(center)[
  #grid(columns: 2, gutter: 2em,
    stack(spacing: 8pt,
      [Budget de Bruit],
      rect(fill: luma(240), stroke: 1pt, height: 2em, width: 8em,
        grid(columns: (1fr, 0.2fr), rect(fill: blue, height: 100%)[], [])
      )
    ),
    stack(spacing: 8pt,
      [Erreur de Déchiffrement],
      rect(fill: luma(240), stroke: 1pt, height: 2em, width: 8em,
        align(center + horizon)[$0$]
      )
    )
  )
]

== Discussion des Métriques
- *Expansion des données :* Un pixel (1 octet) devient un polynôme de plusieurs mégaoctets. Goulot d'étranglement majeur.
- *Asymétrie de latence :*

#align(center)[
  #grid(columns: 2, gutter: 3em,
    box(stroke: 1pt, inset: 10pt, radius: 2pt)[
      *Addition* \
      $approx 10$ #text(size: 0.8em)[$\mu s$]
    ],
    box(stroke: 1pt + red, inset: 10pt, radius: 2pt)[
      *Multiplication + Rélîn.* \
      $approx 50-100$ #text(size: 0.8em)[ms]
    ]
  )
]

- *Validation :* Démontre empiriquement les limites de performance du *Levelled-FHE*.
