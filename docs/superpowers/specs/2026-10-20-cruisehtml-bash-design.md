# cruisehtml.sh: bash replacement for cruisehtml.f

Date: 2026-10-20

## Why

`cruisehtml.f` (built as `cruisehtml.x`) writes the HTML page for one XBT
cruise on the HRX website. `line_2025.sh` runs it near the end of processing.

The program starts from sample strings written for AX22 cruise 0506 and
overwrites characters at fixed column positions, for example
`write(middown1(26:28),'(a3)') 'i21'`. Each line's special case is one more
patch at one more column, and there are about ten near-copies of the label
string. That makes it hard to change and easy to get wrong. The IX21 download
link bug (fixed in the Fortran on 2026-10-20) happened because the i21 patch
was added for the image names but not for the download link.

The repo is already moving its scripts to bash (`line2.bat` became
`line_2025.sh`, `addnew` became bash). This continues that.

## Goals

- A bash script, `cruisehtml.sh`, that writes the same page `cruisehtml.x`
  writes, for every supported line.
- All per-line settings in one table in the script, one row per line, so
  adding a line or changing a size is a one-line edit.
- The page layout written once as a template, so small layout changes that
  apply to every page are easy.
- A clear error instead of a broken page. Today, if the xbtinfo file is
  missing or the cruise isn't in it, `cruisehtml.x` writes NUL bytes into the
  previous/next links and carries on.

## Non-goals

- Changing how pages look, the website folder layout, or file naming. Naming
  is documented in `cruise_and_file_naming_designations.md`.
- Changing `rdxbtinfo1.f` (also used by `ferstn.f` and `mapxbt3.f`) or the
  xbtinfo files.
- Fixing other parts of `line_2025.sh`, such as image creation.

## Anti-goals

The work has failed, even if the script runs, if:

- Any content that varies between cruises differs from what `cruisehtml.x`
  writes. That covers the page file name, label, download link,
  previous/next links, image names, image sizes and include file names.
- It writes to, regenerates or otherwise touches existing pages on the website.

## What "exact" means (user's decision)

Pages must match `cruisehtml.x` output byte for byte, with one exception:
small fixes that look the same on every page and don't depend on the cruise
number, the plots, and so on. The user's example: the Next link's broken quote
`<font size=3">` can become `<font size="3">`.

My call: every such fix is listed in the script's header comment and in the
comparison test's list of allowed differences, so it's visible. Keep them few.

## Reference

`cruisehtml.f` and `rdxbtinfo1.f` are the specification. Where this document
and the Fortran disagree, the Fortran's output wins, apart from the allowed
every-page fixes. The current `cruisehtml.f` already includes the IX21
download-link fix, so the reference pages have the correct `i21` link.

## Interface

- Today, `line_2025.sh` pipes the cruise name to `cruisehtml.x` on stdin.
  For IX28 it pipes two lines.
- My call: `cruisehtml.sh` takes the cruise name as one argument, for example
  `cruisehtml.sh i212507`. For IX28 it takes the 8-character name with the
  leg letter, for example `cruisehtml.sh p282402a`.
- It reads `xbtinfo.<first 3 characters of cruise>` from the current
  directory, as today. `run_image_gen.sh` links these into the cruise folder,
  including `xbtinfo.i21`, which links to `xbtinfo.p15`.
- It writes one page into the current directory, with the same file name
  `cruisehtml.x` would use. `line_2025.sh` moves it to the website as it does
  now.
- `line_2025.sh` replaces both `cruisehtml.x` calls with `cruisehtml.sh`.
  My call for IX28: `line_2025.sh` builds the 8-character name from `p28` plus
  the cruise folder name (for example `2402a`). Today the leg letter only
  exists in the folder name: data files in `p28/2402a` are named
  `p282402e.001`.
- Match the style of the existing bash scripts (`line_2025.sh`,
  `extract_prefix.sh`): `#!/bin/bash`, a header comment block, echo progress.

