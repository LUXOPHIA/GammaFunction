# GammaFunction
Gamma Function in Delphi.

[English](../README.md)

![](../--------/GammaFunction.png)

複素ガンマ関数の $|\Gamma(z)|$ 曲面を FireMonkey の 3D メッシュとして描画するサンプルと、その計算ライブラリ (LUXOPHIA/LUX)。

## 🟦 Build

- Delphi 13 / FireMonkey

## 🟦 Usage

- Algorithm コンボボックスで計算アルゴリズムを切替 (Lanczos 7/9/11/15, Ooura)
- ドラッグで視点を回転

## 🟦 Library

| ユニット | 内容 |
|---|---|
| `LUX.D1.Gamma.Lanczos` (+`.Diff`) | 実数 $\Gamma$ / $\ln\Gamma$ — Lanczos 近似 |
| `LUX.D1.Gamma.Ooura` (+`.Diff`) | 実数 $\Gamma$ / $\ln\Gamma$ — 大浦版 dgamma / dlgamma |
| `LUX.C2.Gamma.Lanczos` (+`.Diff`) | 複素 $\Gamma$ / $\mathrm{Ln}\Gamma$ — Lanczos 近似 |
| `LUX.C2.Gamma.Ooura` (+`.Diff`) | 複素 $\Gamma$ — 大浦版 cdgamma |

`.Diff` 系は双対数 (dual number) による自動微分対応版。サンプルでは曲面の法線を解析的に求めるために使用。

## 🟦 Algorithms

### 🟨 Lanczos 近似

```math
\Gamma(z) = \sqrt{2\pi} \cdot A(z) \cdot B^{z-\frac{1}{2}} \cdot e^{-B},
\qquad B = z + g - \tfrac{1}{2},
\qquad A(z) = c_0 + \sum_{k=1}^{N-1} \frac{c_k}{z-1+k}
```

- 一つの滑らかな式で $\mathrm{Re}(z) \ge \tfrac{1}{2}$ を覆い、残りは反射公式 $\Gamma(z) \Gamma(1-z) = \pi / \sin(\pi z)$ で処理する。複素引数へ自然に拡張でき、対数形なので $\ln\Gamma$ も直接得られる。
- パラメータ $g$ と項数 $N$ の組で精度とコストを調整できる。項数を増やすほど除算が増え、精度が上がる。
- 実装済みの係数セット (mpmath との突き合わせによる $[-5,5]^2$ での最大相対誤差、倍精度):

| 関数 | $N$ | $g$ | 最大相対誤差 | 出自 |
|---|---|---|---|---|
| `Gamma7` | $7$ | $5$ | $\sim 7\times10^{-11}$ | Numerical Recipes |
| `Gamma9` | $9$ | $7$ | $\sim 2\times10^{-14}$ | Godfrey |
| `Gamma11` | $11$ | $9$ | $\sim 3\times10^{-14}$ | Godfrey |
| `Gamma15` | $15$ | $607/128$ | $\sim 6\times10^{-15}$ | Boost 系。ほぼ倍精度限界 |

### 🟨 大浦版 gamerf

大浦拓哉 氏 (1996) によるミニマックス最適化された初等関数近似。評価コストは固定で、調整パラメータはなく、非常に高速。

- `dgamma` (実数 $\Gamma$): シフトした引数まわりの固定多項式 + 漸化式の積。$\sim 10^{-15}$ (倍精度限界)。
- `dlgamma` (実数 $\ln\Gamma$): 4分岐 — $0$ 近傍の級数、中域のテーブル有理近似2種、$x \ge 8$ のスターリング型漸近展開。$\sim 10^{-14}$。$\Gamma(x) < 0$ の区間では NaN。
- `cdgamma` (複素 $\Gamma$): 複素演算で評価する単一の固定有理近似 + $\mathrm{Re}(z) < 0$ の反射公式。$[-5,5]^2$ で $\sim 10^{-13}$。

目安: 固定コストでほぼ倍精度が欲しいなら大浦版。$N$ で精度と速度を調整したい、$\ln\Gamma$ を直接使いたいなら Lanczos。

## 🟦 Notes

- 非正整数 $0, -1, -2, \dots$ は極。既定の浮動小数点例外マスク環境では INF/NaN を返す。
- 複素 `LnGamma*` は $\exp(\mathrm{LnGamma}(z)) = \Gamma(z)$ を満たすが主枝ではなく、連続な log-gamma (lgamma) と $2\pi i$ の整数倍だけ異なる場合がある。
- 実数 `RLnGamma` は $\Gamma(x) < 0$ となる区間 ($-1<x<0$, $-3<x<-2$, …) で NaN を返す (オリジナル dlgamma と同挙動)。

## 🟦 Verification

全実装を mpmath (50桁精度) と突き合わせ、値・導関数とも各手法の理論精度どおりであることを確認済み。

## 🟥 Reference

### 🟩 [Ooura's Mathematical Software Packages](https://www.kurims.kyoto-u.ac.jp/~ooura/)
- [Special Functions - Gamma / Error Functions](https://www.kurims.kyoto-u.ac.jp/~ooura/gamerf.html)
  - [gamerf.zip](https://www.kurims.kyoto-u.ac.jp/~ooura/gamerf.zip)
    - `cdgamma.c` :Complex Gamma Function in C
    - `dgamma.c` :Gamma Function in C
    - `dlgamma.c` :Log Gamma Function in C
- ガンマ関数および誤差関数の初等関数近似とその最適化
  - [jsiam95.pdf](https://www.kurims.kyoto-u.ac.jp/~ooura/papers/jsiam95.pdf)

## 🟥 License

- 本リポジトリ: [MIT License](../LICENSE)
- 大浦版ガンマ関数 (`LUX.*.Gamma.Ooura*`): Copyright(C) 1996 Takuya OOURA — "You may use, copy, modify this code for any purpose and without fee."
