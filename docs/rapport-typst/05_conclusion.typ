= Conclusion et Perspectives

== Bilan de la preuve de concept
La preuve de concept valide la viabilité théorique du chiffrement homomorphe basé sur LWE. L'exécution de calculs à l'aveugle préserve strictement l'intégrité des données, conditionnée par le maintien d'un budget de bruit positif. Cependant, des obstacles pratiques majeurs limitent son déploiement immédiat. L'expansion massive de la mémoire et l'accumulation inexorable de l'erreur restreignent cette approche à des circuits de profondeur finie (Levelled-FHE).

== Le concept de Bootstrapping
Le *Bootstrapping* constitue la solution théorique à l'épuisement du bruit en restaurant le budget d'erreur sans exposer le message en clair. Ce mécanisme permet d'atteindre une profondeur de calcul infinie @li_survey_2026. Toutefois, son coût computationnel est actuellement prohibitif. Son intégration a été exclue de ce projet afin de privilégier l'observation directe de la dégradation de l'erreur, bien que de nouvelles stratégies basées sur l'apprentissage par renforcement émergent pour optimiser son déclenchement @zhang_reinforcement_2026.

== Évolutions matérielles et industrielles
La démocratisation du chiffrement homomorphe exige une accélération matérielle spécifique. La multiplication polynomiale sature la bande passante mémoire des processeurs classiques. La conception de circuits dédiés (FPGA ou ASIC) est indispensable pour assurer la parallélisation massive requise.

Malgré ces défis, les perspectives d'intégration industrielle se concrétisent. Un cas d'usage pertinent est la recherche visuelle chiffrée sur appareil mobile. Dans ce modèle, un client soumet une image chiffrée à un serveur. Ce dernier évalue homomorphiquement la requête contre une base de données mondiale et retourne un résultat chiffré, garantissant ainsi une confidentialité absolue.

#figure(
  image("figure2.png", width: 60%),
  caption: [Architecture asymétrique pour la recherche visuelle chiffrée sur appareil mobile. Source : Apple Machine Learning Research (https://machinelearning.apple.com/research/homomorphic-encryption)]
)

