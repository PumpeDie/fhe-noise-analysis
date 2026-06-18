= Architecture et Implémentation

== Sélection du Schéma : BFV vs CKKS

#grid(
  columns: (1fr, 1fr),
  gutter: 1em,
  [
    - *BFV (Brakerski-Fan-Vercauteren) :*
      - Arithmétique entière *exacte*.
      - Le bruit cryptographique (LWE) est strictement isolé du message clair jusqu'à saturation.
  ],
  [
    - *CKKS (Cheon-Kim-Kim-Song) :*
      - Arithmétique à virgule flottante *approximative*.
      - Le bruit cryptographique se confond volontairement avec l'erreur de précision numérique.
  ]
)

- *Justification du choix (BFV) :* L'objectif de la preuve de concept est d'isoler et d'observer empiriquement l'*Effet Falaise* (épuisement du budget de bruit LWE). L'exactitude de BFV garantit une intégrité parfaite (erreur = $0$) tant que le budget est positif, permettant une observation binaire de la corruption, impossible avec l'approximation inhérente à CKKS.

== Algèbre de la Multiplication et Relinéarisation
- *Multiplication de deux chiffrés :* Produit de $(c_0^((1)), c_1^((1)))$ et $(c_0^((2)), c_1^((2)))$.
- Génère intrinsèquement un *triplet* polynomial :
  #align(center)[$ (c_0^((1)) c_0^((2)), quad c_0^((1)) c_1^((2)) + c_1^((1)) c_0^((2)), quad c_1^((1)) c_1^((2)) ) $]
- *Relinéarisation :* Étape critique utilisant des clés d'évaluation publiques pour projeter le terme quadratique ($c_2 dot s^2$) et ramener le texte chiffré à un format standard $(c_0', c_1')$. Opération source de la latence principale.

== Ingénierie des Paramètres Cryptographiques
- *Degré du polynôme ($N = 8192$) :* Détermine le niveau de sécurité et la capacité d'encodage (Batching/SIMD).
- *Plain Modulus ($t = 2^45$) :*
  - Choisi pour éviter les dépassements arithmétiques (*overflows*) lors de l'évaluation du filtre Gamma.
  - Préserve l'espace du message face à la croissance exponentielle des coefficients.

== Architecture Logicielle et Pile Technologique
- *Modèle asymétrique séparé :* Conception divisée entre orchestration (client simulé) et exécution arithmétique (serveur aveugle).

#align(center)[
  #grid(columns: (1fr, 0.2fr, 1fr), align: horizon, gutter: 1em,
    box(stroke: 1pt, inset: 10pt, radius: 4pt, fill: luma(250))[
      *Frontend & API (Python/Flask)* \
      - Serveur web interactif. \
      - Orchestration via `subprocess`. \
      - Rendu DOM et Métriques (JSON). \
      - Préparation image (`Pillow`).
    ],
    [$arrow.r.double$],
    box(stroke: 1pt + rgb("#6e8b15"), inset: 10pt, radius: 4pt, fill: rgb("#eaf2d6"))[
      *Moteur FHE (C++17)* \
      - Core FHE : `Microsoft SEAL`. \
      - Profilage CPU : `std::chrono`. \
      - I/O Images : `stb_image`. \
      - Build system : `CMake`.
    ]
  )
]

== Flux d'Exécution du Code C++
1. *Initialisation :* `KeyGenerator` instancie les clés de session (Secret, Public, RelinKeys).
2. *Encodage / Chiffrement :* `BatchEncoder` vectorise l'image ($6400$ pixels) dans les coefficients du polynôme, `Encryptor` génère le texte chiffré.
3. *Évaluation (Serveur) :* `Evaluator` applique `multiply_inplace` (correction Gamma) et `add_plain_inplace` (luminosité). La relinéarisation est forcée après chaque multiplication.
4. *Extraction des métriques :* Mesure empirique du bruit résiduel (`invariant_noise_budget`) et sérialisation des latences au format JSON.
