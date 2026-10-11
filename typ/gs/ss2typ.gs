// ヌーソロジー書籍化プロジェクト
// GAS（Google Apps Script）のソースコードです。

// --- 【設定】シート名や名前定義（Named Ranges）の定数定義 ---
const CONFIG = {
  REF_SHEET_NAME: "書籍『ヌーソロジー』参考文献",
  TERM_SHEET_NAME: "書籍『ヌーソロジー』用語集",
  EXEC_SHEET_NAME: "GAS実行",
  // 名前付き範囲の名称
  TERM_OUTPUT_RANGE: "用語集アウトプット",
  REF_OUTPUT_RANGE: "参考文献アウトプット"
};

/**
 * 【メイン関数】各シートの変換を行い、最新データに更新した上で、
 * 「GAS実行」シートの各アウトプットセルに出力する
 */
function generateAllTypstData() {
  var ss = SpreadsheetApp.getActiveSpreadsheet();
  
  // 0. 実行開始時に既存の出力（各シートのoutput列および実行シートの名前付き範囲）をいったん全消しする
  clearAllOutputs(ss);
  
  // 1. まず用語集と参考文献の個別コードを更新
  var refCount = processReferencesSheet(ss);
  var termCount = processTermsSheet(ss);
  
  // 2. 「GAS実行」シートの各アウトプットセルに出力を反映
  outputToExecSheet(ss);
  
  SpreadsheetApp.getUi().alert(
    "すべての変換と「GAS実行」シートへの一括出力が完了しました！\n\n" +
    "・参考文献: " + refCount + "件 更新\n" +
    "・用語集: " + termCount + "件 更新\n" +
    "・出力先: 「" + CONFIG.EXEC_SHEET_NAME + "」シート"
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
 * 各パーツを収集し、「GAS実行」シートの名前付き範囲に出力する関数
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
 * 指定した名前付き範囲（Named Range）から値を取得するヘルパー関数
 */
function getNamedRangeValue(ss, rangeName) {
  var namedRange = ss.getRangeByName(rangeName);
  if (namedRange) {
    var val = namedRange.getValue();
    return val ? String(val) : "";
  }
  console.warn("名前付き範囲「" + rangeName + "」が見つかりませんでした。");
  return "";
}

/**
 * 「GAS実行」シートの用語集内容を取得し、インポート文を追加して「glossary.typ」としてダウンロードする
 */
function downloadGlossaryFile() {
  var ss = SpreadsheetApp.getActiveSpreadsheet();
  var rawContent = getNamedRangeValue(ss, CONFIG.TERM_OUTPUT_RANGE);
  
  if (!rawContent) {
    SpreadsheetApp.getUi().alert(
      "「" + CONFIG.EXEC_SHEET_NAME + "」シートの名前付き範囲「" + CONFIG.TERM_OUTPUT_RANGE + "」が空です。\n" +
      "先にメインの変換処理を実行してデータを生成してください。"
    );
    return;
  }
  
  // 先頭に lib.typ のインポート文を自動追加する
  var content = '#import "lib.typ": term-item\n\n' + rawContent;
  
  showDownloadDialog("glossary.typ", content, "用語集ファイル（glossary.typ）のダウンロード");
}

/**
 * 「GAS実行」シートの参考文献内容を取得し、インポート文を追加して「references.typ」としてダウンロードする
 */
function downloadReferencesFile() {
  var ss = SpreadsheetApp.getActiveSpreadsheet();
  var rawContent = getNamedRangeValue(ss, CONFIG.REF_OUTPUT_RANGE);
  
  if (!rawContent) {
    SpreadsheetApp.getUi().alert(
      "「" + CONFIG.EXEC_SHEET_NAME + "」シートの名前付き範囲「" + CONFIG.REF_OUTPUT_RANGE + "」が空です。\n" +
      "先にメインの変換処理を実行してデータを生成してください。"
    );
    return;
  }
  
  // 先頭に lib.typ のインポート文を自動追加する
  var content = '#import "lib.typ": bib-item\n\n' + rawContent;
  
  showDownloadDialog("references.typ", content, "参考文献ファイル（references.typ）のダウンロード");
}

/**
 * 共通のダウンロード用モーダルダイアログを表示するヘルパー関数
 */
function showDownloadDialog(filename, fileContent, title) {
  var template = HtmlService.createTemplate(
    '<!DOCTYPE html>' +
    '<html>' +
    '<head><meta charset="utf-8"></head>' +
    '<body style="font-family:sans-serif; text-align:center; padding:20px;">' +
    '  <p><b><?= filename ?></b> の準備ができました。</p>' +
    '  <button id="dl-btn" style="background:#4285f4; color:white; border:none; padding:10px 20px; font-size:14px; border-radius:4px; cursor:pointer;">ファイルをダウンロード</button>' +
    '  <p style="font-size:12px; color:#666; margin-top:15px;">ボタンを押すとダウンロードが始まります。<br>完了したらこのウインドウを閉じてください。</p>' +
    '  <script>' +
    '    document.getElementById("dl-btn").onclick = function() {' +
    // JSON.parse を噛ませることで、改行や特殊文字を元のテキストの構造通りに完璧に復元します
    '      var rawContent = JSON.parse(<?= safeContent ?>);' +
    '      var blob = new Blob([rawContent], { type: "text/plain;charset=utf-8" });' +
    '      var url = URL.createObjectURL(blob);' +
    '      var a = document.createElement("a");' +
    '      a.href = url;' +
    '      a.download = "<?= filename ?>";' +
    '      document.body.appendChild(a);' +
    '      a.click();' +
    '      document.body.removeChild(a);' +
    '      URL.revokeObjectURL(url);' +
    '    };' +
    '  </script>' +
    '</body>' +
    '</html>'
  );
  
  template.filename = filename;
  template.safeContent = JSON.stringify(fileContent);
  
  var htmlOutput = template.evaluate()
      .setWidth(350)
      .setHeight(200);
      
  SpreadsheetApp.getUi().showModalDialog(htmlOutput, title);
}