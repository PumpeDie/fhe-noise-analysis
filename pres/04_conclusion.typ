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

== Perspectives Industrielles
- *Accélération matérielle :* Développement de FPGA ou ASIC spécialisés pour optimiser les opérations NTT (*Number Theoretic Transform*).
- *Schémas alternatifs :* Adoption du schéma CKKS (Arithmétique approximative) pour l'IA et le *Machine Learning*, environnements naturellement tolérants au bruit.
