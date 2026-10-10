//GAS（Google Apps Script）のソースコードです。

// --- 【設定】シート名や名前定義（Named Ranges）の定数定義 ---
const CONFIG = {
  REF_SHEET_NAME: "書籍『ヌーソロジー』参考文献",
  TERM_SHEET_NAME: "書籍『ヌーソロジー』用語集",
  EXEC_SHEET_NAME: "GAS実行",
  // 名前付き範囲の名称
  TERM_OUTPUT_RANGE: "用語集アウトプット",
  REF_OUTPUT_RANGE: "参考文献アウトプット",
  FULL_CODE_OUTPUT_RANGE: "コード全体アウトプット"
};

/**
 * 【メイン関数】各シートの変換を行い、最新データに更新した上で、
 * テンプレートと結合して「コード全体アウトプット」に一括出力する
 */
function generateAllTypstData() {
  var ss = SpreadsheetApp.getActiveSpreadsheet();
  
  // 0. 実行開始時に既存の出力（各シートのoutput列および実行シートの名前付き範囲）をいったん全消しする
  clearAllOutputs(ss);
  
  // 1. まず用語集と参考文献の個別コードを更新
  var refCount = processReferencesSheet(ss);
  var termCount = processTermsSheet(ss);
  
  // 2. 「GAS実行」シートの各アウトプットセル、および全体コード出力を実行
  outputToExecSheet(ss);
  
  SpreadsheetApp.getUi().alert(
    "すべての変換と「GAS実行」シートへの一括出力が完了しました！\n\n" +
    "・参考文献: " + refCount + "件 更新\n" +
    "・用語集: " + termCount + "件 更新\n" +
    "・出力先: 「" + CONFIG.EXEC_SHEET_NAME + "」シート\n" +
    " - 命名定義「" + CONFIG.FULL_CODE_OUTPUT_RANGE + "」に全体コードを出力しました"
  );
}

/**
 * 実行開始時に既存の出力内容をすべてクリアする関数
 */
function clearAllOutputs(ss) {
  // 1. 参考文献シートのoutput列をクリア
  var refSheet = ss.getSheetByName(CONFIG.REF_SHEET_NAME);
  if (refSheet) {
    var values = refSheet.getDataRange().getValues();
    if (values.length > 1) {
      var headers = values[0];
      var outIdx = -1;
      for (var i = 0; i < headers.length; i++) {
        if (String(headers[i]).trim() === "output") {
          outIdx = i;
          break;
        }
      }
      if (outIdx !== -1) {
        refSheet.getRange(2, outIdx + 1, values.length - 1, 1).clearContent();
      }
    }
  }

  // 2. 用語集シートのoutput列をクリア
  var termSheet = ss.getSheetByName(CONFIG.TERM_SHEET_NAME);
  if (termSheet) {
    var values = termSheet.getDataRange().getValues();
    if (values.length > 1) {
      var headers = values[0];
      var outIdx = -1;
      for (var i = 0; i < headers.length; i++) {
        if (String(headers[i]).trim() === "output") {
          outIdx = i;
          break;
        }
      }
      if (outIdx !== -1) {
        termSheet.getRange(2, outIdx + 1, values.length - 1, 1).clearContent();
      }
    }
  }

  // 3. 「GAS実行」シートの名前付き範囲（アウトプットセル群）をクリア
  clearNamedRangeValue(ss, CONFIG.TERM_OUTPUT_RANGE);
  clearNamedRangeValue(ss, CONFIG.REF_OUTPUT_RANGE);
  clearNamedRangeValue(ss, CONFIG.FULL_CODE_OUTPUT_RANGE);
}

/**
 * 指定した名前付き範囲のセル内容をクリアするヘルパー関数
 */
function clearNamedRangeValue(ss, rangeName) {
  var namedRange = ss.getRangeByName(rangeName);
  if (namedRange) {
    namedRange.clearContent();
  }
}

/**
 * 参考文献シートを処理する内部関数
 */
