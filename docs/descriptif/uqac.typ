#let rapport(
  titre: "",
  sous-titre: "",
  matiere: "",
  departement: "",
  professeur: "",
  equipe: (),
  date: "",
  trimestre: "",
  logo: "logo-uqac.pdf",
  table-des-matieres: false,
  couleur-primaire: rgb("#466d12"),
  body
) = {
  // Configuration globale
  set document(title: titre)
  set text(lang: "fr", font: "New Computer Modern", size: 11pt)
  set page(paper: "a4")
  set par(justify: true)
  set heading(numbering: "1.")
  set cite(style: "apa")

  show link: set text(fill: couleur-primaire)
  show link: underline

  show heading.where(level: 1): set text(fill: couleur-primaire.darken(10%))
  show heading.where(level: 2): set text(fill: couleur-primaire)
  show heading.where(level: 3): set text(fill: couleur-primaire.lighten(20%))

  // Page de garde
  page(
    margin: 3cm,
    header: none,
    footer: none,
  )[
    #align(center)[
      #image(logo, width: 40%)
      #v(2em)
      #text(14pt, weight: "bold", fill: couleur-primaire)[#departement] \
      #text(12pt)[#matiere]
      
      #v(4em)
      #text(22pt, weight: "bold", fill: couleur-primaire.darken(15%))[#titre] \
      #v(1em)
      #text(16pt)[#sous-titre]
    ]

    #v(4em)

    #align(center)[
      #block(width: 70%)[
        #grid(
          columns: (1fr, 1fr),
          align(left)[
            *Professeur :* \
            #professeur
          ],
          align(right)[
            *Par :* \
            #for membre in equipe [
              #membre.prenom #membre.nom \
              #text(size: 9pt, fill: luma(100))[#membre.code] \
              #v(0.5em)
            ]
          ]
        )
      ]
    ]

    #align(center + bottom)[
      #trimestre \
      #date
    ]
  ]

  // Configuration des pages de contenu
  set page(
    margin: (top: 2.5cm, bottom: 2cm, x: 2cm),
    header: [
      #set text(8pt)
      #grid(
        columns: (1fr, 1fr),
        align(left)[#image(logo, height: 1cm)],
        align(right + horizon)[#titre]
      )
      #v(-0.5em)
      #line(length: 100%, stroke: 0.5pt + couleur-primaire)
    ],
    footer: [
      #set text(9pt)
      #line(length: 100%, stroke: 0.5pt + couleur-primaire)
      #v(0.2em)
      #align(right)[
        #context [Page #counter(page).display() sur #counter(page).final().first()]
      ]
    ]
  )

  counter(page).update(1)

  // Table des matières
  if table-des-matieres {
    outline(title: "Table des matières", indent: auto)
    pagebreak()
  }

  body
}
