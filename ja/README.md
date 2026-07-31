# GammaFunction

[English](../README.md) | [日本語](README.md)

複素ガンマ関数の絶対値曲面 $|\Gamma(z)|$ をインタラクティブな 3D メッシュとして描画する FireMonkey アプリケーション。計算は [LUXOPHIA/LUX](https://github.com/LUXOPHIA/LUX) ライブラリのガンマ関数ユニット群（Lanczos 近似および大浦版 gamerf）が担う。

![GammaFunction](../--------/GammaFunction.png)

## 利用ライブラリ

* [**LUX**](https://github.com/LUXOPHIA/LUX) ：LUXOPHIA プロジェクトの基盤数学ライブラリ。
* [**LUX.FMX.Graphics.D3**](https://github.com/LUXOPHIA/LUX.FMX.Graphics.D3) ：FireMonkey 3D シーンの補助クラス群（ワールド・カメラ・ライト・シェイパ）。

## 1. Overview

- 複素領域 $[-5,+5]^2$ 上の $|\Gamma(z)|$ を $255 \times 255$ の三角形メッシュとして描画（格子点が極を踏まない分割数を選んでいる）。
- ドメインカラーリング: 複素数値 $\Gamma(z)$ を単位円板へ圧縮してテクスチャ座標とし、`_DATA/Texture 1024x1024.png` を参照する。色相が $\arg\Gamma(z)$、半径方向が $|\Gamma(z)|$ に対応。
- 厳密な法線: 各ガンマ実装には双対数 (dual number) による自動微分版 (`.Diff`) があり、法線を差分近似ではなく解析的に計算する。
- 切替可能な 5 アルゴリズム: 項数 $N = 7, 9, 11, 15$ の Lanczos 近似と、大浦版ミニマックス近似 `cdgamma`。
- ビューアとは独立に使えるライブラリユニット:

| ユニット | 内容 |
|---|---|
| `LUX.D1.Gamma.Lanczos` (+`.Diff`) | 実数 $\Gamma$ / $\ln\Gamma$ — Lanczos 近似 |
| `LUX.D1.Gamma.Ooura` (+`.Diff`) | 実数 $\Gamma$ / $\ln\Gamma$ — 大浦版 dgamma / dlgamma |
| `LUX.C2.Gamma.Lanczos` (+`.Diff`) | 複素 $\Gamma$ / $\mathrm{Ln}\Gamma$ — Lanczos 近似 |
| `LUX.C2.Gamma.Ooura` (+`.Diff`) | 複素 $\Gamma$ — 大浦版 cdgamma |

全実装を mpmath [7]（50 桁精度）と突き合わせ、値・導関数とも各手法の理論精度どおりであることを確認済み。

## 2. Mathematical Background

### 2.1. ガンマ関数

ガンマ関数は階乗を複素引数へ拡張したものである:

```math
\Gamma(z) = \int_0^\infty t^{z-1} e^{-t}\,dt , \qquad \mathrm{Re}(z) > 0 , \tag{1}
```

これを解析接続すると、極 $z = 0, -1, -2, \dots$ を除く全平面で定義される。

### 2.2. Lanczos 近似

Lanczos 近似 [1] は単一の滑らかな式で $\Gamma(z)$ を評価する:

```math
\Gamma(z) = \sqrt{2\pi} \cdot A(z) \cdot B^{z-\frac{1}{2}} \cdot e^{-B},
\qquad B = z + g - \tfrac{1}{2},
\qquad A(z) = c_0 + \sum_{k=1}^{N-1} \frac{c_k}{z-1+k} . \tag{2}
```

式 (2) は $\mathrm{Re}(z) \ge \tfrac{1}{2}$ を覆い、残りの領域は反射公式

```math
\Gamma(z)\,\Gamma(1-z) = \frac{\pi}{\sin(\pi z)} \tag{3}
```

で処理する。複素引数へ自然に拡張でき、式 (2) の対数形から $\ln\Gamma$ も直接得られる。精度とコストは調整可能で、パラメータ $g$ と項数 $N$ は対になったセットをなす — 項数を増やすほど除算が増え、精度が上がる。実装済みの係数セット（mpmath との突き合わせによる $[-5,5]^2$ での最大相対誤差、倍精度）:

| 関数 | $N$ | $g$ | 最大相対誤差 | 出自 |
|---|---|---|---|---|
| `Gamma7` | $7$ | $5$ | $\sim 7\times10^{-11}$ | Numerical Recipes [2] |
| `Gamma9` | $9$ | $7$ | $\sim 2\times10^{-14}$ | Godfrey [3] |
| `Gamma11` | $11$ | $9$ | $\sim 3\times10^{-14}$ | Godfrey [3] |
| `Gamma15` | $15$ | $607/128$ | $\sim 6\times10^{-15}$ | Boost 系 [4]。ほぼ倍精度限界 |

### 2.3. 大浦版 gamerf

大浦拓哉 氏 (1996) によるミニマックス最適化された初等関数近似 [5][6]。評価コストは固定で、調整パラメータはなく、非常に高速。

- `dgamma`（実数 $\Gamma$）: シフトした引数まわりの固定多項式 + 漸化式の積。$\sim 10^{-15}$（倍精度限界）。
- `dlgamma`（実数 $\ln\Gamma$）: 4 分岐 — $0$ 近傍の級数、中域のテーブル有理近似 2 種、$x \ge 8$ のスターリング型漸近展開。$\sim 10^{-14}$。$\Gamma(x) < 0$ の区間では NaN。
- `cdgamma`（複素 $\Gamma$）: 複素演算で評価する単一の固定有理近似 + $\mathrm{Re}(z) < 0$ の反射公式 (3)。$[-5,5]^2$ で $\sim 10^{-13}$。

目安: 固定コストでほぼ倍精度が欲しいなら大浦版。$N$ で精度と速度を調整したい、$\ln\Gamma$ を直接使いたいなら Lanczos。

### 2.4. 曲面とドメインカラーリング

各格子点 $z = u + iv$ は頂点

```math
\bigl(\, u ,\; |\Gamma(u+iv)| ,\; v \,\bigr) \tag{4}
```

へ持ち上げられ、テクスチャ座標は $\Gamma(z)$ を絶対値の Möbius 型変換で単位円板へ圧縮して得る:

```math
w = \frac{\Gamma(z)}{s + |\Gamma(z)|},
\qquad (t_x, t_y) = \left( \frac{1+\mathrm{Re}\,w}{2},\; \frac{1+\mathrm{Im}\,w}{2} \right),
\qquad s = 2\sqrt{\pi} , \tag{5}
```

これがドメインカラーリング用テクスチャの参照座標となる。

### 2.5. 双対数による自動微分

`.Diff` 系ユニットは同じ式を双対数上で評価する。双対数では

```math
f(a + b\,\varepsilon) = f(a) + f'(a)\, b\,\varepsilon , \qquad \varepsilon^2 = 0 \tag{6}
```

が成り立つため、一度の評価で値と厳密な導関数が同時に得られる。ビューアはこれを用いて各頂点の接ベクトル系 — すなわち厳密な法線 — を構成する。

### 2.6. Notes

- 非正整数 $0, -1, -2, \dots$ は極。既定の浮動小数点例外マスク環境では INF/NaN を返す。
- 複素 `LnGamma*` は $\exp(\mathrm{LnGamma}(z)) = \Gamma(z)$ を満たすが主枝ではなく、連続な log-gamma (lgamma) と $2\pi i$ の整数倍だけ異なる場合がある。
- 実数 `RLnGamma` は $\Gamma(x) < 0$ となる区間（$-1<x<0$, $-3<x<-2$, …）で NaN を返す（オリジナル dlgamma と同挙動）。

## 3. Architecture

```
・TForm1 (Main.pas)
  ┣・_Gammas :TList<TdDoubleCFunc>        ･･･ Gamma variants (Lanczos, Ooura)
  ┣・ComboBoxA                            ･･･ Viewer1.Func を選択
  ┗・TViewerFrame (Viewer.pas)
     ┗・TViewport3D
        ┗・TF3DWorld                      ･･･ (LUX.FMX.Graphics.D3)
           ┣・TF3DCamera                  ･･･ マウスドラッグで軌道回転
           ┃  ┗・TF3DLight
           ┗・TComplex3D                  ･･･ (LUX.Complex.FMX.D3)
              ┣・Func :TdDoubleCFunc      ･･･ 双対数複素関数
              ┣・Area / DivX / DivY / Scale
              ┗・MakeGeometry
                 ┗・TexToMatrix(TexToPos) ･･･ 頂点 + 厳密な法線

クラス階層:

・TControl3D
  ┗・TF3DObject
     ┣・TF3DWorld
     ┣・TF3DCamera
     ┗・TF3DShaper
        ┗・TComplex3D

・FMX.Controls3D.TLight
  ┗・TF3DLight
```

```
・GammaFunction/
  ┣・GammaFunction.dpr          ･･･ プロジェクト（全ライブラリユニット登録）
  ┣・Main.pas / Main.fmx        ･･･ メインフォーム: アルゴリズムリスト + コンボ
  ┣・Viewer.pas / Viewer.fmx    ･･･ TViewerFrame: 3D シーン + マウス軌道カメラ
  ┣・_DATA/
  ┃  ┗・Texture 1024x1024.png  ･･･ ドメインカラーリング用（実行時読込）
  ┗・_LIBRARY/                  ･･･ git subtree コピー — ここでは編集しない
     ┗・LUXOPHIA/
        ┣・LUX/                 ･･･ https://github.com/LUXOPHIA/LUX
        ┃  ┣・Complex/         ･･･ TDoubleC・TdDoubleC・TComplex3D メッシュ
        ┃  ┃  ┗・Gamma/       ･･･ LUX.C2.Gamma.{Lanczos,Ooura}[.Diff]
        ┃  ┗・D1/Gamma/        ･･･ LUX.D1.Gamma.{Lanczos,Ooura}[.Diff]
        ┗・LUX.FMX.Graphics.D3/ ･･･ TF3DWorld/TF3DCamera/TF3DLight/TF3DShaper
```

## 4. Usage

| 操作 | 動作 |
|---|---|
| `Algorithm` コンボボックス | 計算アルゴリズムの切替: Lanczos 7 / 9 / 11 / 15, Ooura |
| ビューポート内を左ドラッグ | カメラの軌道回転（ピッチは $\pm 90^\circ$ に制限） |

## 5. Building

- RAD Studio (Delphi 13) / FireMonkey。
- `GammaFunction.dproj` を開いてビルド。ターゲットプラットフォーム: Win32, Win64。
- テクスチャは相対パス `../../_DATA/Texture 1024x1024.png` から実行時に読み込むため、既定の出力ディレクトリ（例: `Win64/Debug/`）から実行すること。

## 6. References

1. C. Lanczos, "[A Precision Approximation of the Gamma Function](https://doi.org/10.1137/0701008)", *SIAM Journal on Numerical Analysis*, Ser. B, 1 (1964), pp. 86–96.
2. W. H. Press, S. A. Teukolsky, W. T. Vetterling, B. P. Flannery, [*Numerical Recipes*](https://numerical.recipes/).
3. P. Godfrey, "[A note on the computation of the convergent Lanczos complex Gamma approximation](https://my.fit.edu/~gabdo/gamma.txt)" (2001).
4. Boost Math Toolkit — "[The Lanczos Approximation](https://www.boost.org/doc/libs/release/libs/math/doc/html/math_toolkit/lanczos.html)".
5. 大浦拓哉, "[Gamma / Error Functions](https://www.kurims.kyoto-u.ac.jp/~ooura/gamerf.html)" (gamerf), Ooura's Mathematical Software Packages — ソース: [gamerf.zip](https://www.kurims.kyoto-u.ac.jp/~ooura/gamerf.zip) (`dgamma.c`, `dlgamma.c`, `cdgamma.c`)
6. 大浦拓哉, [ガンマ関数および誤差関数の初等関数近似とその最適化](https://www.kurims.kyoto-u.ac.jp/~ooura/papers/jsiam95.pdf).
7. [mpmath](https://mpmath.org/) — 任意精度浮動小数点演算の Python ライブラリ.
8. Wikipedia — "[ガンマ関数](https://ja.wikipedia.org/wiki/%E3%82%AC%E3%83%B3%E3%83%9E%E9%96%A2%E6%95%B0)".

## 7. License

- 本リポジトリ: [MIT License](../LICENSE)
- 大浦版ガンマ関数ユニット (`LUX.*.Gamma.Ooura*`): Copyright (C) 1996 Takuya OOURA — "You may use, copy, modify this code for any purpose and without fee."

## 💖 [Embarcadero](https://www.embarcadero.com/jp/) [**Delphi**](https://www.embarcadero.com/jp/products/delphi)
ネイティブなクロスプラットフォームアプリを開発するための統合開発環境（ＩＤＥ）。
### Free Download: [**Delphi** Community Edition](https://www.embarcadero.com/jp/products/delphi/starter)
