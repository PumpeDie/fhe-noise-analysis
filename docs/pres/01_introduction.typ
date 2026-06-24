= Introduction et Problématique

== Contexte Technologique et Cryptographique
- *Le chaînon manquant de la confidentialité :* Les données sont protégées au repos et en transit, mais exposées en clair *en cours d'utilisation*.
- *Modèle de menace cloud :* Serveur *Honest-but-curious*. Nécessité d'opérer sur les données à l'aveugle.
- *Menace quantique :* Vulnérabilité des systèmes asymétriques classiques (RSA, ECC).
- *Cryptographie Post-Quantique (PQC) :* Standardisation d'algorithmes basés sur les problèmes de réseaux euclidiens.

== Chiffrement Homomorphe Complet (FHE)
- *Définition formelle :* Un schéma de chiffrement $E$ est homomorphe si, pour une opération $⋆$ dans le domaine chiffré et $∘$ dans le domaine clair, l'égalité suivante est vérifiée :
  #align(center)[$ E(m_1) ⋆ E(m_2) = E(m_1 ∘ m_2) $]
- *Propriétés :* Préserve la structure algébrique pour l'addition ($⊕$) et la multiplication ($⊗$).
- *Catégories :* PHE (Partiel, ex: Paillier) $->$ SWHE (Limité) $->$ FHE (Profondeur infinie).

== Base Théorique : Ring-LWE (Learning With Errors sur Anneaux)
- Problème calculatoire opérant sur des polynômes dans des anneaux quotients $(bb(Z)_(q)[X])/(X^n + 1)$.
- *Génération des clés :*
  #align(center)[$ b(x) = -a(x) dot s(x) + e(x) quad (mod q) $]
  - $s(x)$ : Polynôme secret (coefficients petits).
  - $a(x)$ : Polynôme aléatoire uniformément réparti.
  - $e(x)$ : Bruit (erreur probabiliste indispensable à la sécurité sémantique).
- *Rôle de l'erreur :* Sans le terme $e(x)$, le secret $s(x)$ est trivialement calculable.

== La Problématique du Bruit (Noise Budget)
- *Le paradoxe LWE :* Le bruit garantit la sécurité (IND-CPA), mais dégrade l'exactitude calculatoire.
- *Condition d'échec (Cliff Effect) :* Échec de déchiffrement si l'erreur accumulée $e$ dépasse le facteur d'échelle $Delta$, empiétant sur les bits du message.

#align(center)[
  #grid(
    columns: (8em, 2em, 8em, 2em, 8em),
    align: center + horizon,
    
    stack(spacing: 10pt,
      text(weight: "bold", size: 0.9em)[Frais],
      rect(width: 8em, height: 2em, stroke: 1pt, radius: 2pt, inset: 0pt)[
        #grid(columns: (3em, 1fr, 1.5em), rows: (100%),
          rect(width:100%, height:100%, fill: rgb("#eaf2d6"), stroke:none)[Msg],
          rect(width:100%, height:100%, fill: luma(245), stroke:none)[],
          rect(width:100%, height:100%, fill: red.lighten(50%), stroke:none)[$e$]
        )
      ]
    ),
    
    [$arrow.r$],
    
    stack(spacing: 10pt,
      text(weight: "bold", size: 0.9em)[Après calculs],
      rect(width: 8em, height: 2em, stroke: 1pt, radius: 2pt, inset: 0pt)[
        #grid(columns: (3em, 1fr, 4em), rows: (100%),
          rect(width:100%, height:100%, fill: rgb("#eaf2d6"), stroke:none)[Msg],
          rect(width:100%, height:100%, fill: luma(245), stroke:none)[],
          rect(width:100%, height:100%, fill: red.lighten(50%), stroke:none)[$e'$]
        )
      ]
    ),
    
    [$arrow.r$],
    
    stack(spacing: 10pt,
      text(weight: "bold", size: 0.9em, fill: red)[Effet Falaise],
      rect(width: 8em, height: 2em, stroke: 2pt + red, radius: 2pt, inset: 0pt)[
        #rect(width:100%, height:100%, fill: red.lighten(30%), stroke:none)[*Corruption*]
      ]
    )
  )
]

== Problématique et Objectifs du Projet
- *Question centrale :* Dans quelle mesure l'accumulation *empirique* du bruit influence-t-elle les performances globales et la viabilité opérationnelle d'un système FHE ?
- *Objectif de l'Étude :* Confronter les approximations théoriques aux mesures physiques et temporelles obtenues via la POC, en mesurant l'évolution réelle du bruit lors d'opérations successives.
