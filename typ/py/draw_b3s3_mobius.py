#!/usr/init/env python3
"""3次元球体を3次元球面として見るときのイメージ図を PNG で生成するスクリプト。

使い方:
    python draw_sphere_figure.py         # b3s3.png を出力
    python draw_sphere_figure.py out.png    # 出力ファイル名を指定

必要: matplotlib, numpy  (pip install matplotlib numpy)
日本語フォント(Noto Sans CJK JP / Yu Gothic / Meiryo / Hiragino / IPAex など)が
入っていれば自動で使用します。
"""
import sys
import os

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np
from matplotlib import font_manager
from matplotlib.patches import Circle, Ellipse

W, H = 1218, 877  # 画像サイズ(px)。座標系もこのピクセル座標(左上原点)を使う


def setup_japanese_font():
    candidates = [
        "Noto Sans CJK JP", "Noto Sans JP", "Yu Gothic", "YuGothic", "Meiryo",
        "Hiragino Sans", "Hiragino Kaku Gothic ProN", "IPAexGothic", "IPAGothic",
        "TakaoPGothic", "VL Gothic", "MS Gothic", "Source Han Sans JP",
    ]
    installed = {f.name for f in font_manager.fontManager.ttflist}
    for name in candidates:
        if name in installed:
            plt.rcParams["font.family"] = name
            return name
    print("警告: 日本語フォントが見つかりません。文字化けする可能性があります。",
          file=sys.stderr)
    return None


