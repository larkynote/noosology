// ==========================================
// KDPペーパーバック対応 短歌集テンプレート
// （ページ数2倍・全12首構成・完全モノクロ）
// ==========================================

#set page(
  paper: "a5",
  margin: (top: 20mm, bottom: 20mm, left: 18mm, right: 28mm),

  header: context {
    let page_num = counter(page).get().first()
    if page_num > 2 {
      align(center, text(size: 8pt, fill: luma(110))[はんだづけ ― ヌーソロジー詩集2026 ―])
    }
  },
  
  footer: context {
    let page_num = counter(page).get().first()
    if page_num > 1 {
      align(center, text(size: 9pt, fill: luma(90))[#page_num])
    }
  }
)

#set text(
  font: ("Yu Mincho", "BIZ UDPMincho", "MS Mincho"),
  size: 10pt,
  lang: "ja"
)

#set par(
  justify: false,
  leading: 0.8em,
  first-line-indent: 0pt
)

// ------------------------------------------
// 自動採番カウンタ
// ------------------------------------------
#let tanka-counter = counter("tanka-number")

// 正多角形の頂点と中心からの点線を描画する関数
#let polygon-with-diagonals(n, r) = {
  let cx = r
  let cy = r
  
  let pts = ()
  let i = 0
  while i < n {
    let angle = (i * 2 * calc.pi) / n - (calc.pi / 2)
    let x = r + r * calc.cos(angle)
    let y = r + r * calc.sin(angle)
    pts.push((x, y))
    i = i + 1
  }
  
  box(width: r * 2, height: r * 2, {
    place(top + left, polygon(
      stroke: 0.5pt + luma(120),
      fill: luma(250),
      ..pts
    ))
    
    for pt in pts {
      place(top + left, line(
        start: (cx, cy),
        end: pt,
        stroke: (dash: "dashed", thickness: 0.4pt, paint: luma(150))
      ))
    }
  })
}

// 短歌を表示しつつ、右側に番号に応じた多角形＋点線を配置する関数
#let tanka(body) = context [
  #tanka-counter.step()
  #let current-num = tanka-counter.get().first()
  
  #grid(
    columns: (1fr, 32mm),
    gutter: 8mm,
    [
      #block(
        width: 100%,
        inset: (x: 6pt, y: 8pt),
        stroke: (bottom: 0.4pt + luma(200)),
        [
          #text(size: 8.5pt, fill: luma(110))[【#current-num】] \
          #v(4pt)
          #text(size: 10pt, weight: "regular")[#body]
        ]
      )
    ],
    // 右側余白の多角形エリア（3番目以降のみ描画）
    align(center + horizon)[
      #if current-num >= 3 [
        #polygon-with-diagonals(current-num, 10mm)
        #v(2pt)
        #text(size: 7.5pt, fill: luma(140))[n = #current-num]
      ]
    ]
  )
  #v(0.5em)
]


// ==========================================
// 1. 表紙
// ==========================================
#align(center + horizon)[
  #v(-10mm)
////  #text(size: 10pt, tracking: 2pt, fill: luma(100))[思 索 録]
  
  #v(15mm)
  #text(size: 26pt, weight: "bold")[はんだづけ]
  
  #v(8mm)
  #text(size: 11pt, tracking: 1.5pt)[― ヌーソロジー詩集2026 ―]

  #v(35mm)
  #text(size: 11pt)[ラーキー]
]

#pagebreak()

// ==========================================
// 2. 目次
// ==========================================
#outline(
  title: [目次],
  indent: 1.5em,
  depth: 1
)

#pagebreak()

////// ==========================================
////// 3. 本文：第一章
////// ==========================================
////= 第一章：構造と余白
= はじめに

#v(1em)

////#tanka([
////  光散る \
////  部屋の隅なる \
////  一画に \
////  影を置いては \
////  静けさを書く
////])
////
////#tanka([
////  解きほぐす \
////  言葉の糸の \
////  もつれ合い \
////  解くるを待たず \
////  夜を明かしぬ
////])
////
////#tanka([
////  キーボード \
////  叩く指先に \
////  とどまりて \
////  三十一の音 \
////  カタカタと浮く
////])
////
////#pagebreak()

