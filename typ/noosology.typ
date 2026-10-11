// 共通ライブラリの読み込み
#import "lib.typ": *

#set page(
  paper: "a5",
  margin: (top: 22mm, bottom: 22mm, left: 22mm, right: 22mm),
  
  // ページ全体の枠線
  background: context {
    let m = 12mm
    place(
      top + left,
      dx: m,
      dy: m,
      rect(
        width: 100% - (m * 2),
        height: 100% - (m * 2),
        stroke: 0.5pt + gray.darken(30%),
        radius: 2pt
      )
    )
  },

  header: context {
    let page_num = counter(page).get().first()
    if page_num > 2 {
      align(center, text(size: 8pt, fill: gray)[ヌーソロジー ― 半田広宣のイデア論 ―])
    }
  },
  footer: context {
    let page_num = counter(page).get().first()
    if page_num > 1 {
      align(center, text(size: 9pt)[#page_num])
    }
  }
)

#set text(
  font: ("Yu Mincho", "BIZ UDPMincho", "MS Mincho"),
  size: 9.5pt,
  lang: "ja"
)

#set par(
  justify: true,
  leading: 0.65em,
  first-line-indent: 1em
)

// --- 表紙ページ ---
#align(center + horizon)[
  #v(-30mm)
  #text(size: 11pt, fill: gray.darken(20%))[The Glossary of Noosology]
  
  #v(10mm)
  #text(size: 28pt, weight: "bold")[ヌーソロジー]
  
  #v(5mm)
  #text(size: 14pt, tracking: 2pt)[― 半田広宣のイデア論 ―]

  #v(20mm)
  // ヴェシカパイシス風の幾何学シンボル
  #box(width: 40mm, height: 25mm, {
    place(top + left, dx: 5mm, circle(radius: 10mm, stroke: 0.5pt + black))
    place(top + left, dx: 15mm, circle(radius: 10mm, stroke: 0.5pt + black))
  })

  #v(20mm)
  #text(size: 12pt)[著者：ラーキー]
  
  #v(5mm)
  #text(size: 9pt, fill: gray)[発行：Larky Note]
]

#pagebreak()

// --- 目次ページ ---
#outline(
  title: [目次],
  indent: 1.5em,
  depth: 3  // 見出し3まで目特に拾わせる
)

#pagebreak()

// --- 本文（用語集） ---
= 用語集
// ★ この1行を追加（これ以降の level 3 見出し「===」が本文上では消え、目次にだけ載る）
#show heading.where(level: 3): none
#include "glossary.typ"  // ← 外部ファイル「glossary.typ」を読み込み

#pagebreak()

// --- 参考文献 ---
= 参考文献

#show figure: set align(left)
#set par(first-line-indent: 0pt)

#show figure.where(kind: "bib"): it => {
  let num = numbering("1", counter(figure.where(kind: "bib")).at(it.location()).first())
  
  block(width: 100%, below: 1.2em, [
    #strong("[" + num + "]") \
    #pad(left: 1.5em, it.body)
  ])
}

#include "references.typ"  // ← 外部ファイル「references.typ」を読み込み

#pagebreak()

// --- 奥付ページ ---
#align(center + horizon)[
////  #v(20mm)
  #text(size: 14pt, weight: "bold")[ヌーソロジー ― 半田広宣のイデア論 ―]
  
  #v(10mm)
  #text(size: 9.5pt)[
    発行日：2026年11月1日 初版発行\
    著者：ラーキー\
    発行：Larky Note\
    \
    #v(5mm)
    本書の無断転載・複製・公衆送信は常識の範囲でご自由にどうぞ。\
    Printed in Japan.
  ]
]