# GammaFunction
Gamma Function in Delphi.

[日本語](ja/README.md)

![](--------/GammaFunction.png)

A FireMonkey sample that renders the $|\Gamma(z)|$ surface of the complex gamma function as a 3D mesh, together with the underlying math library (LUXOPHIA/LUX).

## 🟦 Build

- Delphi 13 / FireMonkey

## 🟦 Usage

- Switch the algorithm (Lanczos 7/9/11/15, Ooura) with the Algorithm combo box
- Drag to rotate the view

## 🟦 Library

| Unit | Description |
|---|---|
| `LUX.D1.Gamma.Lanczos` (+`.Diff`) | Real $\Gamma$ / $\ln\Gamma$ — Lanczos approximation |
| `LUX.D1.Gamma.Ooura` (+`.Diff`) | Real $\Gamma$ / $\ln\Gamma$ — Ooura's dgamma / dlgamma |
| `LUX.C2.Gamma.Lanczos` (+`.Diff`) | Complex $\Gamma$ / $\mathrm{Ln}\,\Gamma$ — Lanczos approximation |
| `LUX.C2.Gamma.Ooura` (+`.Diff`) | Complex $\Gamma$ — Ooura's cdgamma |

The `.Diff` units are automatic-differentiation versions built on dual numbers; the sample uses them to compute exact surface normals.

## 🟦 Algorithms

### 🟨 Lanczos approximation

$$
\Gamma(z) = \sqrt{2\pi}\; A(z)\; B^{\,z-\frac{1}{2}}\; e^{-B},
\qquad B = z + g - \tfrac{1}{2},
\qquad A(z) = c_0 + \sum_{k=1}^{N-1} \frac{c_k}{z-1+k}
$$

- One smooth formula covers $\operatorname{Re} z \ge \tfrac{1}{2}$; the reflection formula $\Gamma(z)\,\Gamma(1-z) = \pi/\sin(\pi z)$ handles the rest of the plane. Extends naturally to complex arguments, and $\ln\Gamma$ comes directly from the log form.
- Accuracy and cost are tunable: the parameter $g$ and the number of terms $N$ form matched sets. More terms, more divisions, more accuracy.
- Implemented coefficient sets (max relative error measured against mpmath on $[-5,5]^2$, double precision):

| Function | $N$ | $g$ | Max rel. error | Origin |
|---|---|---|---|---|
| `Gamma7` | $7$ | $5$ | $\sim 7\times10^{-11}$ | Numerical Recipes |
| `Gamma9` | $9$ | $7$ | $\sim 2\times10^{-14}$ | Godfrey |
| `Gamma11` | $11$ | $9$ | $\sim 3\times10^{-14}$ | Godfrey |
| `Gamma15` | $15$ | $607/128$ | $\sim 6\times10^{-15}$ | Boost-style, near the double-precision limit |

### 🟨 Ooura's gamerf

Minimax-optimized elementary-function approximations by Takuya Ooura (1996). Fixed evaluation cost, no tunable parameters, very fast.

- `dgamma` (real $\Gamma$): a single fixed polynomial around a shifted argument plus a recurrence product; $\sim 10^{-15}$, i.e. the double-precision limit.
- `dlgamma` (real $\ln\Gamma$): four branches — a series near $0$, two mid-range table-based rationals, and Stirling-type asymptotics for $x \ge 8$; $\sim 10^{-14}$. Returns NaN where $\Gamma(x) < 0$.
- `cdgamma` (complex $\Gamma$): one fixed rational approximation evaluated in complex arithmetic, plus reflection for $\operatorname{Re} z < 0$; $\sim 10^{-13}$ on $[-5,5]^2$.

Rule of thumb: Ooura gives (near) full double precision at a fixed, minimal cost; Lanczos lets you trade accuracy for speed and yields $\ln\Gamma$ directly.

## 🟦 Notes

- Non-positive integers $0, -1, -2, \dots$ are poles; with the default masked-FPU environment the functions return INF/NaN there.
- Complex `LnGamma*` satisfies $\exp(\mathrm{LnGamma}(z)) = \Gamma(z)$ but is not the principal branch: it may differ from the continuous log-gamma (lgamma) by integer multiples of $2\pi i$.
- Real `RLnGamma` returns NaN on the intervals where $\Gamma(x) < 0$ ($-1<x<0,\ -3<x<-2,\ \dots$), matching the original dlgamma.

## 🟦 Verification

All implementations were verified against mpmath (50-digit precision); values and derivatives agree with the theoretical accuracy of each method.

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

- This repository: [MIT License](LICENSE)
- Ooura gamma units (`LUX.*.Gamma.Ooura*`): Copyright(C) 1996 Takuya OOURA — "You may use, copy, modify this code for any purpose and without fee."
