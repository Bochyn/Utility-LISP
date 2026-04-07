# Utility-LISP

AutoLISP utilities for AutoCAD, built in daily architectural practice to eliminate repetitive drafting work. 14 commands covering selection, dimensioning, area calculation with live fields, and cleanup.

## Why these exist

Architectural drawings carry thousands of objects, layers, and dimensions. The built-in AutoCAD commands cover the basics, but day-to-day drafting hits the same friction points: selecting "all the texts at this height", chaining dimensions without them drifting, summing polyline areas into a live total. Each tool here was written to remove a specific bottleneck I hit repeatedly while preparing construction documentation.

## Install

1. Clone or download the repo.
2. In AutoCAD, run `APPLOAD` and load any `.lsp` file you want, or
3. Add the path to your `acaddoc.lsp` for auto-loading on startup:

   ```lisp
   (load "C:/path/to/Utility-LISP/selection/SelMasterTool.lsp")
   ```

All commands are entered at the AutoCAD command line.

## Commands

### Selection (`selection/`)

| Command | Alias | Description |
|---------|-------|-------------|
| `SelMasterTool` | — | Multi-step selection workflow: pick objects, filter by layer/color/block, then run an action (isolate, freeze, join, draworder, move, copy, align). One tool replacing a dozen click-paths. |
| `SelByBlockColor` | — | Pick a block, select every block matching its color. Handles indexed (BYLAYER) and RGB color sources. |
| `SelByColor` | — | Same idea, any object type. Resolves BYLAYER to the layer's color before filtering. |
| `SelByLayer` | — | Pick an object, select everything on its layer. |
| `SelByLine` | — | Select all objects matching the picked object's lineweight. Resolves BYLAYER. |
| `SelByLineType` | — | Select all objects matching the picked object's linetype. |
| `SelectBlocksInView` | — | Filter the current selection (or whole drawing) down to block references only. |
| `SelByTextHeight` | `STH` | Pick a text, select every TEXT/MTEXT/ATTDEF/ATTRIB at the same height (0.0001 tolerance). |

### Dimensions (`dimensions/`)

| Command | Description |
|---------|-------------|
| `DimChain` | Aligned dimension followed by automatic `DIMCONTINUE`, then offers to wrap the new dimensions into a block or group. Disassociates dimensions before blocking to fix the bug where blocked associative dimensions drift away from their geometry. Includes a proper `*error*` handler. |
| `ConvertToAligned` | Selects dimension entities and rebuilds non-aligned ones as aligned dimensions, preserving definition points. |
| `PolyDimension` | Auto-dimensions a polyline at every intersection point with selected entities. Sorts intersection points along the polyline using parametric projection, removes duplicates, then chains aligned dimensions between consecutive points. Uses ActiveX/VLA for intersection calculation. |

### Areas (`areas/`)

Both commands insert MTEXT containing a **live AutoCAD FIELD expression** — the displayed area updates automatically when the polyline geometry changes.

| Command | Description |
|---------|-------------|
| `PolyArea` | Pick a closed polyline, place a text label showing its area as a live field. Conversion factor `0.0001` (mm² to m²), 2 decimal places, thousands separator. |
| `SumArea` | Pick multiple closed polylines, place a text label showing the live sum of their areas. Builds a single `AcExpr` field referencing every polyline's `ObjectId`. |

### Cleanup (`cleanup/`)

| Command | Description |
|---------|-------------|
| `OVERKILLBLOCKS` | Removes duplicate block references that share both insertion point and block name. |

### Draw order (`draworder/`)

| Command | Alias | Description |
|---------|-------|-------------|
| `DraworderPlus` | `DOP` | Pre-select friendly draw order with four options: above everything (`F`), below everything (`R`), to front (`G`), to back (`T`). |

## Highlights worth a look

- **`dimensions/PolyDimension.lsp`** — parametric point projection along a polyline, ActiveX intersection, segment-relative sort. The most algorithmically interesting file in the repo.
- **`areas/SumArea.lsp`** — demonstrates AutoCAD `AcExpr` field syntax for live formulas referencing multiple object IDs. A rarely used corner of AutoCAD's field system.
- **`dimensions/DimChain.lsp`** — production-grade error handling and a fix for the bug where blocked associative dimensions drift, resolved with `DIMDISASSOCIATE` before block creation.

## License

MIT. See [LICENSE](./LICENSE).