function processReferencesSheet(ss) {
  var sheet = ss.getSheetByName(CONFIG.REF_SHEET_NAME);
  if (!sheet) return 0;
  
  var values = sheet.getDataRange().getValues();
  if (values.length < 2) return 0;
  
  var headers = values[0];
  
  function findCol(names) {
    for (var i = 0; i < headers.length; i++) {
      var h = String(headers[i]).trim();
      if (names.indexOf(h) !== -1) return i;
    }
    return -1;
  }
  
  var colMap = {
    author: findCol(["author"]),
    title: findCol(["title"]),
    date: findCol(["date"]),
    note: findCol(["note"]),
    url: findCol(["url"]),
    labelKey: findCol(["label-key", "labelkey", "label_key"]),
    output: findCol(["output"])
  };
  
  if (colMap.output === -1) return 0;
  
  var count = 0;
  for (var i = 1; i < values.length; i++) {
    var row = values[i];
    var title = colMap.title !== -1 ? row[colMap.title] : "";
    if (!title) {
      sheet.getRange(i + 1, colMap.output + 1).setValue("");
      continue;
    }
    
    var author = colMap.author !== -1 ? row[colMap.author] : "";
    var rawDate = colMap.date !== -1 ? row[colMap.date] : "";
    var note = colMap.note !== -1 ? row[colMap.note] : "";
    var url = colMap.url !== -1 ? row[colMap.url] : "";
    var labelKey = colMap.labelKey !== -1 ? row[colMap.labelKey] : "";
    
    var dateStr = "";
    if (rawDate instanceof Date) {
      dateStr = Utilities.formatDate(rawDate, Session.getScriptTimeZone(), "yyyy/MM/dd");
    } else if (rawDate) {
      dateStr = String(rawDate).trim();
    }
    
    var code = "#bib-item(\n";
    if (author) code += '  author: "' + String(author).trim() + '",\n';
    code += '  title: [' + title + '],\n';
    if (dateStr) code += '  date: "' + dateStr + '",\n';
    if (note) code += '  note: [' + note + '],\n';
    if (url) code += '  url: "' + String(url).trim() + '",\n';
    if (labelKey) code += '  label-key: "' + String(labelKey).trim() + '"\n';
    
    code = code.replace(/,\n$/, "\n");
    code += ")";
    
    sheet.getRange(i + 1, colMap.output + 1).setValue(code);
    count++;
  }
  return count;
}

/**
 * 用語集シートを処理する内部関数
 */
function processTermsSheet(ss) {
  var sheet = ss.getSheetByName(CONFIG.TERM_SHEET_NAME);
  if (!sheet) return 0;
  
  var values = sheet.getDataRange().getValues();
  if (values.length < 2) return 0;
  
  var headers = values[0];
  function findCol(names) {
    for (var i = 0; i < headers.length; i++) {
      var h = String(headers[i]).trim();
      if (names.indexOf(h) !== -1) return i;
    }
    return -1;
  }
  
  var colMap = {
    term: findCol(["term"]),
    kana: findCol(["kana"]),
    desc: findCol(["desc"]),
    output: findCol(["output"])
  };
  
  if (colMap.output === -1) return 0;
  
  var count = 0;
  for (var i = 1; i < values.length; i++) {
    var row = values[i];
    var term = colMap.term !== -1 ? row[colMap.term] : "";
    if (!term) {
      sheet.getRange(i + 1, colMap.output + 1).setValue("");
      continue;
    }
    
    var kana = colMap.kana !== -1 ? row[colMap.kana] : "";
    var desc = colMap.desc !== -1 ? row[colMap.desc] : "";
    
    var code = "// " + (kana ? kana : term) + '\n';
    code += '=== ' + term + '\n';
    code += '#term-item(\n';
    code += '  term: "' + term + '",\n';
    if (kana) code += '  kana: "' + kana + '",\n';
    code += '  desc: [' + desc + ']\n';
    code += ')';
    
    sheet.getRange(i + 1, colMap.output + 1).setValue(code);
    count++;
  }
  return count;
}

