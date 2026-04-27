# Drone Fleet Dashboard — IEEE Conference Paper

LaTeX source for the IEEE conference paper describing this project.

## Before compiling

Capture 6 screenshots from the running Flutter app (`flutter run -d chrome --web-port 8080`) and save them as PNGs in `figures/`:

| File                       | Screen                                                                 |
|----------------------------|------------------------------------------------------------------------|
| `figures/dashboard.png`    | Dashboard tab (fleet grid + counters)                                  |
| `figures/map.png`          | Map tab (OSM + markers, ideally with one drone selected)               |
| `figures/drone_detail.png` | Any drone's detail screen (telemetry chips + mission timeline)         |
| `figures/mission_picker.png` | Mission-status bottom sheet (tap edit icon next to Mission Timeline) |
| `figures/alerts.png`       | Alerts tab (let Gamma-03 drain < 20 % first if list is empty)          |
| `figures/analytics.png`    | Analytics tab (bar chart + line chart + composition)                   |

Phone-shaped screenshots: in Chrome press `F12` → `Ctrl+Shift+M` → pick Pixel 7 / iPhone 14 Pro → DevTools three-dot menu → **Capture screenshot**.

## Author details

Replace the placeholder author block near the top of `main.tex`:

```latex
\author{\IEEEauthorblockN{Author Name} ...}
```

## Compile locally

```bash
pdflatex main.tex
bibtex   main
pdflatex main.tex
pdflatex main.tex
```

Produces `main.pdf`.

## Compile on Overleaf (recommended)

1. Create a new project → Upload Project → zip this `paper/` folder.
2. Set the compiler to **pdfLaTeX** and main document to `main.tex`.
3. Recompile — `IEEEtran.cls` is already installed on Overleaf.
