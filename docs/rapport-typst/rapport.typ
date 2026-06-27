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
  date: "22 juin 2026",
  trimestre: "Trimestre d'été",
  logo: "logo-uqac.pdf",
  table-des-matieres: true,
)

#include("01_introduction.typ")
#include("02_theorie.typ")
#include("03_archi.typ")
#include("04_analyses.typ")
#include("05_conclusion.typ")


#pagebreak()
#bibliography(
  "refs.bib",
  style: "apa",
  title: "Références"
)
