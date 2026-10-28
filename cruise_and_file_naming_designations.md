# Cruise and File Naming Designations

The current naming table comes from `cruise_and_file_naming_designations_update_2026.xlsx`.
The old conventions, from `cruise_and_file_naming_designations.xlsx`, are kept at
the bottom of this document under [Old Conventions](#old-conventions-pre-2026).

## Column Definitions

| Column | Description |
|--------|-------------|
| Route | Ship route description |
| HRXBT Website Designation | Line name used on the HRXBT public website |
| SIO Cruise name | Scripps Internal cruise prefix (used as program input) |
| Savu `/data/xbt/` | Folder prefix on Savu server under `/data/xbt/` |
| Savu `/data/xbt/nodc/` | Folder prefix under `/data/xbt/nodc/` |
| Savu `/data1/xbt-archive/` | Folder prefix under `/data1/xbt-archive/` |
| HTML folder (`/argo-project/pub/html/www-hrx/`) | Subfolder name for cruise HTML pages |
| HTML filenames | Filename prefix for cruise HTML files |
| Data folder (`…/pub/www-hrx/`) | Subfolder name for `.10.gz` data files |
| Data filenames | Filename prefix for `.10.gz` data files |
| CSIRO Cruise name | Designation used by CSIRO (where differs) |

---

## Naming Table (2026)

Rows marked **NEW** are marked that way in the 2026 spreadsheet.

| Route | HRXBT Designation | SIO Cruise | Savu `/data/xbt/` | Savu `/data/xbt/nodc/` | Savu `/data1/xbt-archive/` | HTML folder | HTML filenames | Data folder | Data filenames | CSIRO name |
|-------|-------------------|------------|-------------------|------------------------|---------------------------|-------------|----------------|-------------|----------------|------------|
| Punta Arenas / Antarctica | AX22 | p22 | p22 | p22 | p22 | ax22 | a22 | ax22 | a22 | — |
| Mauritius / Fremantle | IX15 | i15 | p15 (i15 alias) | p15 (i15 alias) | i15 | ix15 | i15 | ix15 | i15 | — |
| Mauritius / Durban **NEW** | IX21 | i21 | i21 | i21 | i21 | ix15 | i21 | ix21 | i21 | — |
| Hobart / Antarctica | IX28 | i28 | p28 | p28 | p28 | ix28 | i28 | ix28 | i28 | IX28 |
| Brisbane / Yokohama | PX05 | p05 | p05 | p05 | p05 | px05 | p05 | px05 | p05 | — |
| Suva / Hawaii **NEW** | PX09 | p09 | PX09 (as written; see note) | p09 | p09 | px09 | p09 | px09 | p09 | — |
| Auckland / Suva **NEW** | PX06 | p06 | p06 | p06 | p06 | px09 | p06 | px06 | p06 | — |
| Los Angeles / Auckland **NEW?** | PX13 | p13 | p13 | p13 | p13 | px09 | p13 | px13 | p13 | — |
| Brisbane / Noumea / Lautoka | PX30/31 | p31 | p31 | p31 | p31 | px31 | p31 | px31 | p31 | PX30 |
| Sydney / Wellington | PX34 | p34 | p34 | p34 | p34 | px34 | p34 | px34 | p34 | PX32 |
| San Francisco / Hawaii | PX37 | p37 | p37 | p37 | p37 | px37 | p37 | px37 | p37 | — |
| Los Angeles / Honolulu | PX37-south | s37 | s37 | s37 | s37 | p37s | p37 | p37s | s37 | — |
| Yokohama / Honolulu | PX40 | p40 | p40 | p40 | p40 | px40 | p40 | px40 | p40 | — |

### What changed from the old conventions

| Line | Column | Old | 2026 |
|------|--------|-----|------|
| IX21 | Savu `/data/xbt/` and `/data/xbt/nodc/` | `p21` (i21 alias) | `i21` |
| IX21 | HTML filenames | `i15` | `i21` |
| IX21 | Data folder | `ix15` | `ix21` |
| PX06 | SIO cruise name | `p09` | `p06` |
| PX06 | Savu folders (all three) | `p09` (nodc blank) | `p06` |
| PX06 | HTML filenames | `p09` | `p06` |
| PX06 | Data folder / filenames | `px09` / `p09` | `px06` / `p06` |
| PX09 | Whole row | Note only: "PX09 now represents Auckland/Suva" | Its own route (Suva/Hawaii) under `p09` |
| PX13 | — | — | Marked NEW, but every value matches the old table |

The other eight lines are the same in both tables.

---

## Notes

- **PX06 and PX09 are separate lines again.** The old table folded Auckland/Suva
  (PX06) into `p09`. In 2026, PX06 has its own cruise name `p06`, with `p06`
  folders on Savu, `p06` file names and a `px06` data folder. Its HTML pages
  still go in the `px09` HTML folder. PX09 (`p09`) is now just Suva/Hawaii.
- **Three lines share the `px09` HTML folder.** PX06, PX09 and PX13 pages all go in
  `px09/`, but each has its own data folder (`px06`, `px09`, `px13`) and its own
  file prefix (`p06`, `p09`, `p13`).
- **IX21 still shares the `ix15` HTML folder, but nothing else.** In 2026, IX21
  pages are named `i21YYMM.html` (not `i15`), its data goes in its own `ix21` data
  folder, and its Savu folders are `i21` instead of the `p21` alias.
- **IX15 still uses the `p15` alias on Savu.** `/data/xbt/` and `/data/xbt/nodc/`
  use `p15`, while the archive and the website use `i15`.
- **IX28 input vs. output**: The page generator gets the Savu name `p28` as
  input but writes output named `i28` (the SIO/CSIRO name), plus the leg letter
  (e.g., `i280506a.html`).
- **PX37-south (`s37`)**: HTML files go in the `p37s` folder but are named with the
  `p37` prefix (shared with the full PX37 route). Data files use the `s37` prefix
  in the `p37s` folder.
- **PX09 Savu `/data/xbt/` cell reads `PX09`.** Every other line has a lowercase
  folder prefix there, and PX09's other Savu columns say `p09`. This is probably
  meant to be `p09`. Confirm before acting on it.

---

## Known Conflicts (as of 2026-10-28)

**Repo state:** PR #19 (`cruisehtml-bash`) was merged into main as `490452c`.
`line_2025.sh` now builds cruise pages with `cruisehtml.sh`. `cruisehtml.f` and
`cruisehtml.mk` are still in the repo, but the pipeline no longer calls them.
PR #18 (`bug/fix_cruisehtml`) was closed without merging.

### A. Code vs. the 2026 naming table

The code still follows the old conventions. These all need changing before the
2026 names can be used.

| # | Conflict | 2026 table says | Code does | Location |
|---|----------|-----------------|-----------|----------|
| A1 | IX21 HTML filename | `i21YYMM.html` | Writes `i15YYMM.html`, with previous/next links to `i15` pages | `cruisehtml.sh:90` (page prefix `i15`) |
| A2 | IX21 data folder | `ix21` | Download link points to `ix15/`; `.10.gz` is copied to `ix15` | `cruisehtml.sh:90`, `line_2025.sh:686-688` |
| A3 | IX21 Savu folder | `i21` | Nothing hard-codes `p21`, but `addnew.sh` adds i21 cruises to the `p15.dat` master file | `addnew.sh:79-80` |
| A4 | IX21 xbtinfo | Separate line (own folders and names) | IX21 reads `xbtinfo.p15` (through an `xbtinfo.i21` link), so its previous/next links run through the shared IX15/IX21 list | `cruisehtml.sh:273-281`, `run_image_gen.sh:98-109` |
| A5 | PX06 cruise code `p06` | `p06` everywhere | `cruisehtml.sh` doesn't accept `p06` (not in `SUPPORTED_CODES`), so `line_2025.sh` would report an error and skip the page | `cruisehtml.sh:24`, `cruisehtml.sh:86-101` |
| A6 | PX06 HTML folder | `px09` | `line_2025.sh` has no `06` case, so the page would go to `px06/` (the default `px${line}`) | `line_2025.sh:658-664` |
| A7 | PX06 plots | — | No `06` case in the image section, so it uses the default branch. That branch's `mv p{$line}{$i}t.gif` has literal braces (bash doesn't expand single-item braces), so it never finds the plot | `line_2025.sh:386-390` |
| A8 | PX06 label on `p09` pages | PX06 cruises use `p06` | The `p09` label still adds `PX06` when the track has Auckland/East Cape/Tauranga plus Suva. Under the 2026 names those cruises would be `p06`, so this rule (and PX09/PX39/PX31/PX12/PX18 sharing) needs a decision | `cruisehtml.sh:131-140` |

