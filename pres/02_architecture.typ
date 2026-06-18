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

== Mécanique du Schéma BFV
- *Encodage et Facteur d'échelle (*$Delta$*) :* $m'(x) = m(x) dot Delta$ avec $Delta = floor(q/t)$.
- *Chiffrement :* Génération d'un doublet $(c_0, c_1)$ représentant le texte chiffré :
  #align(center)[$ c_0(x) = b(x) dot r(x) + m'(x) quad (mod q) $]
  #align(center)[$ c_1(x) = a(x) dot r(x) quad (mod q) $]
- *Déchiffrement :* $m'(x) = c_0(x) + c_1(x) dot s(x) quad (mod q)$, suivi du décodage $m(x) = floor(m'(x) / Delta)$.

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
- *Implémentation logicielle :* Utilisation de l'API *Microsoft SEAL* (C++) optimisée pour les opérations NTT (*Number Theoretic Transform*).
