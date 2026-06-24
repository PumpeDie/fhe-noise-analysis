= Analyse Expérimentale et Métriques

== Protocole d'Évaluation
Le protocole d'évaluation repose sur un cas d'usage de traitement d'image délégué. Le client chiffre une image source en niveaux de gris ($80 times 80$ pixels). Le serveur aveugle applique deux transformations homomorphes distinctes : un ajustement de la luminosité et une fonction de correction Gamma. Les résultats déchiffrés sont ensuite comparés mathématiquement à l'image attendue.

#figure(
  image("poc_screenshot.png", width: 70%),
  caption: [Interface de la preuve de concept illustrant l'architecture asymétrique Client/Serveur.]
)

== Suivi de la Dégradation du Bruit
L'implémentation mesure dynamiquement le budget de bruit invariant restant. Avec les paramètres sélectionnés ($N=8192$, $t=45$ bits), le budget initial s'élève à environ 135 bits (assurant un niveau de sécurité post-quantique standard de 128 bits).

L'opération d'addition homomorphe ne consomme qu'une fraction négligeable de ce budget ($approx 1$ bit). À l'inverse, chaque multiplication homomorphe ampute massivement ce budget de manière constante (environ 32 bits par itération). La profondeur multiplicative maximale du circuit est donc strictement bornée. La décroissance du budget y est linéaire en fonction du nombre d'opérations ($135 arrow.r 103 arrow.r 71 arrow.r 39 arrow.r 7 arrow.r 0$ bits).

L'expérimentation valide l'Effet Falaise (*Cliff Effect*). Tant que le budget reste strictement positif, l'écart d'erreur demeure absolument nul. Dès que le budget atteint 0 bit, les données subissent une corruption totale et instantanée.

#figure(
  grid(columns: 5, align: bottom, gutter: 1em,
    stack(spacing: 5pt, text(size: 0.7em)[121 bits], rect(width: 3em, height: 75pt, fill: rgb("#6e8b15").lighten(20%)), text(size: 0.8em)[Frais]),
    stack(spacing: 5pt, text(size: 0.7em)[64 bits], rect(width: 3em, height: 45pt, fill: rgb("#6e8b15").lighten(40%)), text(size: 0.8em)[Mult 1]),
    stack(spacing: 5pt, text(size: 0.7em)[6 bits], rect(width: 3em, height: 12pt, fill: orange), text(size: 0.8em)[Mult 2]),
    stack(spacing: 5pt, text(size: 0.7em, fill: red)[0 bit], rect(width: 3em, height: 2pt, fill: red), text(weight: "bold", size: 0.8em, fill: red)[Corruption])
  ),
    caption: [Évolution de la consommation du budget de bruit et illustration visuelle de la corruption (Effet Falaise)]
)

== Profilage de la Latence
L'analyse des temps d'exécution, cohérente avec les observations menées lors d'évaluations comparatives de schémas FHE @jiang_fhebench_2022, révèle une forte asymétrie computationnelle.

L'addition homomorphe s'exécute en moyenne en $130 mu s$. La multiplication homomorphe, combinée à son étape obligatoire de relinéarisation, requiert environ $20 m s$. L'opération de mise au carré (optimisée mathématiquement) requiert un temps d'exécution légèrement inférieur à la multiplication standard, mais consomme un budget de bruit strictement identique. Cette asymétrie confirme que la profondeur multiplicative d'un circuit définit son goulot d'étranglement principal.

== Empreinte Mémoire et Réseau
Le chiffrement basé sur LWE induit une expansion massive des données traitées. Un entier standard en clair de 8 octets est transformé en un doublet de polynômes chiffrés pesant approximativement 100 Ko (ratio $approx 10^4$). L'utilisation de l'optimisation SIMD permet d'amortir partiellement ce ratio.

Cependant, l'impact réseau reste significatif. Le client doit transmettre au serveur les clés d'évaluation publiques (*RelinKeys*). Pour les paramètres actuels, ces clés représentent un volume de données d'environ 16 Mo, pénalisant la bande passante avant le début des calculs.

== Limites de l'implémentation
Bien que fonctionnelle, cette preuve de concept présente plusieurs limites d'ingénierie et d'analyse qui restreignent sa portée théorique :
- *Distribution statistique de l'erreur :* L'outil extrait uniquement la valeur scalaire du budget de bruit (`invariant_noise_budget`). Il ne permet pas d'analyser la distribution exacte des coefficients pour observer empiriquement les phénomènes à queue lourde décrits dans la littérature récente @gao_critique_2025.
- *Biais méthodologique d'épuisement (Débordement vs Bruit) :* L'évaluation de la fonction Gamma ($x^gamma$) fait croître exponentiellement la valeur mathématique du message. Cela crée un risque de confondre l'épuisement du budget de bruit avec un débordement arithmétique (*overflow*) du module en clair $t$. Une mesure rigoureuse isolant strictement l'effet du bruit exigerait des multiplications successives par une constante mathématique neutre (valeur $1$).
- *Optimisation de la profondeur multiplicative :* La fonction de correction Gamma utilise une boucle d'itération séquentielle. Une approche optimale requerrait un arbre d'exponentiation binaire ou l'algorithme de Paterson-Stockmeyer pour minimiser la profondeur du circuit.
