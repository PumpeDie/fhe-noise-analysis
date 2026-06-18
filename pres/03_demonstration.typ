= Démonstration et Analyse

== La Preuve de Concept (POC)
- *Scénario :* Traitement d'image délégué (80x80 pixels).
- *Opération 1 : Addition (Luminosité)*
  - Ajout d'une constante en clair.
  - Consommation de bruit quasi nulle.
- *Opération 2 : Multiplication (Correction Gamma)*
  - Évaluation polynomiale : $y = x^gamma$
  - Multiplications successives (*Chiffré-Chiffré*).
  - Consommation massive du budget de bruit.

== Analyse des Observations Empiriques
- *L'Effet Falaise (Cliff Effect) :*
  - Tant que le budget de bruit est $> 0$ bit, l'écart d'erreur avec la vérité terrain est strictement de $0$. L'intégrité est parfaite.
  - À $0$ bit, l'image devient instantanément un bruit blanc (corruption totale).
- *Validation :* Démontre empiriquement la limite des circuits arithmétiques de profondeur fixe (*Levelled-FHE*).

== Discussion des Métriques
- *Expansion des données (Ciphertext Expansion) :*
  - Un pixel en clair (1 octet) devient un polynôme chiffré pesant plusieurs mégaoctets.
  - Goulot d'étranglement majeur pour la bande passante réseau.
- *Latence computationnelle :*
  - Asymétrie extrême entre l'addition (micro-secondes) et la multiplication suivie d'une relinéarisation (milli-secondes/secondes).
