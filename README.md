# GammaFunction

[English](README.md) | [日本語](ja/README.md)

A FireMonkey application that renders the modulus surface $|\Gamma(z)|$ of the complex gamma function as an interactive 3D mesh, backed by a set of gamma-function units (Lanczos approximation and Ooura's gamerf) from the [LUXOPHIA/LUX](https://github.com/LUXOPHIA/LUX) library.

![GammaFunction](--------/GammaFunction.png)

## 利用ライブラリ

* [**LUX**](https://github.com/LUXOPHIA/LUX) ：Foundational mathematics library for the LUXOPHIA projects.
* [**LUX.FMX.Graphics.D3**](https://github.com/LUXOPHIA/LUX.FMX.Graphics.D3) ：Helper classes for FireMonkey 3D scenes (world, camera, light, shaper).

## 1. Overview

- Plots $|\Gamma(z)|$ over the complex domain $[-5,+5]^2$ as a $255 \times 255$ triangle mesh (the grid resolution is chosen so that no grid node lands exactly on a pole).
- Domain coloring: the complex value $\Gamma(z)$ is compressed to the unit disk and used as a texture coordinate into `_DATA/Texture 1024x1024.png`, so hue encodes $\arg\Gamma(z)$ and radius encodes $|\Gamma(z)|$.
- Exact surface normals: every gamma implementation also exists in an automatic-differentiation (`.Diff`) version built on dual numbers, so normals are computed analytically instead of by finite differences.
- Five switchable algorithms: Lanczos approximations with $N = 7, 9, 11, 15$ terms and Ooura's minimax approximation `cdgamma`.
- Library units usable independently of the viewer:

| Unit | Description |
|---|---|
| `LUX.D1.Gamma.Lanczos` (+`.Diff`) | Real $\Gamma$ / $\ln\Gamma$ — Lanczos approximation |
| `LUX.D1.Gamma.Ooura` (+`.Diff`) | Real $\Gamma$ / $\ln\Gamma$ — Ooura's dgamma / dlgamma |
| `LUX.C2.Gamma.Lanczos` (+`.Diff`) | Complex $\Gamma$ / $\mathrm{Ln}\Gamma$ — Lanczos approximation |
| `LUX.C2.Gamma.Ooura` (+`.Diff`) | Complex $\Gamma$ — Ooura's cdgamma |

All implementations were verified against mpmath [7] at 50-digit precision; values and derivatives agree with the theoretical accuracy of each method.

## 2. Mathematical Background

### 2.1. The gamma function

The gamma function extends the factorial to complex arguments:

```math
\Gamma(z) = \int_0^\infty t^{z-1} e^{-t}\,dt , \qquad \mathrm{Re}(z) > 0 , \tag{1}
```

continued analytically to the whole plane except the poles at $z = 0, -1, -2, \dots$

### 2.2. Lanczos approximation

The Lanczos approximation [1] evaluates $\Gamma(z)$ with a single smooth formula:

```math
\Gamma(z) = \sqrt{2\pi} \cdot A(z) \cdot B^{z-\frac{1}{2}} \cdot e^{-B},
\qquad B = z + g - \tfrac{1}{2},
\qquad A(z) = c_0 + \sum_{k=1}^{N-1} \frac{c_k}{z-1+k} . \tag{2}
```

Equation (2) covers $\mathrm{Re}(z) \ge \tfrac{1}{2}$; the rest of the plane is handled by the reflection formula

```math
\Gamma(z)\,\Gamma(1-z) = \frac{\pi}{\sin(\pi z)} . \tag{3}
```

It extends naturally to complex arguments, and $\ln\Gamma$ comes directly from the log form of (2). Accuracy and cost are tunable: the parameter $g$ and the number of terms $N$ form matched sets — more terms, more divisions, more accuracy. The implemented coefficient sets (max relative error measured against mpmath on $[-5,5]^2$, double precision):

| Function | $N$ | $g$ | Max rel. error | Origin |
|---|---|---|---|---|
| `Gamma7` | $7$ | $5$ | $\sim 7\times10^{-11}$ | Numerical Recipes [2] |
| `Gamma9` | $9$ | $7$ | $\sim 2\times10^{-14}$ | Godfrey [3] |
| `Gamma11` | $11$ | $9$ | $\sim 3\times10^{-14}$ | Godfrey [3] |
| `Gamma15` | $15$ | $607/128$ | $\sim 6\times10^{-15}$ | Boost-style [4], near the double-precision limit |

### 2.3. Ooura's gamerf

Minimax-optimized elementary-function approximations by Takuya Ooura (1996) [5][6]. Fixed evaluation cost, no tunable parameters, very fast.

- `dgamma` (real $\Gamma$): a single fixed polynomial around a shifted argument plus a recurrence product; $\sim 10^{-15}$, i.e. the double-precision limit.
- `dlgamma` (real $\ln\Gamma$): four branches — a series near $0$, two mid-range table-based rationals, and Stirling-type asymptotics for $x \ge 8$; $\sim 10^{-14}$. Returns NaN where $\Gamma(x) < 0$.
- `cdgamma` (complex $\Gamma$): one fixed rational approximation evaluated in complex arithmetic, plus reflection (3) for $\mathrm{Re}(z) < 0$; $\sim 10^{-13}$ on $[-5,5]^2$.

Rule of thumb: Ooura gives (near) full double precision at a fixed, minimal cost; Lanczos lets you trade accuracy for speed and yields $\ln\Gamma$ directly.

### 2.4. Surface and domain coloring

Each grid point $z = u + iv$ is lifted to the vertex

```math
\bigl(\, u ,\; |\Gamma(u+iv)| ,\; v \,\bigr) , \tag{4}
```

and the texture coordinate is obtained by compressing $\Gamma(z)$ into the unit disk with the Möbius-style magnitude map

```math
w = \frac{\Gamma(z)}{s + |\Gamma(z)|},
\qquad (t_x, t_y) = \left( \frac{1+\mathrm{Re}\,w}{2},\; \frac{1+\mathrm{Im}\,w}{2} \right),
\qquad s = 2\sqrt{\pi} , \tag{5}
```

which indexes into the domain-coloring texture.

### 2.5. Automatic differentiation with dual numbers

The `.Diff` units evaluate the same formulas over dual numbers, for which

```math
f(a + b\,\varepsilon) = f(a) + f'(a)\, b\,\varepsilon , \qquad \varepsilon^2 = 0 , \tag{6}
```

so each evaluation returns the value and its exact derivative simultaneously. The viewer uses this to build the tangent frame — and hence exact surface normals — at every vertex.

### 2.6. Notes

- Non-positive integers $0, -1, -2, \dots$ are poles; with the default masked-FPU environment the functions return INF/NaN there.
- Complex `LnGamma*` satisfies $\exp(\mathrm{LnGamma}(z)) = \Gamma(z)$ but is not the principal branch: it may differ from the continuous log-gamma (lgamma) by integer multiples of $2\pi i$.
- Real `RLnGamma` returns NaN on the intervals where $\Gamma(x) < 0$ ($-1<x<0$, $-3<x<-2$, …), matching the original dlgamma.

## 3. Architecture

```
・TForm1 (Main.pas)
  ┣・_Gammas :TList<TdDoubleCFunc>        ･･･ Gamma variants (Lanczos, Ooura)
  ┣・ComboBoxA                            ･･･ selects Viewer1.Func
  ┗・TViewerFrame (Viewer.pas)
     ┗・TViewport3D
        ┗・TF3DWorld                      ･･･ (LUX.FMX.Graphics.D3)
           ┣・TF3DCamera                  ･･･ mouse-drag orbit pose
           ┃  ┗・TF3DLight
           ┗・TComplex3D                  ･･･ (LUX.Complex.FMX.D3)
              ┣・Func :TdDoubleCFunc      ･･･ dual-number complex function
              ┣・Area / DivX / DivY / Scale
              ┗・MakeGeometry
                 ┗・TexToMatrix(TexToPos) ･･･ vertices + exact normals

class hierarchy:

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
  ┣・GammaFunction.dpr          ･･･ project file (registers all library units)
  ┣・Main.pas / Main.fmx        ･･･ main form: algorithm list + combo box
  ┣・Viewer.pas / Viewer.fmx    ･･･ TViewerFrame: 3D scene + mouse-orbit camera
  ┣・_DATA/
  ┃  ┗・Texture 1024x1024.png  ･･･ domain-coloring texture (loaded at runtime)
  ┗・_LIBRARY/                  ･･･ git-subtree copies — do not edit here
     ┗・LUXOPHIA/
        ┣・LUX/                 ･･･ https://github.com/LUXOPHIA/LUX
        ┃  ┣・Complex/         ･･･ TDoubleC, TdDoubleC, TComplex3D mesh
        ┃  ┃  ┗・Gamma/       ･･･ LUX.C2.Gamma.{Lanczos,Ooura}[.Diff]
        ┃  ┗・D1/Gamma/        ･･･ LUX.D1.Gamma.{Lanczos,Ooura}[.Diff]
        ┗・LUX.FMX.Graphics.D3/ ･･･ TF3DWorld/TF3DCamera/TF3DLight/TF3DShaper
```

## 4. Usage

| Control | Action |
|---|---|
| `Algorithm` combo box | Switch the evaluation algorithm: Lanczos 7 / 9 / 11 / 15, Ooura |
| Left-drag in the viewport | Orbit the camera (pitch clamped to $\pm 90^\circ$) |

## 5. Building

- RAD Studio (Delphi 13) / FireMonkey.
- Open `GammaFunction.dproj` and build; target platforms: Win32, Win64.
- The texture is loaded at runtime from the relative path `../../_DATA/Texture 1024x1024.png`, so run the executable from its default output directory (e.g. `Win64/Debug/`).

## 6. References

1. C. Lanczos, "[A Precision Approximation of the Gamma Function](https://doi.org/10.1137/0701008)", *SIAM Journal on Numerical Analysis*, Ser. B, 1 (1964), pp. 86–96.
2. W. H. Press, S. A. Teukolsky, W. T. Vetterling, B. P. Flannery, [*Numerical Recipes*](https://numerical.recipes/).
3. P. Godfrey, "[A note on the computation of the convergent Lanczos complex Gamma approximation](https://my.fit.edu/~gabdo/gamma.txt)" (2001).
4. Boost Math Toolkit — "[The Lanczos Approximation](https://www.boost.org/doc/libs/release/libs/math/doc/html/math_toolkit/lanczos.html)".
5. T. Ooura, "[Gamma / Error Functions](https://www.kurims.kyoto-u.ac.jp/~ooura/gamerf.html)" (gamerf), Ooura's Mathematical Software Packages — sources: [gamerf.zip](https://www.kurims.kyoto-u.ac.jp/~ooura/gamerf.zip) (`dgamma.c`, `dlgamma.c`, `cdgamma.c`)
6. T. Ooura, [ガンマ関数および誤差関数の初等関数近似とその最適化](https://www.kurims.kyoto-u.ac.jp/~ooura/papers/jsiam95.pdf) (Elementary-function approximations of the gamma and error functions and their optimization).
7. [mpmath](https://mpmath.org/) — Python library for arbitrary-precision floating-point arithmetic.
8. Wikipedia — "[Gamma function](https://en.wikipedia.org/wiki/Gamma_function)".

## 7. License

- This repository: [MIT License](LICENSE)
- Ooura gamma units (`LUX.*.Gamma.Ooura*`): Copyright (C) 1996 Takuya OOURA — "You may use, copy, modify this code for any purpose and without fee."

## 💖 [Embarcadero](https://www.embarcadero.com/) [**Delphi**](https://www.embarcadero.com/products/delphi)
Integrated Development Environment (IDE) for Creating Native Cross-Platform Apps.
### Free Download: [**Delphi** Community Edition](https://www.embarcadero.com/products/delphi/starter)
