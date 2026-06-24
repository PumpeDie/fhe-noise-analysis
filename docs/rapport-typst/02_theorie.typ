= Fondements Théoriques (Chiffrement Homomorphe et LWE)

== Le Chiffrement Homomorphe
Le chiffrement homomorphe permet d'effectuer des calculs mathématiques directement sur des données chiffrées. Un schéma $E$ est dit homomorphe s'il préserve la structure algébrique des données. Pour une opération $star$ dans le domaine chiffré et $circle.small$ dans le domaine clair, l'égalité suivante s'applique :
$ E(m_1) star E(m_2) = E(m_1 circle.small m_2) $

Ces schémas supportent l'addition et la multiplication. Leur évolution historique se divise en trois catégories :
- *PHE (Partially Homomorphic Encryption) :* Supporte une seule opération mathématique.
- *SWHE (Somewhat Homomorphic Encryption) :* Supporte l'addition et la multiplication, mais pour un nombre limité d'opérations successives (circuit de profondeur finie).
- *FHE (Fully Homomorphic Encryption) :* Supporte une profondeur de calcul infinie grâce au mécanisme de rafraîchissement du bruit (*bootstrapping*).

== Le problème LWE et Ring-LWE
Le chiffrement s'appuie sur le problème mathématique LWE (Learning With Errors). Il consiste à résoudre des systèmes d'équations linéaires volontairement bruités. Ce problème de réseaux euclidiens offre une sécurité robuste face aux ordinateurs quantiques.

Pour des raisons d'efficacité calculatoire, l'implémentation utilise la variante structurée Ring-LWE (RLWE). L'arithmétique n'opère plus sur des matrices, mais sur des polynômes. Cette structure algébrique accélère significativement les opérations. Ces calculs s'effectuent dans un anneau quotient $(bb(Z)_(q)[X])/(X^n + 1)$, ce qui empêche l'explosion de la taille des données en réduisant continuellement le degré des polynômes.

La génération des clés repose sur l'équation suivante :
$ b(x) = -a(x) dot s(x) + e(x) mod q $
Le polynôme $s(x)$ est la clé secrète. Le polynôme $a(x)$ est un masque aléatoire public. La clé publique est formée par la paire $(b(x), a(x))$.

== L'Anatomie du Bruit Cryptographique
Le terme $e(x)$ représente le bruit cryptographique. Cette erreur probabiliste est strictement nécessaire pour la sécurité sémantique (IND-CPA), mais exige une gestion rigoureuse @bai_research_2024.

Cependant, ce bruit entrave le calcul. Chaque évaluation homomorphe amplifie l'erreur sous-jacente. L'addition engendre une croissance linéaire du bruit. La multiplication provoque une croissance exponentielle.

Le texte chiffré dispose d'un budget de bruit limité. L'Effet Falaise (*Cliff Effect*) survient lorsque ce budget est épuisé. Le bruit accumulé déborde alors sur les bits de poids fort réservés au message. À ce stade, la donnée est irrémédiablement corrompue et le déchiffrement échoue.

== Comparaison des schémas
L'implémentation nécessite le choix d'un schéma cryptographique adapté, un processus facilité par la comparaison des propriétés des différents standards @doan_survey_2023.

Le schéma CKKS utilise une arithmétique à virgule flottante approximative, où le bruit se confond volontairement avec l'erreur de précision numérique @kim_approximate_2020. 

Le schéma BFV utilise une arithmétique entière exacte. Le bruit LWE y reste mathématiquement isolé du message clair jusqu'au point de saturation.

Ce projet retient le schéma BFV. L'arithmétique exacte garantit une intégrité absolue tant que le budget de bruit est positif, permettant d'observer rigoureusement le franchissement de la limite d'erreur.