/**
 * 名前定義を使って各パーツを収集し、テンプレートと結合して「コード全体アウトプット」に出力する関数
 */
function outputToExecSheet(ss) {
  // 1. 用語集から出力コードを収集
  var termSheet = ss.getSheetByName(CONFIG.TERM_SHEET_NAME);
  var termCodes = [];
  if (termSheet) {
    var values = termSheet.getDataRange().getValues();
    var headers = values[0];
    var outIdx = headers.indexOf("output");
    if (outIdx !== -1) {
      for (var i = 1; i < values.length; i++) {
        var val = values[i][outIdx];
        if (val) termCodes.push(val);
      }
    }
  }
  
  // 2. 参考文献から出力コードを収集
  var refSheet = ss.getSheetByName(CONFIG.REF_SHEET_NAME);
  var refCodes = [];
  if (refSheet) {
    var values = refSheet.getDataRange().getValues();
    var headers = values[0];
    var outIdx = headers.indexOf("output");
    if (outIdx !== -1) {
      for (var i = 1; i < values.length; i++) {
        var val = values[i][outIdx];
        if (val) refCodes.push(val);
      }
    }
  }
  
  var combinedTerms = termCodes.join("\n\n");
  var combinedRefs = refCodes.join("\n\n");
  
  // 3. 名前定義（Named Ranges）を経由して、それぞれのセルにパーツを出力
  setNamedRangeValue(ss, CONFIG.TERM_OUTPUT_RANGE, combinedTerms);
  setNamedRangeValue(ss, CONFIG.REF_OUTPUT_RANGE, combinedRefs);
  
  // 4. Typst全体のテンプレートコードを組み立て、全体出力用の名前定義セルへ流し込む
  var fullTypstCode = buildFullTypstTemplate(combinedTerms, combinedRefs);
  setNamedRangeValue(ss, CONFIG.FULL_CODE_OUTPUT_RANGE, fullTypstCode);
}

/**
 * 指定した名前付き範囲（Named Range）のセルに値を設定するヘルパー関数
 */
function setNamedRangeValue(ss, rangeName, value) {
  var namedRange = ss.getRangeByName(rangeName);
  if (namedRange) {
    namedRange.setValue(value);
  } else {
    console.warn("名前付き範囲「" + rangeName + "」が見つかりませんでした。スプレッドシート側で名前の定義を確認してください。");
  }
}

/**
 * Typst全体のテンプレートを組み立てる関数
 */
function buildFullTypstTemplate(glossaryContent, bibContent) {
  return `#set page(
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
  depth: 3  // ← ここを 3 に変更（見出し3まで目次に拾わせる）
)

#pagebreak()

// --- 本文 ---
= 用語集
// ★ この1行を追加（これ以降の level 3 見出し「===」が本文上では消え、目次にだけ載る）
#show heading.where(level: 3): none
//▼ここから用語集■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
${glossaryContent}
//▲ここまで用語集■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■

#pagebreak()

// --- 参考文献 ---
= 参考文献

#show figure: set align(left)
#set par(first-line-indent: 0pt)

#show figure.where(kind: "bib"): it => {
  let num = numbering("1", counter(figure.where(kind: "bib")).at(it.location()).first())
  
  block(width: 100%, below: 1.2em, [
    #strong("[" + num + "]") \\
    #pad(left: 1.5em, it.body)
  ])
}

//▼ここから参考文献■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
${bibContent}
//▲ここまで参考文献■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■

#pagebreak()

// --- 奥付ページ ---
#align(center + horizon)[
////  #v(20mm)
  #text(size: 14pt, weight: "bold")[ヌーソロジー ― 半田広宣のイデア論 ―]
  
  #v(10mm)
  #text(size: 9.5pt)[
    発行日：2026年11月1日 初版発行\\
    著者：ラーキー\\
    発行：Larky Note\\
    \\
    #v(5mm)
    本書の無断転載・複製・公衆送信は常識の範囲でご自由にどうぞ。\\
    Printed in Japan.
  ]
]`;
}