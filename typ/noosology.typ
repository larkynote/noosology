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
    text(weight: "bold", size: 10.5pt, fill: blue.darken(35%))[#term]
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
      #if note != "" [  #text(size: 9pt, fill: gray.darken(30%))[#note] ]
      #if url != "" [  #link(url)[#text(size: 8.5pt, fill: blue.darken(20%))[#url]] ]
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
  depth: 3  // ← ここを 3 に変更（見出し3まで目次に拾わせる）
)

#pagebreak()

// --- 本文 ---
= 用語集
// ★ この1行を追加（これ以降の level 3 見出し「===」が本文上では消え、目次にだけ載る）
#show heading.where(level: 3): none
//▼ここから用語集■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
// いざなぎといざなみ
=== イザナギとイザナミ
#term-item(
  term: "イザナギとイザナミ",
  kana: "いざなぎといざなみ",
  desc: [『人類が神を見る日[@book-jinkami]』p.73によれば、イザナギとは13の凪（なぎ）、イザナミとは13の波（なみ）を表していると言われています（オコツト情報）。13という数字はΨ1～Ψ13など観察子の数字と対応しています。]
)

// えぬしー
=== NC
#term-item(
  term: "NC",
  kana: "えぬしー",
  desc: [「ヌースコンストラクション」の略。]
)

// おこつと
=== オコツト
#term-item(
  term: "オコツト",
  kana: "おこつと",
  desc: [冥王星のオコツト。半田さんがチャネリング体験で交信を行った相手の名。]
)

// がいめん
=== 外面
#term-item(
  term: "外面",
  kana: "がいめん",
  desc: [「人間の外面」「付帯質の外面」「精神の外面」といった言葉がありますが、半田さんのX（#link("https://x.com/kohsen")[\@kohsen]） [@handa-x] では「人間の外面」の意味で使われていることが多いです。]
)

// かんさつし
=== 観察子
#term-item(
  term: "観察子",
  kana: "かんさつし",
  desc: [ヌースレクチャー2019の資料によれば、観察子とはケイブユニバースを構成しているホロニックな空間のようなものだと言えます。次元観察子（Ψ1～Ψ14）、大系観察子（Ω1～Ω14）、脈性観察子（Φ1～Φ14）などの種類があります。他者側の表記はアスタリスク「\*」を付けて「Ψ\*1～Ψ\*14」のように表されます。自己側と他者側を合わせると各観察子は28種類の空間の力と方向性になります。次元観察子は「人間、人間の反対、変換人」、大系観察子は「ヒト」、脈性観察子は「真実の人間」と呼ばれる存在に対応しています。Ψ1～Ψ8を元止揚、Ψ9～Ψ10を調整質、Ψ11～Ψ12を中性質、Ψ13～Ψ14を変換質と言います。]
)

// けいぶこんぱす
=== ケイブコンパス
#term-item(
  term: "ケイブコンパス",
  kana: "けいぶこんぱす",
  desc: [cave compass。直訳すると「洞窟の羅針盤」。Ψ1～Ψ10など各観察子の数字同士の関係性を確認するのに使えます。青い帯は円の下側を始点として、赤い帯は円の上側を始点としています。例えば青い帯の奇数の数字はいずれも始点は円の下側で共通なので、Ψ7の範囲は半円分、Ψ5は円の四分の1といった長さ（角度）に対応します。 \
Ψ9思形、Ψ10感性の矢印の先端の色がグラデーションで薄くなっているのは、持続ではなく、持続の方向性を模索している状態であることを表しています。 \
#figure(
  image("svg/cave_compass.svg", width: 80%),
  caption: [ケイブコンパス（Ψ表示）],
  supplement: none,
)]
)

// さとり
=== 悟り
#term-item(
  term: "悟り",
  kana: "さとり",
  desc: [『人類が神を見る日[@book-jinkami]』p.107によれば、悟りとはオリオンにおける負荷、すなわち「観察精神」に入ることだとされています。]
)

// じげんかんさつし
=== 次元観察子
#term-item(
  term: "次元観察子",
  kana: "じげんかんさつし",
  desc: [観察子のひとつ。]
)

// じぞく
=== 持続
#term-item(
  term: "持続",
  kana: "じぞく",
  desc: [持続空間のこと。]
)