## Reading the xbtinfo file (previous/next cruise and track)

`extract_prefix.sh` gives the cruise name from the data file names, which is
the script's input. It doesn't read the xbtinfo file. The page also needs two
things only the xbtinfo file has:

- the previous and next cruise, for the Previous/Next links
- the track letters, for the p09 and p37 labels

`cruisehtml.x` gets both from `rdxbtinfo1`, and nothing in bash does this yet.
`check_xbtinfo_updated.sh` already scans xbtinfo files with `awk`, so follow
its style. Its scan rule is different, though: it starts after the first
dashed line and stops at the first blank line. To keep the links exact, use
`rdxbtinfo1`'s rules:

- Skip the first 3 lines.
- Columns are fixed: cruise ID in 1-5, track in 25-29, ship in 73-75
  (Fortran format `a5,19x,a5,t73,a3`).
- Skip lines that start with `-----`.
- The match is the first line whose columns 1-4 equal the cruise's YYMM. For
  `p28`, columns 1-5 must equal YYMM plus the leg letter.
- Previous is the last non-`-----` line read before the match. If the match is
  the first cruise line, previous is the cruise itself.
- Next is the next line after the match that isn't `-----`. If that line is
  blank, next is the cruise itself.
- The scan doesn't stop at the end of the cruise table. Some files have notes
  further down whose lines start with a YYMM, but the first match wins.
- No match, or no xbtinfo file: exit with a clear error and write no page.

## Per-line special cases

This list is for orientation and was taken from `cruisehtml.f`. If it
disagrees with the Fortran, the Fortran wins.

| Cruise code | Page file | Label | Notes |
| --- | --- | --- | --- |
| p22 | a22YYMM.html | AX22 YYMM | |
| p15, i15 | i15YYMM.html | IX21/IX15 YYMM | reads xbtinfo.p15 / xbtinfo.i15 |
| i21 | i15YYMM.html | IX21 YYMM | images and download link use `i21YYMM`; data folder `ix15` |
| p28 | i28YYMML.html (L = leg letter) | IX28 YYMML | previous/next links and images use the 5-character YYMML |
| p05 | p05YYMM.html | PX05 YYMM | |
| p09 | p09YYMM.html | built from the track letters | e.g. `PX06/PX31 0508` (rdtrack + nameit) |
| p13 | p13YYMM.html | PX13 YYMM | page goes in the `px09` web folder, data link points to `px13` |
| p31 | p31YYMM.html | PX30/31 YYMM | |
| p34 | p34YYMM.html | PX34 YYMM | |
| p37 | p37YYMM.html | built from the track letters | e.g. `PX37/PX10/PX37 0505` (rdtrack + nameit) |
| s37 | p37YYMM.html | PX37 South YYMM | download link `p37s/s37YYMMa.10.gz` |
| p40 | p40YYMM.html | PX40 YYMM | |

Shared rules, with the exceptions above:

- Include files are `<page prefix>head.html` and `<page prefix>table.html`.
- The download link is `../www-hrx/<folder>/<page name>a.10.gz`. The folder
  is the page prefix's letter, then `x`, then the digits: `ax22`, `ix15`,
  `px40`.
- Images are `img/<page name>s-b.gif`, `s-s`, `t-b` and `t-s`.
- The station map width and height, and the temperature plot height, are set
  per line.
- The left spacer cell is 20 px wide for lines 15, 21, 37, 38 and 40, and
  50 px for the others.
- Labels built by `nameit` (p09, p37, s37) follow `nameit` exactly. They have
  no leading space after `color="red">` when a line name is set, and a single
  leading space with no line name when no line flag is set. Examples:
  p37 1012 gives `" 1012"`, and so do p09 0811, 0901, 0907, 0709 and 1507.
  The fixed labels always have a leading space.
