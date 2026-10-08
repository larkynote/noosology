#!/usr/bin/env python3
"""
CFT空間 / AdS空間 / dS空間 図を SVG で再現し、表示用 HTML を生成する単一スクリプト。

使い方:
    python3 cft_cave_compass.py            # 同じフォルダに cave_compass.svg と index.html を出力
    python3 cft_cave_compass.py --open     # 生成後にブラウザで開く
"""
import math
import sys
import webbrowser
from pathlib import Path

W, H = 1024, 768
CX, CY = 500, 405          # 中心（黒点）

# ---- 色 ----
TEAL = "#265a70"
PSI9 = "#2a6b8a"
RED = "#9a2f35"
RED_TXT = "#8e2a2f"
GRID = "#d9d9d9"
GREY_TXT = "#555555"
FONT = "'Hiragino Sans','Hiragino Kaku Gothic ProN','Noto Sans JP','Yu Gothic','Meiryo',sans-serif"


# ---- 内側円の8分割 ----
# 右半円（青）: 下(180°)から右を通って上へ。累積角 π/8, π/4, π/2, π → Ψ1,Ψ3,Ψ5,Ψ7
# 左半円（赤）: 上(0°)から左を通って下へ。累積角 π/8, π/4, π/2, π → Ψ2,Ψ4,Ψ6,Ψ8
CUM = [math.pi / 8, math.pi / 4, math.pi / 2, math.pi]
_prev = [0.0] + CUM[:-1]
SECTORS = []   # (ラベル, 開始θ°, 終了θ°)  θは真上=0°・時計回り正
for lab, c0, c1 in zip(("Ψ1", "Ψ3", "Ψ5", "Ψ7"), _prev, CUM):
    SECTORS.append((lab, 180 - math.degrees(c0), 180 - math.degrees(c1)))
for lab, c0, c1 in zip(("Ψ2", "Ψ4", "Ψ6", "Ψ8"), _prev, CUM):
    SECTORS.append((lab, -math.degrees(c0), -math.degrees(c1)))
LABEL_R = 172


# ---- 幾何ヘルパー（θ は真上=0°、時計回りが正）----
def pt(r, deg):
    t = math.radians(deg)
    return CX + r * math.sin(t), CY - r * math.cos(t)


def ring(r_in, r_out, a1, a2):
    """a1→a2 の円環セクターのパス（a2<a1 なら反時計回り）"""
    sweep_out = 1 if a2 > a1 else 0
    large = 1 if abs(a2 - a1) > 180 else 0
    x1, y1 = pt(r_out, a1)
    x2, y2 = pt(r_out, a2)
    x3, y3 = pt(r_in, a2)
    x4, y4 = pt(r_in, a1)
    return (f"M{x1:.1f},{y1:.1f} A{r_out},{r_out} 0 {large} {sweep_out} {x2:.1f},{y2:.1f} "
            f"L{x3:.1f},{y3:.1f} A{r_in},{r_in} 0 {large} {1 - sweep_out} {x4:.1f},{y4:.1f} Z")


def poly(points, fill, extra=""):
    d = " ".join(f"{x:.1f},{y:.1f}" for x, y in points)
    return f'<polygon points="{d}" fill="{fill}" {extra}/>'


def text(x, y, s, size, fill, weight="400", anchor="middle", extra=""):
    return (f'<text x="{x}" y="{y}" font-size="{size}" fill="{fill}" font-weight="{weight}" '
            f'text-anchor="{anchor}" dominant-baseline="central" {extra}>{s}</text>')