def main(out_path="b3s3.png"):
    setup_japanese_font()
    plt.rcParams["axes.unicode_minus"] = False

    dpi = 100
    fig = plt.figure(figsize=(W / dpi, H / dpi), dpi=dpi, facecolor="white")
    ax = fig.add_axes([0, 0, 1, 1])
    ax.set_xlim(0, W)
    ax.set_ylim(H, 0)  # y 軸を反転(画像座標)
    ax.axis("off")

    # ---------- 中心位置の調整（シフト量） ----------
    # 現在の球の中心 (671, 439) をキャンバスの中央 (W/2 = 609, H/2 = 438.5) に合わせるためのオフセット
    orig_cx, orig_cy = 671, 439
    target_cx, target_cy = W / 2, H / 2
    shift_x = target_cx - orig_cx  # およそ -62
    shift_y = target_cy - orig_cy  # およそ 0

    # ---------- 灰色の球(中心付近に白いグラデーション) ----------
    cx, cy, R = orig_cx + shift_x, orig_cy + shift_y, 263
    glow_x, glow_y, glow_r = 635 + shift_x, 470 + shift_y, 150

    yy, xx = np.mgrid[0:H, 0:W]
    d = np.hypot(xx - glow_x, yy - glow_y) / glow_r
    t = np.clip(d, 0, 1)
    t = t * t * (3 - 2 * t)  # smoothstep
    gray = np.array([0xC6, 0xC6, 0xC6]) / 255.0
    white = np.array([1.0, 1.0, 1.0])
    img = white[None, None, :] * (1 - t[..., None]) + gray[None, None, :] * t[..., None]

    im = ax.imshow(img, extent=[0, W, H, 0], zorder=1, interpolation="bilinear")
    ax.set_xlim(0, W)
    ax.set_ylim(H, 0)
    clip = Circle((cx, cy), R, transform=ax.transData)
    im.set_clip_path(clip)

    # ---------- 2 つの楕円(メビウスの帯のイメージ) ----------
    lw = 2.6
    ecx, ecy = 673 + shift_x, 438 + shift_y
    a_, b_ = 258, 113
    alpha0 = np.deg2rad(6.0)

    def ellipse_pts(u, alpha):
        x = ecx + a_ * np.cos(u) * np.cos(alpha) - b_ * np.sin(u) * np.sin(alpha)
        y = ecy + a_ * np.cos(u) * np.sin(alpha) + b_ * np.sin(u) * np.cos(alpha)
        return x, y

    n = 400
    u_up = np.linspace(2 * np.pi, np.pi, n)   # 上側: 右端 → 左端
    u_lo = np.linspace(np.pi, 0.0, n)          # 下側: 左端 → 右端
    segs = [
        ellipse_pts(u_up, +alpha0),    # E1 上側
        ellipse_pts(u_lo, -alpha0),    # E2 下側
        ellipse_pts(u_up, -alpha0),    # E2 上側
        ellipse_pts(u_lo, +alpha0),    # E1 下側
    ]
    mx = np.concatenate([sg[0] for sg in segs] + [segs[0][0][:1]])
    my = np.concatenate([sg[1] for sg in segs] + [segs[0][1][:1]])
    ax.plot(mx, my, color="black", lw=lw, zorder=3,
            solid_joinstyle="round", solid_capstyle="round")

    # ---------- 矢印(S 側から S* 側へ) ----------
    ax.annotate(
        "", xy=(437 + shift_x, 431 + shift_y), xytext=(908 + shift_x, 435 + shift_y),
        arrowprops=dict(arrowstyle="-|>,head_length=1.1,head_width=0.45",
                        color="black", lw=2.4, shrinkA=0, shrinkB=0),
        zorder=5,
    )

    # ---------- 点 ----------
    ax.plot(680 + shift_x, 435 + shift_y, "o", color="black", ms=5.5, zorder=6)    # O
    ax.plot(908 + shift_x, 435 + shift_y, "o", color="black", ms=5.5, zorder=6)    # 矢印の始点
    ax.plot(403 + shift_x, 440 + shift_y, "o", color="black", ms=5.5, zorder=6)    # S* 側の黒点
    for x, y in [(433, 441), (944, 437)]:               # 白抜きの点
        ax.plot(x + shift_x, y + shift_y, "o", mfc="white", mec="black", mew=1.8, ms=6.5, zorder=6)

    # ---------- ラベル ----------
    ax.text(662 + shift_x, 456 + shift_y, "O", fontsize=20, ha="center", va="center", zorder=7)
    ax.text(371 + shift_x, 438 + shift_y, "S*", fontsize=20, ha="center", va="center", zorder=7)
    ax.text(975 + shift_x, 432 + shift_y, "S", fontsize=20, ha="center", va="center", zorder=7)
    ax.text(320 + shift_x, 473 + shift_y, "(−∞、+∞)", fontsize=23, ha="center", va="center", zorder=7)
    ax.text(1035 + shift_x, 470 + shift_y, "(+∞、−∞)", fontsize=23, ha="center", va="center", zorder=7)

    # ---------- タイトルと注釈 ----------
####    ax.text(48, 70, "どの大円をとっても、一回転捻りのメビウスの帯のようになっています。",
####            fontsize=24, fontweight="bold", ha="left", va="center")
####    ax.text(680, 775, "次元球体を 3 次元球面として見るときのイメージ",
####            fontsize=21, ha="center", va="center")

    # ---------- マージン最小化と保存 ----------
    # bbox_inches="tight" を指定することで、描画要素の周囲の余白を必要最小限にします
    fig.savefig(out_path, dpi=dpi, facecolor="white", bbox_inches="tight", pad_inches=0.05)
    plt.close(fig)
    print(f"保存しました: {out_path}")


if __name__ == "__main__":
    script_dir = os.path.dirname(os.path.abspath(__file__))
    
    if len(sys.argv) > 1:
        arg_path = sys.argv[1]
        out_file = arg_path if os.path.isabs(arg_path) else os.path.join(script_dir, arg_path)
    else:
        out_file = os.path.join(script_dir, "../png/b3s3.png")

    try:
        main(out_file)
    except Exception as e:
        print(f"エラーが発生しました: {e}", file=sys.stderr)
    
    input("\n処理が完了しました。Enterキーを押すと終了します。")