Items that still match: IX21 HTML folder `ix15` (`line_2025.sh:655-657`, images at
`:244-246`), IX21 data filename `i21`, PX13 pages in `px09/` (`line_2025.sh:661-662`),
and PX06 data in `px06` (the default branch in `line_2025.sh:697-698`).

The Fortran plotting programs `ferstn.f` and `fertem.f` still have old `p06`
branches. Check them against the 2026 PX06 conventions when PX06 is set up.

### B. Status of the earlier `cruisehtml.f` findings (from 2026-06-26)

| # | Issue | Status now |
|---|-------|------------|
| 1 | **IX21 download link wrong**: pointed to `i15YYMM.10.gz` instead of `i21YYMM.10.gz` | **Fixed** in `cruisehtml.f` on main (`8a6ebbf`), and `cruisehtml.sh` gets it right. Under the 2026 table the folder also changes, see A2. |
| 2 | Dead code: `if(outhtml(1:3).eq.'s37')` can never be true | Still in `cruisehtml.f` (PR #18's cleanup wasn't merged). `cruisehtml.sh` has no equivalent. No effect, since `cruisehtml.f` isn't used. |
| 3 | `mid4s37` defined and modified but never written | Same as 2. |
| 4 | Redundant if-else in the `'37'` write block | Same as 2. |
| 5 | `nameit()` for `p37`: `linename(1)` is rdtrack's **PX44** flag but is printed as `PX37` | **Open decision.** `cruisehtml.sh` keeps the old label on purpose so pages stay identical. It affects 77 p37 cruises (9109–1110) whose tracks have Guam plus Taiwan or Hong Kong (e.g. `PX37/PX10/PX37`). PR #18 would have changed them to `PX44`. |
| 6 | `linename` declared with 6 elements, but `rdtrack` writes 7 (found 2026-08-21) | Still in `cruisehtml.f`; no effect, since it isn't used. `cruisehtml.sh` doesn't call `rdtrack`. |
| 7 | rdtrack's **PX13** flag (`linename(7)`) is never shown in the `p09` label (found 2026-08-21) | **Open decision.** Both programs leave it out. It affects p09 cruises 0709a, 0811a and 0901a, which show only `YYMM`. PR #18 would have added `PX13`. |
| 8 | `rdtrack` prints "ALERT ... rewrite rdtrack" for i21 | No effect: `cruisehtml.sh` doesn't use `rdtrack`. |

If 5 or 7 should change, change `track_label` in `cruisehtml.sh` and regenerate
the affected reference pages in `tests/cruisehtml/expected/`.

### C. Lines in the code but not in either naming table

`cruisehtml.sh` supports only the lines in the naming table. The rest of the
pipeline still has branches for these lines. If any of them is processed, the
plots are made but `cruisehtml.sh` stops with "unsupported cruise code" and no
page is written.

| Line | Where it still appears | Status |
|------|------------------------|--------|
| PX08 (`p08`) | `line_2025.sh` image branch; `cruisehtml.f` | Unknown, may be historical |
| PX38 (`p38`) | `line_2025.sh` image branch; `cruisehtml.f` | Unknown, may be historical |
| PX44 (`p44`) | `line_2025.sh` image branch | Unknown, may be historical |
| PX50 (`p50`) | `line_2025.sh` image branch; `cruisehtml.f` | Unknown, may be historical |
| PX81/PX25 (`p81`) | `line_2025.sh` image branch and `mapxbt3.x` case; `cruisehtml.f` | Unknown, may be historical |

---

## Old Conventions (pre-2026)

From `cruise_and_file_naming_designations.xlsx`; the same table is in the
"OLD Conventions" section of the 2026 spreadsheet. This is what the code
follows today.

| Route | HRXBT Designation | SIO Cruise | Savu `/data/xbt/` | Savu `/data/xbt/nodc/` | Savu `/data1/xbt-archive/` | HTML folder | HTML filenames | Data folder | Data filenames | CSIRO name |
|-------|-------------------|------------|-------------------|------------------------|---------------------------|-------------|----------------|-------------|----------------|------------|
| Punta Arenas / Antarctica | AX22 | p22 | p22 | p22 | p22 | ax22 | a22 | ax22 | a22 | — |
| Mauritius / Fremantle | IX15 | i15 | p15 (i15 alias) | p15 (i15 alias) | i15 | ix15 | i15 | ix15 | i15 | — |
| Mauritius / Durban | IX21 | i21 | p21 (i21 alias) | p21 (i21 alias) | i21 | ix15 | i15 | ix15 | **i21** | — |
| Hobart / Antarctica | IX28 | i28 | p28 | p28 | p28 | ix28 | i28 | ix28 | i28 | IX28 |
| Brisbane / Yokohama | PX05 | p05 | p05 | p05 | p05 | px05 | p05 | px05 | p05 | — |
| Auckland / Suva | PX06 | p09 | p09 (p06 folders no longer used) | — | p09 | px09 | p09 | px09 | p09 | — |
| Suva / Hawaii | PX09 | p09 | PX09 now represents Auckland/Suva | — | — | — | — | — | — | — |
| Los Angeles / Auckland | PX13 | p13 | p13 | p13 | p13 | px09 | p13 | px13 | p13 | — |
| Brisbane / Noumea / Lautoka | PX30/31 | p31 | p31 | p31 | p31 | px31 | p31 | px31 | p31 | PX30 |
| Sydney / Wellington | PX34 | p34 | p34 | p34 | p34 | px34 | p34 | px34 | p34 | PX32 |
| San Francisco / Hawaii | PX37 | p37 | p37 | p37 | p37 | px37 | p37 | px37 | p37 | — |
| Los Angeles / Honolulu | PX37-south | s37 | s37 | s37 | s37 | p37s | p37 | p37s | s37 | — |
| Yokohama / Honolulu | PX40 | p40 | p40 | p40 | p40 | px40 | p40 | px40 | p40 | — |

### Notes on the old conventions

- **IX21 shares the IX15 folder**: IX21 HTML files are named with the `i15` prefix
  and stored in the `ix15` HTML folder alongside IX15 files, but the data files use
  the `i21` prefix. These are distinct cruises on the same route segment.
- **PX06 / PX09 merger**: Both Auckland/Suva (PX06) and Suva/Hawaii (PX09) use the
  SIO cruise name `p09`. PX09 represents the Auckland/Suva route; old `p06` folder
  names are no longer used.
- **PX13 HTML folder anomaly**: PX13 HTML files sit under `px09/` (not `px13/`), but
  data files are under `px13/`.