// じぞくくうかん
=== 持続空間
#term-item(
  term: "持続空間",
  kana: "じぞくくうかん",
  desc: [Ψ5、すなわち「位置の等化」の空間。自己と他者の意識の次元であり、垂質とも言います。非局所的空間であり、時間が存在しません。物理学では複素ヒルベルト空間と呼ばれ、ルドルフ・シュタイナーの言う「エーテル空間」に対応します。[@handa-x-psi-5]エーテル空間はΩ5としての太陽の力がはたらく空間で、生命を維持しているエーテル体の活動の場だと考えられます[@handa-blog-3782]。]
)

// しりうすげんご
=== シリウス言語
#term-item(
  term: "シリウス言語",
  kana: "しりうすげんご",
  desc: [シリウスファイルにおいてオコツトの用いる独特な用語や概念。]
)

// しりうすふぁいる
=== シリウスファイル
#term-item(
  term: "シリウスファイル",
  kana: "しりうすふぁいる",
  desc: [冥王星のオコツトとの交信記録。オコツト情報と呼ばれることもあります。]
)

// せなかあわせのじことたしゃ
=== 背中合わせの自己と他者
#term-item(
  term: "背中合わせの自己と他者",
  kana: "せなかあわせのじことたしゃ",
  desc: [意識の次元において、自己と他者の空間は前後と上下が反転していると言われています[@handa-x-fig-b2b-tao]。ヌーソロジーの世界観と類似点の多いドゴン神話ではシリウスからやってくるノンモという精霊が登場しますが、彼らもまた背中合わせの姿をしています[@handa-x-fig-b2b-dogon]。]
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

// ぬうすこんすとらくしょん
=== ヌースコンストラクション
#term-item(
  term: "ヌースコンストラクション",
  kana: "ぬうすこんすとらくしょん",
  desc: [ヌースコンストラクション（NC:Noos Construction）。ヌーソロジーのシンボルとも言えるカタチ。右側の球体は自己、左側の球体は他者、中央の球体はモノを意味しています[@handa-x-fig-tetra-in-nc]。 \
#figure(
  image("png/noos_construction_white.png", width: 70%),
  caption: [NC:ヌースコンストラクション],
  supplement: none,
) ]
)

// ぬうそろじい
=== ヌーソロジー
#term-item(
  term: "ヌーソロジー",
  kana: "ぬうそろじい",
  desc: [ヌーソロジーとは物質と精神を空間的視点から統合する具体的なイデア論です [@handa-x] 。ヌースコンストラクションが「自己、他者、モノ」を意味しているように、ヌーソロジーは自他論とも言えます[@handa-x-jitaron-ads-cft]。
ヌーソロジーは冥王星のオコツトと呼ばれる存在とのチャネリング体験、交信記録（通称：シリウスファイル）にルーツをもちますが、単なるチャネリング情報にとどまらず、現実の素粒子物理学、量子論、幾何学、哲学、生物学、心理学、果てはAIや機械学習まで、幅広い知識体系と現実的に整合性をとりつつ具体的な接合を実現しつつあり、武蔵野学院大学にヌーソロジー研究所が発足するなど新たな学問分野としての期待も高まっています。]
)

// はんだこうせん
=== 半田広宣
#term-item(
  term: "半田広宣",
  kana: "はんだこうせん",
  desc: [半田広宣（はんだ こうせん, 本名：はんだ ひろのぶ[@noosology-lab-yt-mov-kohsen-last]、1956年11月4日[@book-sirius][@kohsen-birthday] - 2026年4月21日[@kohsen-meinichi]）。ヌーソロジーというポスト科学主義の宇宙論の創始者。武蔵野学院大学ヌーソロジー研究所所長や客員教授をされていました。『シュタイナー思想とヌーソロジー』『奥行きの子供たち』など多数の著書があります。株式会社ヌースコーポレーションの代表取締役やヌースアカデメイアの主宰をされていました。]
)

// ぺんたーぶしすてむ
=== ペンターブシステム
#term-item(
  term: "ペンターブシステム",
  kana: "ぺんたーぶしすてむ",
  desc: [「１：負荷、２：対化、３：等化、４：中和、５：新たな負荷」という宇宙のリズム。５は新たな１として、１，２，３，４を繰り返します。音楽においてオクターブがドレミファソラシの７種類であるように、ペンターブは負荷、対化、等化、中和の4段階と言えます。[@handa-x-pentave-fuka] \
『シリウス革命』[@book-sirius]p.29では「負荷、反映、等化、中和」という表記になっています。負荷とは第1のベクトルのようなもので、反映とは負荷という作用に対する反作用のようなものを意味します。対化とは負荷と反映という二元性を意味し、等化とは対化を止揚（アウフヘーベン）するはたらきを意味します。中和とは等化という作用に対する反作用のようなもので、等化の反対物だと述べられています。カタチとしては等化は正三角形、中和は六芒星として表現されます。]
)

