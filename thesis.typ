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
    ([Beisitzer], [Prof. Dr. Alan Yuille?]),
    ([Vorsitzer], [Prof. Dr. Thomas Brox?]),
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
    #lorem(310)
  ],

  abstract-de: [
    #lorem(300)
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

    Sven, Nuti hihi

    
  ],

  chapters: (
    include "content/0_list_publication.typ",
    include "content/1_introduction.typ",
    include "content/2_related_work.typ",
    include "content/3_background.typ",
    include "content/4_methodology.typ",
    include "content/5_experiments.typ",
    include "content/6_discussion.typ",
  ),
  
  appendices: (
    include "content/A_appendix.typ",
    include "content/B_papers.typ",
  ),

  bibliography-content: bibliography("references.bib", style: "ieee", title: none),
)
