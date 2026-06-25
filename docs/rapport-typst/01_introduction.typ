= Introduction
Notre projet est disponible sur GitHub : https://github.com/PumpeDie/fhe-noise-analysis.

== Contexte technologique
L'externalisation des calculs vers l'informatique en nuage (Cloud) pose un défi majeur de sécurité. Actuellement, les données sont efficacement protégées au repos et en transit par les méthodes de chiffrement standards. Cependant, elles doivent être déchiffrées pour être manipulées par un processeur. Cette étape expose les informations sensibles sur les serveurs distants. Le chiffrement homomorphe (FHE) résout ce problème en permettant d'exécuter des opérations directement sur des données chiffrées, assurant une confidentialité totale en cours d'utilisation.

== Contexte cryptographique
L'émergence de l'ordinateur quantique menace la pérennité des systèmes cryptographiques asymétriques actuels, tels que RSA ou ECC. L'algorithme de Shor rend ces standards vulnérables à court terme. Une transition vers la cryptographie post-quantique (PQC) est donc indispensable. Les algorithmes basés sur la difficulté des problèmes de réseaux euclidiens constituent la principale alternative @bhoi_post-quantum_2025. Parmi eux, le problème LWE (Learning With Errors) offre une sécurité prouvée contre les attaques classiques et quantiques.

== Problématique
Le fonctionnement du problème LWE repose sur l'injection volontaire d'une erreur mathématique, appelée bruit. Ce bruit est fondamental : il garantit la sécurité sémantique du chiffrement. Paradoxalement, ce même bruit est destructeur pour les calculs. Chaque opération homomorphe (particulièrement la multiplication) amplifie cette erreur. Si le bruit dépasse une certaine limite, le message devient corrompu et le déchiffrement échoue. 

De plus, la littérature théorique estime souvent la croissance de cette erreur en se basant sur des modèles de cas moyen. La réalité des circuits arithmétiques complexes montre parfois des accumulations d'erreurs beaucoup plus rapides dues à des distributions à queue lourde @gao_critique_2025. Il existe donc un écart significatif entre les prédictions théoriques et la dégradation pratique.

== Objectifs
Ce projet vise à évaluer concrètement l'accumulation du bruit dans un système basé sur LWE. L'objectif principal est de concevoir une implémentation logicielle pour mesurer empiriquement la consommation du budget de bruit lors d'opérations successives. Cette preuve de concept permettra d'observer directement le point de rupture cryptographique et d'analyser la latence induite par la gestion de cette erreur.
