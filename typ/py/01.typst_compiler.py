import os
import platform
import subprocess
from pathlib import Path

# ==========================================
# 【設定】ファイルパスの指定（すべてスクリプト基準の相対パス）
# ==========================================
# コンパイルする対象の .typ ファイルへの相対パス
TARGET_TYP_PATH = "../noosology.typ"

# 出力する PDF ファイルへの相対パス
OUTPUT_PDF_PATH = "../../pdf/noosology.pdf"

# コンパイル成功後にPDFを自動で開くかどうか (True: 開く / False: 開かない)
AUTO_OPEN_PDF = True


def pause():
    """ダブルクリック実行時にウィンドウが即座に閉じないよう待機する"""
    print("\n" + "=" * 40)
    input("エンターキーを押すと終了します...")


def open_pdf(pdf_path):
    """生成されたPDFをOSのデフォルトアプリケーションで開く"""
    try:
        if platform.system() == "Windows":
            os.startfile(str(pdf_path))
        elif platform.system() == "Darwin":  # macOS
            subprocess.run(["open", str(pdf_path)], check=True)
        else:  # Linux 等
            subprocess.run(["xdg-open", str(pdf_path)], check=True)
        print(f"[情報] PDFを開きました: {pdf_path.name}")
    except Exception as e:
        print(f"[警告] PDFを自動で開けませんでした: {e}")


def compile_typst():
    # スクリプト自身のディレクトリを取得
    script_dir = Path(__file__).resolve().parent

    # ターゲットファイルとPDF出力先の絶対パスを算出
    typ_path = (script_dir / TARGET_TYP_PATH).resolve()
    pdf_path = (script_dir / OUTPUT_PDF_PATH).resolve()

    if not typ_path.exists():
        print(f"[エラー] 対象のTypstファイルが見つかりません: {typ_path}")
        pause()
        return

    # 出力先ディレクトリが存在しない場合は作成する
    pdf_path.parent.mkdir(parents=True, exist_ok=True)

    # .typファイルが存在するディレクトリをワーキングディレクトリにする
    working_dir = typ_path.parent

    print(f"コンパイル開始: {typ_path.name} -> {pdf_path.name}")
    print(f"出力先: {pdf_path}")
    print(f"作業ディレクトリ: {working_dir}")

    try:
        # typst compile コマンドを実行
        result = subprocess.run(
            ["typst", "compile", str(typ_path), str(pdf_path)],
            cwd=str(working_dir),
            capture_output=True,
            text=True,
            encoding="utf-8",
            check=True,
        )

        print(f"[成功] PDFが正常に生成されました: {pdf_path}")
        if result.stdout:
            print(result.stdout)

        # 成功時にPDFを自動で開く
        if AUTO_OPEN_PDF:
            open_pdf(pdf_path)

    except FileNotFoundError:
        print(
            "[エラー] 'typst' コマンドが見つかりません。Typst CLIがインストールされているか、パスが通っているか確認してください。"
        )
    except subprocess.CalledProcessError as e:
        print("[エラー] Typst のコンパイル中にエラーが発生しました:")
        print(e.stderr)

    # 処理完了後（成功時もエラー時も）ウィンドウが閉じないようにする
    pause()


if __name__ == "__main__":
    compile_typst()