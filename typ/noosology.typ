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

// --- 【AIフレンドリー設計】用語定義用のカスタム関数 ---
#let term-item(term: "", kana: "", desc: []) = {
  block(width: 100%, below: 1.2em, breakable: false, {
    text(weight: "bold", size: 10.5pt, fill: blue.darken(35%))[・#term]
    if kana != "" {
      text(size: 9pt, fill: gray.darken(30%))[ （#kana）]
    }
    v(0.2em)
    pad(left: 1.2em)[#desc]
  })
}

// --- 【AIフレンドリー設計】更新履歴用のカスタム関数 ---
#let changelog(version: "", date: "", items: ()) = {
  block(width: 100%, below: 1em, {
    // バージョンと日付のヘッダー行
    text(weight: "bold", size: 9.5pt, font: ("Courier New", "MS Gothic"))[v#version]
    text(size: 8.5pt, fill: gray.darken(35%))[ （#date）]
    v(0.1em)
    // 複数の変更項目をリスト形式で展開
    pad(left: 1.2em, {
      for item in items {
        list(item)
      }
    })
  })
}

// --- 【AIフレンドリー設計】参考文献用の構造化関数（修正版） ---
#let bib-item(author: "", title: "", date: "", note: "", url: "", label-key: none) = {
  let fig = figure(
    kind: "bib",
    supplement: [文献],
    [
      #if author != "" [ #strong(author), ]
      #title
      #if date != "" [ #text(size: 9pt, fill: gray.darken(30%))[（#date）] ]
      #if note != "" [ \ #text(size: 9pt, fill: gray.darken(30%))[#note] ]
      #if url != "" [ \ #link(url)[#text(size: 8.5pt, fill: blue.darken(20%))[#url]] ]
    ]
  )
  
  if label-key != none {
    [#fig#label(label-key)]
  } else {
    fig
  }
}

// --- 表紙ページ ---
#align(center + horizon)[
  #v(-30mm)
  #text(size: 14pt, tracking: 2pt)[半田広宣のイデア論]
  
  #v(10mm)
  #text(size: 28pt, weight: "bold")[ヌーソロジー]
  
  #v(5mm)
  #text(size: 11pt, fill: gray.darken(20%))[The Glossary of Noosology]

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
//  depth: 2
  depth: 3  // ← ここを 3 に変更（見出し3まで目次に拾わせる）
)

#pagebreak()

// --- 本文 ---
= 用語集


//▼ここから用語集■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
// がいめん
=== 外面
#term-item(
  term: "外面",
  kana: "がいめん",
  desc: [「人間の外面」「付帯質の外面」「精神の外面」といった言葉がありますが、半田さんのX（#link("https://x.com/kohsen")[\@kohsen]） [@handa-x] では「人間の外面」の意味で使われていることが多いです。]
)

// けいぶこんぱす
=== ケイブコンパス
#term-item(
  term: "ケイブコンパス",
  kana: "けいぶこんぱす",
  desc: [cave compass。直訳すると「洞窟の羅針盤」。Ψ1～Ψ10など各観察子の数字同士の関係性を確認するのに使えます。青い帯は円の下側を始点として、赤い帯は円の上側を始点としています。例えば青い帯の奇数の数字はいずれも始点は円の下側で共通なので、Ψ7の範囲は半円分、Ψ5は円の四分の1といった長さ（角度）に対応します。 \
  #image("svg/cave_compass.svg", width: 80%)
  ]
)

// とくさのかんだから
=== 十種神宝
#term-item(
  term: "十種神宝",
  kana: "とくさのかんだから",
  desc: [物部氏の祖であるニギハヤヒノミコトが天降りの際に天照大御神（あまてらすおおみかみ）から授けられたとされる10種類の神宝のことです。ヌースレクチャー2016の資料によると、沖津鏡（おきつかがみ）とは他者の視野空間、辺津鏡（へつかがみ）とは自己の視野空間、八握剣（やつかのつるぎ）とは八咫鏡（やたのかがみ）を支えている「奥行き」、生玉（いくたま）は垂質Ψ5、死返玉（まかるかへしのたま）は垂質の反映Ψ6、足玉（たるたま）は位置の変換Ψ7、道返玉（ちかへしのたま）は位置の転換Ψ8、蛇比礼（おろちのひれ）は人間の思形Ψ9、蜂比礼（はちのひれ）は人間の感性Ψ10、品物之比礼（くさぐさのもののひれ）はΨ11～12に対応すると考えられています。]
)

