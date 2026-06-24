#import "@preview/touying:0.7.4": *
#import themes.metropolis: *

#show: metropolis-theme.with(
  aspect-ratio: "16-9",
  config-info(
    title: [Chiffrement homomorphe basé sur LWE],
    subtitle: [Projet de Cryptographie (8INF874) --- Implémentation logicielle et analyse d'impact de la gestion de l'erreur],
    author: [Groupe 6 \ Justin Bossard --- #text(fill: luma(100))[BOSJ08070300] \ Samuel Plet --- #text(fill: luma(100))[PLES07110100]],
    date: datetime.today(),
    institution: [Université du Québec à Chicoutimi (UQAC)],
    logo: image("uqac.svg", height: 1cm),
  ),
    config-colors(
    primary: rgb("#6e8b15"),
    primary-light: rgb("#eaf2d6"),
    secondary: rgb("#2c3b06"),
    neutral-lightest: rgb("#fafafa"),
    neutral-dark: rgb("#3d472a"),
    neutral-darkest: rgb("#1d2412"),
  ),
)

#title-slide()

#include "01_introduction.typ"
#include "02_architecture.typ"
#include "03_demonstration.typ"
#include "04_conclusion.typ"

#focus-slide[
  Merci de votre attention. \
  *Questions ?*
]
