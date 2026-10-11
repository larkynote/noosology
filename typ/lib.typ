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