// にんげんのがいめん
=== 人間の外面
#term-item(
  term: "人間の外面",
  kana: "にんげんのがいめん",
  desc: [「人間の外面」は見えている空間であり、「人間の内面」は見られている空間であると言われています[@handa-x-fig-gaimen-naimen]。前者は鏡像による時空、後者は主体による持続空間と言えます[@handa-x-fig-two-apple-self]。]
)

// ぬうそろじい
=== ヌーソロジー
#term-item(
  term: "ヌーソロジー",
  kana: "ぬうそろじい",
  desc: [ヌーソロジーとは物質と精神を空間的視点から統合する具体的なイデア論です [@handa-x] 。]
)

// はんだこうせん
=== 半田広宣
#term-item(
  term: "半田広宣",
  kana: "はんだこうせん",
  desc: [半田広宣（はんだ こうせん, 本名：はんだ ひろのぶ[@noosology-lab-yt-mov-kohsen-last]、1956年11月4日[@book-sirius][@kohsen-birthday] - 2026年4月21日[@kohsen-meinichi]）。ヌーソロジーというポスト科学主義の宇宙論の創始者。武蔵野学院大学ヌーソロジー研究所所長や客員教授をされていました。『シュタイナー思想とヌーソロジー』『奥行きの子供たち』など多数の著書があります。株式会社ヌースコーポレーションの代表取締役やヌースアカデメイアの主宰をされていました。]
)
//▲ここまで用語集■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■

#pagebreak()

// --- 参考文献 ---
= 参考文献

#show figure: set align(left)
#set par(first-line-indent: 0pt)

// 図表の番号の書式を [1] のようなブラケット付きに設定し、行頭に自動付与する
#show figure.where(kind: "bib"): it => {
  let num = numbering("1", counter(figure.where(kind: "bib")).at(it.location()).first())
  
  block(width: 100%, below: 1.2em, [
    #strong("[" + num + "]") \
    #pad(left: 1.5em, it.body)
  ])
}

//▼ここから参考文献■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■

#bib-item(
  author: "半田広宣, 春井星乃, まきしむ",
  title: [『奥行きの子供たち』],
  note: [ISBN978-4899764939],
  label-key: "book-depth"
)

#bib-item(
  author: "半田広宣",
  title: [X（旧：Twitter）プロフィール],
  url: "https://x.com/kohsen",
  label-key: "handa-x"
)

#bib-item(
  author: "半田広宣",
  title: [「人間の外面と内面」の反転関係を表す図],
  date: "2025/07/07",
  url: "https://x.com/kohsen/status/1942203587557499140?s=20",
  label-key: "handa-x-fig-gaimen-naimen"
)

#bib-item(
  author: "半田広宣",
  title: [⚫︎私は二人いるということを自覚すること],
  date: "2023/09/29",
  url: "https://x.com/kohsen/status/1707587570618777725?s=20",
  label-key: "handa-x-fig-two-apple-self"
)

#bib-item(
  author: "武蔵野学院大学ヌーソロジー研究所",
  title: [再生リスト「半田広宣（所長）」],
  url: "https://youtube.com/playlist?list=PLdqwrJECkIBUSOrHyvzoQipdxjRcH5bE2&si=IRSWdSV9pH4LMlG9",
  label-key: "noosology-lab-yt-list-kohsen"
)

#bib-item(
  author: "武蔵野学院大学ヌーソロジー研究所",
  title: [「SU(3)Cで紐解く客観の謎」―私たちはなぜ、「同じ世界」を共有できるのか　 半田VS砂子　　ヌーソロジー研究所 :研究動画#42],
  date: "2026/08/13",
  url: "https://youtu.be/L79sgGwewCc?si=dSwV73WJ8wT4AiYA",
  label-key: "noosology-lab-yt-mov-kohsen-last"
)

#bib-item(
  author: "半田広宣",
  title: [『シリウス革命』],
  note: [ISBN978-4812700273],
  label-key: "book-sirius"
)

#bib-item(
  author: "半田広宣",
  title: [半田さんの誕生日に関する投稿],
  date: "2022/11/04",
  url: "https://x.com/kohsen/status/1588529713349550086?s=20",
  label-key: "kohsen-birthday"
)

#bib-item(
  author: "武蔵野学院大学",
  title: [半田客員教授・所長のご逝去のお知らせについて],
  date: "2026/04/27",
  url: "https://www.musashino.ac.jp/mgu/news/15014/",
  label-key: "kohsen-meinichi"
)

//▲ここまで参考文献■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■

#pagebreak()

// --- 奥付ページ ---
#align(center + horizon)[
  #v(20mm)
  #text(size: 14pt, weight: "bold")[ヌーソロジー]
  
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