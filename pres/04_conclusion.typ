= Conclusion et Perspectives

== Bilan
- Viabilité théorique des calculs sur données chiffrées démontrée.
- Garanties de sécurité post-quantiques validées.
- *Obstacles pratiques :* La gestion du budget de bruit et l'expansion mémoire limitent actuellement les applications en temps réel.

== Le Concept de Résolution : Bootstrapping
- *Définition :* Évaluation du circuit de déchiffrement de manière homomorphe pour "nettoyer" le bruit sans révéler le clair.
- Permet une profondeur de calcul théoriquement infinie (FHE pur).
- *Raison de l'exclusion du POC :* Coût computationnel prohibitif, masquant par ailleurs l'observation de la croissance du bruit (objectif initial du projet).

== Perspectives Industrielles
- *Accélération matérielle :* Développement de FPGA ou d'ASIC spécialisés pour réduire la latence des opérations polynomiales complexes (NTT - Number Theoretic Transform).
- *Schémas alternatifs :* Adoption du schéma CKKS (Arithmétique approximative) pour l'intelligence artificielle et le *Machine Learning*, environnements naturellement tolérants au bruit.


