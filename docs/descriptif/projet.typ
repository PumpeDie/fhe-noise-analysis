#import "uqac.typ": rapport

#show: rapport.with(
  titre: "Chiffrement homomorphe basé sur LWE",
  sous-titre: "Implémentation logicielle et analyse d'impact de la gestion de l'erreur",
  matiere: "8INF874 --- Cryptographie",
  departement: "Département d'informatique et de mathématique",
  professeur: "Florentin Thullier",
  equipe: (
    (nom: "Bossard", prenom: "Justin", code: "BOSJ08070300"),
    (nom: "Plet", prenom: "Samuel", code: "PLES07110100"),
  ),
  date: "20 mai 2026",
  trimestre: "Trimestre d'été",
  logo: "logo-uqac.pdf"
)

= Contexte du projet

La généralisation de l'informatique en nuage (_cloud computing_) et l'externalisation des calculs intensifs imposent de profonds changements dans la gestion de la confidentialité des données. Les méthodes traditionnelles de chiffrement protègent efficacement les informations au repos et en transit. Cependant, elles nécessitent une étape de déchiffrement local dès qu'une opération logique ou arithmétique doit être effectuée sur un serveur distant. Cette vulnérabilité expose les données en clair aux fournisseurs d'infrastructures ou à de potentielles interceptions. Le chiffrement homomorphe complet (FHE) résout ce paradigme en permettant d'exécuter des calculs directement sur des textes chiffrés sans jamais révéler le contenu d'origine.

Parallèlement, l'émergence de l'informatique quantique menace la pérennité des systèmes cryptographiques asymétriques actuels. Les standards basés sur la difficulté de la factorisation ou du logarithme discret deviennent vulnérables. La transition vers des algorithmes résistants aux attaques quantiques constitue désormais une priorité institutionnelle et industrielle. Les schémas de chiffrement homomorphe modernes intègrent cette contrainte en s'appuyant principalement sur des problèmes de réseaux euclidiens, notamment le problème de l'apprentissage avec erreurs (_Learning With Errors_ ou LWE) @bhoi_post-quantum_2025. L'idée principale de ce projet réside dans l'étude et l'analyse de la viabilité pratique de ces schémas post-quantiques homomorphes. Ce choix thématique se justifie par la convergence nécessaire entre la protection algorithmique à long terme et la confidentialité des calculs externalisés.

L'environnement technologique de ce projet englobe les architectures logicielles distribuées manipulant des données hautement sensibles, telles que les dossiers médicaux partagés ou les transactions financières confidentielles. Dans ces scénarios, les clients ne possèdent pas toujours les ressources de calcul requises pour exécuter des modèles complexes, comme l'inférence de réseaux de neurones profonds. Ils doivent sous-traiter ces tâches à des serveurs tiers tout en respectant des réglementations strictes sur la protection de la vie privée. L'implémentation de solutions homomorphes basées sur LWE s'adresse directement à ces entités en leur offrant des garanties de sécurité rigoureuses, y compris face à un attaquant doté d'un ordinateur quantique.

Malgré ces avantages théoriques, le passage à une application logicielle concrète se heurte à des contraintes structurelles majeures. La formulation mathématique du problème LWE repose sur l'injection d'une erreur probabiliste, appelée bruit, lors du chiffrement pour garantir la sécurité. Or, chaque manipulation homomorphe, en particulier la multiplication de textes chiffrés, engendre une croissance cumulative de ce bruit. Si le bruit accumulé dépasse un certain seuil critique, le texte chiffré devient corrompu et le déchiffrement échoue, effaçant l'information initiale. La gestion de ce budget de bruit conditionne l'efficacité globale du système. Sa réinitialisation nécessite des opérations de rafraîchissement (_bootstrapping_) extrêmement lourdes en ressources et en temps d'exécution.

Pour explorer ces limitations, ce projet adopte une double approche complémentaire. Le premier angle consiste en une analyse pratique par implémentation logicielle. Il s'agira de développer une preuve de concept à l'aide de bibliothèques cryptographiques open-source reconnues afin de mesurer l'évolution concrète du bruit lors d'opérations successives @zhu_performance_2023. Le second angle repose sur une évaluation analytique et comparative des performances. Cet axe se focalisera sur la quantification fine de la latence de calcul, de la consommation mémoire et de l'impact du dimensionnement des clés sur l'efficacité globale du système.

= Objectifs visés

La problématique générale de ce projet consiste à déterminer dans quelle mesure l'accumulation empirique du bruit influence les performances globales et la viabilité opérationnelle d'un système de chiffrement homomorphe basé sur le problème _Learning With Errors_ (LWE). Les modèles mathématiques traditionnels s'appuient souvent sur des analyses de cas moyen ou des distributions gaussiennes pour estimer cette croissance. Cependant, des recherches récentes démontrent que le bruit réel suit parfois des distributions à queue lourde, conduisant à une sous-estimation systématique de l'erreur dans les circuits complexes @gao_critique_2025. L'enjeu de cette étude est donc de confronter les approximations théoriques de la littérature aux mesures physiques obtenues lors de l'exécution de calculs homomorphes concrets.

Pour répondre à cette problématique, la démarche s'articule autour de la réalisation d'une infrastructure logicielle expérimentale. Le premier objectif opérationnel implique la sélection et le déploiement d'une bibliothèque cryptographique open-source éprouvée, telle que Microsoft SEAL ou OpenFHE, reconnues pour leur efficacité et leur modularité @zhu_performance_2023. À partir de ce socle, une preuve de concept (POC) sera développée pour exécuter des suites d'additions et de multiplications homomorphes sur des circuits arithmétiques de profondeurs variables. Cette implémentation permettra de suivre de manière dynamique la consommation du budget de bruit restant dans les textes chiffrés. Enfin, des tests de performance systématiques documenteront des métriques clés, notamment la latence d'exécution, la taille des clés générées et le taux de réussite du déchiffrement selon les configurations de paramètres choisies.

Ce projet présente néanmoins plusieurs limites potentielles qu'il convient de baliser dès la phase de conception. La contrainte principale réside dans le goulot d'étranglement computationnel que représente le rafraîchissement du bruit. L'exécution d'un mécanisme de _bootstrapping_ complet pour restaurer le budget de bruit consomme une part prépondérante du temps de calcul global. En raison des limitations temporelles du calendrier académique, l'optimisation ou l'intégration avancée de cet algorithme pourrait s'avérer irréalisable, restreignant l'expérimentation à des schémas de chiffrement homomorphe à profondeur limitée. De plus, la charge mémoire requise par la manipulation des structures de réseaux euclidiens complexes constitue une barrière matérielle non négligeable pour des environnements de test standards. L'évaluation se concentrera donc sur des scénarios de calcul simplifiés sans prétendre à une optimisation industrielle globale.

#bibliography(
  "refs.bib",
  style: "apa",
  title: "Références"
)