def build_svg() -> str:
    o = []
    o.append(f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {W} {H}" '
             f'font-family="{FONT}" role="img" aria-label="CFT空間・AdS空間・dS空間の図">')

    # ---- グラデーション ----
    o.append(f'''<defs>
  <linearGradient id="gBlue" gradientUnits="userSpaceOnUse" x1="300" y1="120" x2="440" y2="690">
    <stop offset="0" stop-color="#2d6a8a"/><stop offset="0.45" stop-color="#6f95ad"/>
    <stop offset="1" stop-color="#e6eef4"/>
  </linearGradient>
  <linearGradient id="gRed" gradientUnits="userSpaceOnUse" x1="560" y1="690" x2="640" y2="120">
    <stop offset="0" stop-color="#9a2f35"/><stop offset="0.45" stop-color="#c58a80"/>
    <stop offset="1" stop-color="#f0dcc4"/>
  </linearGradient>
</defs>''')

    o.append(f'<rect width="{W}" height="{H}" fill="#ffffff"/>')

    # ---- 背景の同心円・放射線 ----
    o.append(f'<circle cx="{CX}" cy="{CY}" r="385" fill="#fff" stroke="{GRID}" stroke-width="2"/>')
    o.append(f'<circle cx="{CX}" cy="{CY}" r="335" fill="none" stroke="{GRID}" stroke-width="2"/>')
    for k in range(16):
        a = k * 22.5
        x1, y1 = pt(250, a)
        x2, y2 = pt(385, a)
        o.append(f'<line x1="{x1:.1f}" y1="{y1:.1f}" x2="{x2:.1f}" y2="{y2:.1f}" '
                 f'stroke="{GRID}" stroke-width="2"/>')
    # 水平線（外周まで）
    o.append(f'<line x1="{CX-295}" y1="{CY}" x2="{CX+295}" y2="{CY}" stroke="{GRID}" stroke-width="2"/>')

    # ---- 内側円のピザ分割線（各扇形の境界）----
    for _, a1, a2 in SECTORS:
        for a in (a1, a2):
            x2, y2 = pt(196, a)
            o.append(f'<line x1="{CX}" y1="{CY}" x2="{x2:.1f}" y2="{y2:.1f}" '
                     f'stroke="{GRID}" stroke-width="2"/>')

    # ---- 外側リング ----
    # 左：AdS（青→淡青、反時計回り、下端に矢じり）
    o.append(f'<path d="{ring(243, 285, -1, -162)}" fill="url(#gBlue)"/>')
    tip = pt(266, -182)
    b_out = pt(310, -160)
    b_in = pt(222, -160)
    o.append(poly([b_out, tip, b_in], "#e3ecf3"))

    # 右：dS（赤→ベージュ、反時計回り、上端に矢じり）
    o.append(f'<path d="{ring(243, 285, 178, 30)}" fill="url(#gRed)"/>')
    tip = pt(266, 3)
    b_out = pt(310, 30)
    b_in = pt(222, 30)
    o.append(poly([b_out, tip, b_in], "#efd9c0"))

    # ---- 内側リング ----
    o.append(f'<path d="{ring(196, 233, 2, 179)}" fill="{TEAL}"/>')      # 右・外面（青緑）
    o.append(f'<path d="{ring(196, 233, -2, -178)}" fill="{RED}"/>')      # 左・内面（赤）

    # ---- 中央の縦矢印 ----
    o.append(f'<line x1="490" y1="395" x2="490" y2="172" stroke="{RED}" stroke-width="5"/>')
    o.append(poly([(490, 295), (481, 322), (499, 322)], RED))
    o.append(f'<line x1="508" y1="415" x2="508" y2="610" stroke="{TEAL}" stroke-width="4"/>')
    o.append(poly([(508, 508), (499, 482), (517, 482)], TEAL))

####    # ---- 中心：グレーのU字 + 黒点 ----
####    o.append(f'<path d="M472,368 L472,402 A28,28 0 0 0 528,402 L528,368" fill="none" '
####             f'stroke="#c9c9c9" stroke-width="13"/>')
####    o.append(f'<circle cx="{CX}" cy="{CY}" r="14" fill="#111"/>')

    # ---- ラベル ----
    for lab, a1, a2 in SECTORS:
        x, y = pt(LABEL_R, (a1 + a2) / 2)
        o.append(text(round(x), round(y), lab, 30, "#444", "400"))

    o.append(text(143, 400, "Ψ9", 58, PSI9, "800"))
    o.append(text(862, 400, "Ψ10", 58, RED_TXT, "800"))

    o.append("</svg>")
    return "\n".join(o)


def build_html(svg: str) -> str:
    return f"""<!DOCTYPE html>
<html lang="ja">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>CFT空間・AdS空間・dS空間</title>
<style>
  :root {{ --bg:#ffffff; --fg:#222; }}
  @media (prefers-color-scheme: dark) {{ :root {{ --bg:#ffffff; --fg:#222; }} }}
  html, body {{ margin:0; height:100%; background:var(--bg); color:var(--fg); }}
  body {{ display:flex; align-items:center; justify-content:center; }}
  figure {{ margin:0; width:min(96vw, 130vh * 1.333); }}
  svg {{ width:100%; height:auto; display:block; }}
</style>
</head>
<body>
<figure>
{svg}
</figure>
</body>
</html>
"""


def main():
    out = Path(__file__).resolve().parent
    svg = build_svg()
    (out / "../svg/cave_compass.svg").write_text(svg, encoding="utf-8")
    html_path = out / "../html/index.html"
    html_path.write_text(build_html(svg), encoding="utf-8")
    print(f"生成しました: {out/'cave_compass.svg'}\n           {html_path}")
    if "--open" in sys.argv:
        webbrowser.open(html_path.as_uri())


if __name__ == "__main__":
    main()
