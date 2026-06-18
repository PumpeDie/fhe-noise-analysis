= Démonstration et Analyse

== Encodage des données : Vectorisation et Batching (SIMD)
- *Contrainte :* L'opération polynomiale est coûteuse. Chiffrer un pixel par polynôme est inefficace.
- *Solution (Batching) :* Exploitation du théorème des restes chinois pour encoder plusieurs valeurs dans les coefficients d'un unique polynôme.
- *Application au POC :* Une image $80 times 80$ ($6400$ pixels) tient dans un seul polynôme de degré $N = 8192$.

#align(center)[
  #box(stroke: 1pt + luma(200), inset: 15pt, radius: 4pt)[
    #grid(columns: 5, align: center + horizon, gutter: 1.5em,
      // Matrice 2D
      grid(columns: 2, rows: 2, gutter: 2pt,
        rect(width: 1.5em, height: 1.5em, fill: luma(200)), rect(width: 1.5em, height: 1.5em, fill: luma(150)),
        rect(width: 1.5em, height: 1.5em, fill: luma(100)), rect(width: 1.5em, height: 1.5em, fill: luma(50))
      ),
      text(size: 0.8em)[$arrow.r$ \ Aplatissement],
      // Vecteur 1D
      grid(columns: 4, gutter: 2pt,
        rect(width: 1.2em, height: 1.5em, fill: luma(200)), rect(width: 1.2em, height: 1.5em, fill: luma(150)),
        rect(width: 1.2em, height: 1.5em, fill: luma(100)), rect(width: 1.2em, height: 1.5em, fill: luma(50))
      ),
      text(size: 0.8em)[$arrow.r$ \ Encodage (SEAL)],
      // Polynôme
      rect(width: 8em, height: 3em, fill: rgb("#eaf2d6"), radius: 4pt, stroke: 1pt + rgb("#6e8b15"))[
        Polynôme $m(x)$ \
        #text(size: 0.6em)[(8192 slots indépendants)]
      ]
    )
  ]
]

== Analyse : Dégradation du Budget de Bruit
- Observation empirique de l'Effet Falaise lors de multiplications successives.
- Paramètres : $N = 8192$, Modulus = 45 bits. Budget initial $approx 135$ bits.

#align(center)[
  #grid(columns: 5, align: bottom, gutter: 1em,
    stack(spacing: 5pt, text(size: 0.7em)[135 bits], rect(width: 3em, height: 100pt, fill: rgb("#6e8b15")), text(size: 0.8em)[Frais]),
    stack(spacing: 5pt, text(size: 0.7em)[102 bits], rect(width: 3em, height: 75pt, fill: rgb("#6e8b15").lighten(20%)), text(size: 0.8em)[Mult 1]),
    stack(spacing: 5pt, text(size: 0.7em)[60 bits], rect(width: 3em, height: 45pt, fill: rgb("#6e8b15").lighten(40%)), text(size: 0.8em)[Mult 2]),
    stack(spacing: 5pt, text(size: 0.7em)[15 bits], rect(width: 3em, height: 12pt, fill: orange), text(size: 0.8em)[Mult 3]),
    stack(spacing: 5pt, text(size: 0.7em, fill: red)[0 bit], rect(width: 3em, height: 2pt, fill: red), text(weight: "bold", size: 0.8em, fill: red)[Corruption])
  )
]

== Analyse : Profilage de la Latence (Métriques)
- Évaluation des performances sur l'opération unique via `std::chrono` (C++).
- L'asymétrie computationnelle justifie la nécessité d'optimisation matérielle.

#align(center)[
  #grid(columns: 2, gutter: 4em, align: bottom,
    stack(spacing: 8pt,
      text(size: 0.9em, weight: "bold")[Opérations Linéaires],
      rect(width: 4em, height: 1pt, fill: blue),
      text(size: 0.8em)[Addition \ $approx 130$ µs]
    ),
    stack(spacing: 8pt,
      text(size: 0.9em, weight: "bold")[Opérations Quadratiques],
      rect(width: 4em, height: 100pt, fill: red),
      text(size: 0.8em)[Multiplication + Relinéarisation \ $approx 20$ ms]
    )
  )
]

- *Conclusion du POC :* La latence de traitement est acceptable pour des circuits fixes (Levelled-FHE), mais l'expansion mémoire ($times 10^4$) limite l'usage réseau.