- The p37 label is kept exact, because it's per-cruise content (user's rule).
  That includes the old `PX37/PX10/PX37` labels (cruises 9204, 9904, 0411)
  and cruise 1109's `PX37`, which comes only from rdtrack's PX44 flag,
  `linename(1)`. Every p37 cruise since 2012 has track `HS`, which gives a
  plain `PX37 YYMM`.
- The p28 download link is always `ix28/i28YYMMa.10.gz`, even for a `b` leg
  (checked: cruise `p282402b` links to `i282402a.10.gz`). It looks wrong, but
  it's per-cruise content, so it stays exact.

My call: the script supports only the cruise codes in this table, which are
the lines in `cruise_and_file_naming_designations.md`. The Fortran also handles
`p08`, `p38`, `p50` and `p81`. They aren't in the naming table and have no data
folders, so they are dropped.

## Testing

- The xbtinfo files change whenever a cruise is added. For example, the last
  entry's Next link stops pointing to itself. The workstation and Savu copies
  can also differ. So the saved test can't depend on the live files.
- My call: the repo test uses frozen, trimmed copies of the xbtinfo files as
  its input. Keep only the columns the script reads (1-5, 25-29, 73-75), with
  every other column blanked, so no observer names or other cruise details go
  into a repo that has a GitHub remote. Keep the line structure as it is:
  headers, `-----` lines, blank lines and notes.
- My call: generate the reference pages once, from those frozen copies, with
  the current `cruisehtml.x`, and commit both the copies and the pages. The
  check then still works after the Fortran is retired, on either machine.
- A comparison script, kept in the repo, runs `cruisehtml.sh` against the
  frozen inputs and compares the output with the reference pages. Only the
  listed every-page fixes may differ. While `cruisehtml.x` still exists, it
  can also compare both programs against the live xbtinfo files, given their
  location as an argument: `/home/jbrzensk/XBT` on the workstation,
  `/data/xbt` on Savu.
- IX28 reference pages come from giving `cruisehtml.x` its two inputs
  directly, `p28YYMM` then `p28YYMML`. Don't take them from today's
  `line_2025.sh`, which sends `p28YYMM` twice. That produces a page named
  `i28YYMM .html`, with NUL bytes in the links.
- Choose real cruises from each xbtinfo file:
  - the first entry (previous is the cruise itself)
  - the last entry (next is the cruise itself)
  - a middle entry
  - for i21, i15 and p15 cruises, all three codes
  - for p09 and p37, cruises with different track letters, to cover the
    label combinations
  - for p28, both an `a` leg and a `b` leg
- Also check the failure cases: missing xbtinfo file, and a cruise that isn't
  in the file.

## Retiring the Fortran

My call: keep `cruisehtml.f` and `cruisehtml.mk` in the repo until
`cruisehtml.sh` has been used on a few real cruises, then remove them in a
separate change. The user decides when.

## Left to the builder

- Script structure, the template mechanism and the settings table format.
- Porting the rdtrack/nameit label logic for p09 and p37.
- The list of every-page fixes, kept short and documented.
- Where the comparison script and reference pages live.
- What to do if the matched cruise is the last line of the file. The Fortran
  leaves next unset in that case.

## Settled after review

- **i21 xbtinfo.** The user said `xbtinfo.i21` should exist as a link to
  `xbtinfo.p15`, so the script has no fallback. My call: if it's missing, the
  error message says to create the link (`ln -s xbtinfo.p15 xbtinfo.i21` next
  to `xbtinfo.p15`).
- **Fortran limits and quirks are kept.** These include the 300-line scan
  limit, `xbtinfo.p37` having only 2 header lines (so its first cruise, 9109,
  is skipped), padded sizes like `width=" 95"`, and trailing spaces. The
  300-line limit only cuts off notes at the bottom of `xbtinfo.p09`; every
  cruise there is above line 300.
- **IX28 in `line_2025.sh`.** Passing `p28` plus the folder name (see
  Interface) also fixes today's IX28 page, which `line_2025.sh` currently
  names `i28YYMM .html`, with broken links.