// めびうすのおび
=== メビウスの帯
#term-item(
  term: "メビウスの帯",
  kana: "めびうすのおび",
  desc: [ヌーソロジーにおいてメビウスの帯は等化の象徴とされています。内と外を等化している精神の運動は時空に対して差異を作り、物質の元を作ります。この差異がさらに差異化していくところに時空が生まれてくるという仕組みになっているため、時空と物質を別々のものとして考えてはいけないということが言われています。[@handa-x-mobius] \
3次元球面では、どの大円をとっても一回転捻りのメビウスの帯のようになっています。[@handa-x-fig-b3s3] \
#figure(
  image("png/b3s3.png", width: 80%),
  caption: [3次元球体を3次元球面として見るときのイメージ],
  supplement: none,
)]
)
//▲ここまで用語集■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■

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

//▼ここから参考文献■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
#bib-item(
  author: "半田広宣",
  title: [X（旧：Twitter）プロフィール],
  url: "https://x.com/kohsen",
  label-key: "handa-x"
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
  author: "半田広宣, 春井星乃, まきしむ",
  title: [『奥行きの子供たち』],
  note: [ISBN978-4899764939],
  label-key: "book-depth"
)

#bib-item(
  author: "半田広宣",
  title: [『シリウス革命』],
  note: [ISBN978-4812700273],
  label-key: "book-sirius"
)

#bib-item(
  author: "半田広宣",
  title: [『人類が神を見る日』],
  note: [ISBN978-4198624798],
  label-key: "book-jinkami"
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

#bib-item(
  author: "半田広宣",
  title: [NCにおける自己と他者の二つの正四面体],
  date: "2025/10/14",
  url: "https://x.com/kohsen/status/1977960747679519013?s=20",
  label-key: "handa-x-fig-tetra-in-nc"
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
  author: "半田広宣",
  title: [AdS/CFT対応の観点で考えると、ヌーソロジーは究極の自他論と言える。],
  date: "2025/01/28",
  url: "https://x.com/kohsen/status/1884248591314870505?s=20",
  label-key: "handa-x-jitaron-ads-cft"
)

#bib-item(
  author: "半田広宣",
  title: [⚫︎メビウスの帯が行っていること
],
  date: "2023/11/06",
  url: "https://x.com/kohsen/status/1721348873460105400?s=20",
  label-key: "handa-x-mobius"
)

#bib-item(
  author: "半田広宣",
  title: [●3次元球体を3次元球面として見るときのイメージ],
  date: "2023/12/10",
  url: "https://x.com/kohsen/status/1733859400694321565?s=20",
  label-key: "handa-x-fig-b3s3"
)

#bib-item(
  author: "半田広宣",
  title: [背中合わせの自己と他者（天上のノンモ）],
  date: "2020/07/17",
  url: "https://x.com/kohsen/status/1284061755451170816?s=20",
  label-key: "handa-x-fig-b2b-dogon"
)

#bib-item(
  author: "半田広宣",
  title: [背中合わせの自己と他者（『光の箱舟』より）],
  date: "2021/11/16",
  url: "https://x.com/kohsen/status/1460425280107864066?s=20",
  label-key: "handa-x-fig-b2b-tao"
)

#bib-item(
  author: "半田広宣",
  title: [Ψ5の空間の特性],
  date: "2020/11/12",
  url: "https://x.com/kohsen/status/1326674560691826688?s=20",
  label-key: "handa-x-psi-5"
)

#bib-item(
  author: "半田広宣",
  title: [シュタイナー哲学とヌーソロジーの最初の接合点],
  date: "2013/10/09",
  url: "https://www.noos.ne.jp/cavesyndrome/?p=3782",
  label-key: "handa-blog-3782"
)

#bib-item(
  author: "半田広宣",
  title: [⚫︎ペンターブシステムと負荷],
  date: "2023/08/31",
  url: "https://x.com/kohsen/status/1697028294628258023?s=20",
  label-key: "handa-x-pentave-fuka"
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