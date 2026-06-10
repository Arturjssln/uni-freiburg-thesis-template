#import "uni-freiburg-thesis-template.typ": *
// or for local testing:
// #import "../src/main.typ": *  // This is for local testing

#show: thesis.with(
  draft: true,
  colored: true,
  title: "Robust Computer Vision",
  author: "Artur Jesslen",
  email: "Master von Eidgenössische Technische Hochschule Lausanne",
  immatriculation: "",
  jury: (
    ([Dekan], [Prof. Dr. Frank Balle]),
    ([Gutachter und Betreuer], [Dr. Adam Kortylewski]),
    ([Gutachter und Betreuer], [Prof. Dr. Abhinav Valada]),
    ([Beisitzer], [Prof. Dr. XX XXXXXX]),
    ([Vorsitzer], [Prof. Dr. XX XXXXXX]),
  ),
  faculty: "Faculty of Engineering, University of Freiburg",
  department: "Department of Computer Science",
  research-group: "Generative Intelligence Lab",
  website: "",
  thesis-type: "Dissertation zur Erlangung des Doktorgrades \n der Technischen Fakultät der Albert-Ludwigs-Universität Freiburg",
  date: datetime.today(),
  language: "en",        // document language
  title-language: "de",  // German front page

  abstract-en: [
    This is a demonstration / tutorial on the usage of the UniBasel Typst template.
  ],

  abstract-de: [
    Dies ist eine Demonstration / Anleitung zur Verwendung der UniBasel Typst-Vorlage.
  ],

  acknowledgments: [
    Adam, Thomas, Alan, Abhinav

    Stefan, JD, Max
    
    Nhi, Olaf

    Leo, Leon, Basavaraj

    Guofeng, Wufei?

    Jelena, Silvio, Philipp

    Celia, Lea, Emma, Yael, Sven

    Mum, Dad, Binou

    Sven, Nuti

    
  ],

  chapters: (
    include "content/list_publication.typ",
    include "content/introduction.typ",
    include "content/background.typ",
    include "content/methodology.typ",
    include "content/implementation.typ",
    include "content/evaluation.typ",
    include "content/discussion.typ",
    include "content/conclusion.typ",
    include "content/future_work.typ",
    include "content/related_work.typ",
    include "content/ai_notice.typ"
  ),
  
  appendices: (
    include "content/appendix.typ",
  ),

  bibliography-content: bibliography("references.bib", style: "ieee", title: none),
)
