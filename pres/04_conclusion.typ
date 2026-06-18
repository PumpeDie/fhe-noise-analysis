= Conclusion et Perspectives

== Bilan
- Viabilité théorique des calculs sur données chiffrées démontrée.
- Garanties de sécurité post-quantiques validées par le schéma LWE.
- *Obstacles pratiques :* La gestion du budget de bruit et l'expansion mémoire limitent actuellement les applications en temps réel.

== Le Concept de Résolution : Bootstrapping
- *Définition :* Évaluation homomorphe du circuit de déchiffrement pour "nettoyer" le bruit sans révéler le clair.
- *État du calcul :*

#align(center)[
  #grid(columns: 3, gutter: 1em, align: center + horizon,
    box(fill: luma(230), inset: 8pt, radius: 2pt)[*FHE Niveau*],
    [],
    box(fill: luma(230), inset: 8pt, radius: 2pt)[*Capacité*],
    [Levelled-FHE], $arrow.r.long$, [Profondeur finie],
    [Bootstrapping], $arrow.r.long$, [Profondeur infinie]
  )
]

- *Exclusion du POC :* Coût computationnel prohibitif, masquant l'observation de la croissance du bruit (objectif initial).

== Perspectives Industrielles : Cas d'usage (Apple)
- Application du schéma BFV à la recherche visuelle sur appareil sans compromettre la confidentialité.

#align(center)[
  #image("figure2.png", height: 50%)
]

- *Validation de l'architecture asymétrique :*
  - *Client :* Extraction du vecteur d'embedding, quantification et chiffrement BFV.
  - *Serveur :* Évaluation homomorphe (produits scalaires) contre une base de données globale (POI).

== Perspectives Industrielles : Évolutions
- *Accélération matérielle (NTT) :*
  - La multiplication polynomiale est le goulot d'étranglement majeur. La NTT (*Number Theoretic Transform*) réduit sa complexité de $O(N^2)$ à $O(N log N)$.
  - Les processeurs (CPU) sont limités par la bande passante mémoire. Les architectures dédiées (FPGA/ASIC) permettent une parallélisation massive pour viabiliser le FHE en temps réel.
- *Schémas alternatifs :* Adoption du schéma CKKS (Arithmétique approximative) pour l'IA générative et le *Machine Learning* avancé, environnements nécessitant la manipulation de nombres à virgule flottante.
