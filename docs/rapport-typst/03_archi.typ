= Architecture Logicielle et Ingénierie des Paramètres

== Modèle d'Architecture
L'architecture logicielle repose sur une séparation asymétrique stricte. Le client gère la génération des clés, le chiffrement initial et le déchiffrement final. Le serveur, qualifié d'aveugle, reçoit uniquement les textes chiffrés et les clés d'évaluation publiques. Il exécute les opérations mathématiques sans jamais accéder aux données en clair ni à la clé secrète.

== Ingénierie des Paramètres
Le degré du polynôme est fixé à $N = 8192$. Cette valeur définit la dimension du treillis euclidien, offrant un compromis optimal entre le niveau de sécurité et les performances de calcul. L'espace du message en clair (*Plain Modulus*) est dimensionné à $t = 45$ bits. Cette taille élevée prévient les dépassements arithmétiques (*overflows*) et isole spécifiquement l'erreur cryptographique.

L'implémentation exploite l'optimisation SIMD (*Single Instruction, Multiple Data*), également appelée *Batching*. Cette technique s'appuie sur le théorème des restes chinois pour partitionner un unique polynôme en de multiples sous-espaces indépendants. Cela permet d'encoder les 6400 pixels de l'image de test au sein des 8192 emplacements du polynôme. 

== Algèbre des Opérations Homomorphes
L'addition homomorphe est employée pour simuler l'ajustement de la luminosité des pixels. Cette opération est mathématiquement linéaire et n'induit qu'une croissance négligeable du bruit.

La multiplication homomorphe est utilisée pour évaluer une fonction de correction Gamma. Cette opération engendre une croissance exponentielle du bruit et génère un polynôme de taille étendue. Une étape de relinéarisation, exploitant les clés d'évaluation (*RelinKeys*), est obligatoirement appliquée après chaque multiplication pour limiter l'expansion mémoire.

== Pile Technologique
L'exécution arithmétique de bas niveau est confiée à la bibliothèque Microsoft SEAL, implémentée en C++17. Ce choix garantit des performances optimales et une latence minimisée par rapport à d'autres bibliothèques pour ce type de calculs @zhu_performance_2023 @dhiman_homomorphic_2023. 

L'orchestration du système s'appuie sur un serveur web développé en Python avec le framework Flask. Le backend Python interagit avec l'exécutable C++ via des appels de sous-processus, collectant les métriques de performance et l'état du bruit au format JSON.