#tanka([
  光散る \
  理解を超えて \
  響く声 \
  ウタの思想の \
  楽しそうかな
])

#tanka([
  模索する \
  ヌーソロジーの \
  言の葉の \
  縫い揃える字 \
  ロゴスの世かな
])

#tanka([
  元止揚（げんしよう） \
  そこから出るは \
  電磁の場 \
  どげんしようか \
  韻（ライム）ば踏むか
])

#pagebreak()

////#tanka([
////  本棚の \
////  隙間にひそむ \
////  古い問い \
////  幾何学模様の \
////  夢を見にけり
////])
////
////#tanka([
////  静寂の \
////  底に響くは \
////  秒針の \
////  刻む時間を \
////  すくう指先
////])
////
////#tanka([
////  白紙へと \
////  落とす一滴 \
////  黒きインク \
////  広がりゆきて \
////  宇宙をなす
////])
////
////#pagebreak()

#tanka([
  本の日に \
  本を出そうと \
  頑張って \
  路線反転 \
  面舵（おもかじ）逃げろ
])

#tanka([
  クロノスの \
  テレビを消して \
  カイロスの \
  時間を感じ \
  アイオーンへと
])

#tanka([
  AIの \
  雰囲気だけの \
  文字よりは \
  自分で紡ぐ \
  文字がええわい
])

#pagebreak()

////// ==========================================
////// 4. 本文：第二章
////// ==========================================
////= 第二章：時間と視点
= ヌーソロジー詩集

#v(1em)

////#tanka([
////  薄明の \
////  空に揺らぐは \
////  星の痕 \
////  記録すること \
////  生くることなり
////])
////
////#tanka([
////  名前なき \
////  感情ひとつ \
////  すくい上げ \
////  行間に置き \
////  本を閉じたり
////])
////
////#tanka([
////  ゆく雲の \
////  影のかたちを \
////  追いかけて \
////  遠き視線は \
////  空に消えゆく
////])
////
////#pagebreak()

#tanka([
  半田さん \
  星の帰りに \
  光る点 \
  観察位置の \
  無限遠点
])

#tanka([
  名も知らぬ \
  視線の主に \
  見られては \
  物語編む \
  無意識の内
])

#tanka([
  ゆく雲の \
  無常の姿 \
  ありやなし \
  心のままに \
  映るお話
])

#pagebreak()

////#tanka([
////  コーヒーの \
////  冷めるまでの間に \
////  紡ぎ出す \
////  微小な世界の \
////  座標軸かな
////])
////
////#tanka([
////  幾何学の \
////  網の目くぐる \
////  光線が \
////  紙の白さを \
////  鋭く縁取る
////])
////
////#tanka([
////  終わらない \
////  思考の旅の \
////  その果てに \
////  新しい朝の \
////  気配が満ちる
////])
////
////#pagebreak()

#tanka([
  コーヒーの \
  黒の時間の \
  紡ぎ出す \
  微小世界の \
  思考でいいの
])

#tanka([
  位相幾何学（トポロジー） \
  紡ぐ思考の \
  光線が \
  至る用紙に \
  神を見る日々
])

#tanka([
  終わらない \
  思考の旅の \
  その果てに \
  新しい朝の \
  気配が満ちる
])

#pagebreak()

// ==========================================
// 5. あとがき
// ==========================================
#set par(
  justify: true,
  leading: 0.7em,
  first-line-indent: 1em
)

= あとがき

本書を手にとつていただき、誠にありがとうございます。

////日常の中で意識の輪郭からこぼれ落ちていく微細な感覚や、言葉になる前の思索の断片を、31音という定型の器に流し込む試みとして編纂いたしました。

#pagebreak()

// ==========================================
// 6. 奥付
// ==========================================
#align(center + horizon)[
  #text(size: 13pt, weight: "bold")[はんだづけ ― ヌーソロジー詩集2026 ―]
  
  #v(12mm)
  #text(size: 9.5pt, fill: luma(100))[
    発行日：2026年11月1日 初版発行\
    著者：ラーキー\
    \
    #v(6mm)
////    本書の無断転載・複製・公衆送信を禁じます。\
    本書の無断転載・複製・公衆送信は\
    常識の範囲でご自由にお使いください。\
    Printed in Japan.
  ]
]