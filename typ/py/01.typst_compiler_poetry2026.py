import os
import platform
import subprocess
from pathlib import Path

# ==========================================
# 【設定】ファイルパスの指定（すべてスクリプト基準の相対パス）
# ==========================================
# コンパイルする対象の .typ ファイルへの相対パス
TARGET_TYP_PATH = "../poetry2026.typ"

# 出力する PDF ファイルへの相対パス
OUTPUT_PDF_PATH = "../../pdf/poetry2026.pdf"

# 起動時にPDFを自動で開くかどうか (True: 開く / False: 開かない)
AUTO_OPEN_PDF = True


def pause():
    """終了時にウィンドウが即座に閉じないよう待機する"""
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


def watch_typst():
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

    print(f"リアルタイム監視開始 (watch): {typ_path.name} -> {pdf_path.name}")
    print(f"出力先: {pdf_path}")
    print(f"作業ディレクトリ: {working_dir}")
    print("----------------------------------------")
    print("※ファイルを保存すると自動で再コンパイルされます。")
    print("※終了する場合は、このウィンドウで Ctrl + C を押してください。")
    print("=" * 40)

    try:
        # typst watch コマンドを常駐プロセス(Popen)として実行
        process = subprocess.Popen(
            ["typst", "watch", str(typ_path), str(pdf_path)],
            cwd=str(working_dir),
            text=True,
            encoding="utf-8"
        )

        # 起動時にPDFを自動で開く
        if AUTO_OPEN_PDF:
            open_pdf(pdf_path)

        # 監視プロセスが終了するまで待機
        process.wait()

    except FileNotFoundError:
        print(
            "[エラー] 'typst' コマンドが見つかりません。Typst CLIがインストールされているか、パスが通っているか確認してください。"
        )
    except Exception as e:
        print(f"[エラー] 予期せぬエラーが発生しました: {e}")

    pause()


if __name__ == "__main__":
    watch_typst()