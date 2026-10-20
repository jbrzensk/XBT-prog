# cruisehtml.sh Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace `cruisehtml.f` / `cruisehtml.x` with a bash script, `cruisehtml.sh`, that writes byte-identical cruise pages, then switch `line_2025.sh` over to it.

**Architecture:** `cruisehtml.sh` is a single sourceable bash script. It has:
- one `case` table of per-line settings
- an `awk` reader that copies `rdxbtinfo1`'s previous/next/track rules
- a label builder that ports `rdtrack` and `nameit` for p09/p37/s37
- one heredoc page template

It's tested against reference pages that the current `cruisehtml.x` generated from frozen, trimmed copies of the xbtinfo files. While the Fortran still exists, a live check also compares the two programs over every cruise in the live xbtinfo files.

**Tech Stack:** bash and POSIX awk (gawk on the workstation; Savu's awk is unknown). No other dependencies.

**Spec:** `docs/superpowers/specs/2026-10-20-cruisehtml-bash-design.md`

## Global Constraints

- Supported cruise codes: `p22 p15 i15 i21 p28 p05 p09 p13 p31 p34 p37 s37 p40`. Any other code is an error.
- Pages must be byte-identical to the reference output, with exactly one allowed every-page fix: the Next link's `<font size=3">` becomes `<font size="3">`. List it in `cruisehtml.sh`'s header comment.
- Do not modify `cruisehtml.f`, `rdxbtinfo1.f`, any live xbtinfo file, or anything under the website directory (`/argo-project/...`, `/home/jbrzensk/argo-project/...`).
- Run awk with `LC_ALL=C` for byte columns. Use POSIX awk only: no `gensub`, and no `{n}` regex intervals (write `[0-9][0-9][0-9][0-9]`).
- Script style follows `extract_prefix.sh`: `#!/bin/bash` and a header comment block with usage. Errors go to stderr, and the exit status is 1.
- `cruisehtml.sh` must be executable (`chmod +x`) and live in the repo root, next to `cruisehtml.x`, so it's on the same PATH.
- Reference pages depend on the IX21 download-link fix in `cruisehtml.f` (applied 2026-10-20, uncommitted at plan time). `grep -n "middown1(26:28)" cruisehtml.f` must find it, and `cruisehtml.x` must have been rebuilt (`make -f cruisehtml.mk`) before Task 1. `cruisehtml.x` is gitignored, so it isn't in the repo.
- End commit messages with `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`.

## Review Focus

1. **Two legs that share a YYMM** (`xbtinfo.p09` has `8608b` then `8608a`). The first match wins, and Next is `8608a`, so the link points back to `p098608.html`. Pinned by case `p098608` (Task 1).
2. **The new cruise is the last line of the file** (a cruise was just appended, with no blank line after). The Fortran wrote NUL bytes; the script must make Next point to the cruise itself. Pinned by the `eof_next_self` unit test (Task 2).
3. **CRLF line endings** in an xbtinfo file edited on Windows (the data area has a `Win2K` folder). It must read exactly like the LF version. Pinned by the `crlf_same_as_lf` unit test (Task 2).
4. **Run via PATH from a cruise folder whose xbtinfo is a two-level symlink** (`xbtinfo.i21` → `../../xbtinfo.i21` → `xbtinfo.p15`). The script must read from the current directory and follow the links. Pinned by `test_pages.sh`, which links fixtures through a symlink chain (Task 1).
5. **`cruisehtml.sh` fails inside `line_2025.sh`** (cruise missing from xbtinfo). No `.html` file gets moved to the website, a clear message is printed, and the data-file copy still runs. Pinned by the Task 6 verification step.

---

### Task 1: Frozen test inputs, reference pages, and page test

**Files:**
- Create: `tests/cruisehtml/make_fixtures.sh`
- Create: `tests/cruisehtml/cases.txt`
- Create (generated): `tests/cruisehtml/xbtinfo/xbtinfo.<code>`
- Create (generated): `tests/cruisehtml/expected/<case>/<page>.html`
- Create: `tests/cruisehtml/test_pages.sh`

**Interfaces:**
- Produces:
  - `tests/cruisehtml/test_pages.sh [code ...]`: runs `cruisehtml.sh` for every case in `cases.txt` (or only the cases whose first 3 characters are in the given codes). Prints `PASS <case>` or `FAIL <case>: <reason>` and a diff, then a summary. Exits 1 if any case failed.
  - Fixture layout used by every later task:
    - `tests/cruisehtml/xbtinfo/xbtinfo.<code>`
    - `xbtinfo.i15` and `xbtinfo.i21` are symlinks to `xbtinfo.p15`
    - `tests/cruisehtml/expected/<case>/<page file>`

- [ ] **Step 1: Write `cases.txt`.** One cruise argument per line, as `cruisehtml.sh` will take it:

```text
p229609
p220712
p222404
p159409
p152507
p152604
i152509
i212507
i212509
i212604
p289312a
p282402a
p282402b
p050908
p051810
p052002
p131903
p131507
p132509
p319105
p310704
p312406
p349101
p340609
p342408
p401211
p402206
p402588
p098603
p092508
p098608
p090106
p091407
p090709
p099309
p091412
p090003
p099806
p091409
p092201
p379204
p371012
p371109
p370503
p372305
s370811
s372111
s372410
```

These cover:
- first, middle and last entries of each line (first: previous is itself; last: next is itself)
- every p09 and p37 label variant found in the 1,302 live cruises
- p28 `a` and `b` legs
- `2201`, a 4-character match on the 5-character ID `2201a`
- the `8608b`/`8608a` leg pair

- [ ] **Step 2: Write `make_fixtures.sh <live xbtinfo dir>`**, for example `make_fixtures.sh /home/jbrzensk/XBT`. It does three things:
  1. **Trims** `xbtinfo.<code>` for `p22 p15 p28 p05 p09 p13 p31 p34 p37 s37 p40` into `tests/cruisehtml/xbtinfo/`, then creates the `xbtinfo.i15` and `xbtinfo.i21` symlinks to `xbtinfo.p15`. Each trimmed line is:
     - columns 1-5
     - 19 spaces
     - columns 25-29
     - 43 spaces
     - columns 73-75

     Trailing spaces are stripped, and every line is kept, including headers, `-----` lines, blank lines and notes.
  2. **Generates the reference pages.** For each case, it runs the repo's `cruisehtml.x` in a fresh `mktemp -d` folder with the trimmed xbtinfo files symlinked in, and saves the page as `expected/<case>/<page file>`. For p28 cases it feeds two lines, `p28YYMM` then `p28YYMML`. All other cases get one line: the case.
  3. **Self-checks.** It also runs each case against the live files and fails (exit 1) unless the live page is byte-identical to the trimmed-input page. Any page containing a NUL byte (`grep -qaP '\x00'`) is also an error.

- [ ] **Step 3: Run it and confirm the fixtures.**

Run: `tests/cruisehtml/make_fixtures.sh /home/jbrzensk/XBT && ls tests/cruisehtml/expected | wc -l`
Expected: no errors, and `48`.

Run: `grep -a -h 'color="red">' tests/cruisehtml/expected/p090709/*.html tests/cruisehtml/expected/p371012/*.html tests/cruisehtml/expected/i212507/*.html`
Expected: the labels ` 0709`, ` 1012` and ` IX21 2507`.

Run: `LC_ALL=C awk 'length($0)>75 || substr($0,6,19) ~ /[^ ]/ || substr($0,30,43) ~ /[^ ]/' tests/cruisehtml/xbtinfo/xbtinfo.[ps]* | wc -l`
Expected: `0`. Nothing survives outside columns 1-5, 25-29 and 73-75, so no observer names.

- [ ] **Step 4: Write `test_pages.sh`.** For each selected case:
  1. Make a fresh `mktemp -d` folder `W`.
  2. For every fixture file, create `W/links/xbtinfo.<code>` → the fixture's absolute path, and `W/run/xbtinfo.<code>` → `../links/xbtinfo.<code>`. The fixture `xbtinfo.i21` is itself a link to `xbtinfo.p15`, so i21 is read through three links, like a real cruise folder (Review Focus 4).
  3. Run `"$REPO/cruisehtml.sh" "$case"` from `W/run`.
  4. Pass only if the exit status is 0, exactly one `.html` file exists, its name equals the expected file name, and its bytes equal the expected page after `sed 's/<font size=3">/<font size="3">/'`.

`REPO` is `$(cd "$(dirname "$0")/../.." && pwd)`.

- [ ] **Step 5: Run it and confirm it fails because the script doesn't exist yet.**

Run: `tests/cruisehtml/test_pages.sh p40`
Expected: `FAIL p401211: ...` for all three p40 cases, and exit status 1.

- [ ] **Step 6: Commit.**

```bash
git add tests/cruisehtml
git commit -m "Add cruisehtml page fixtures and comparison test"
```

---

### Task 2: Argument handling, xbtinfo reader, and errors

**Files:**
- Create: `cruisehtml.sh`
- Create: `tests/cruisehtml/test_functions.sh`
- Create: `tests/cruisehtml/test_cli_errors.sh`

**Interfaces:**
- Produces:
  - `cruisehtml.sh <cruise>`. The argument is 7 characters (`[psi][0-9][0-9]YYMM`) or, for p28, 8 characters (`p28YYMML`, where L is a lowercase leg letter). The code is the first 3 characters.
    - On success it writes one page in the current directory, prints `Wrote <file>`, and exits 0.
    - On error it prints a message to stderr, writes no file, and exits 1.
  - The script is sourceable. `main "$@"` runs only when `[[ "${BASH_SOURCE[0]}" == "$0" ]]`.
  - `read_xbtinfo FILE ID` prints one line, `PREV|NEXT|TRACK`, and returns 0. It returns 1 and prints nothing when the cruise isn't found. ID is 4 characters (YYMM), or 5 for p28 (YYMML).
    - PREV and NEXT are columns 1-5 of the chosen lines.
    - TRACK is columns 25-29 of the match.
    - Each field is right-padded with spaces to 5 characters.

- [ ] **Step 1: Write `test_functions.sh`.** It sources `cruisehtml.sh` and uses `check NAME EXPECTED ACTUAL`, which prints `ok`/`FAIL` and counts failures; the script exits 1 on any failure. Synthetic files are built with `row() { printf '%-24s%s\n' "$1" "$2"; }` (ID, then track at column 25), after 3 header lines. Assertions:

```bash
# file A: header x3, 0101 SA, -----, 0102 SH, 0103 AS, (blank), notes "0102 later"
check first_prev_self     "0101 |0102 |SA   " "$(read_xbtinfo A 0101)"
check dash_skipped        "0101 |0103 |SH   " "$(read_xbtinfo A 0102)"
check blank_next_self     "0102 |0103 |AS   " "$(read_xbtinfo A 0103)"
check first_match_wins    "0101 |0103 |SH   " "$(read_xbtinfo A 0102)"
check not_found_status    1                   "$(read_xbtinfo A 9999 >/dev/null; echo $?)"
check not_found_silent    ""                  "$(read_xbtinfo A 9999)"
# file B: header x3, 2402a D - H, 2402b H - D   (no trailing blank line; last line ends with \n)
check p28_leg_match       "2402a|2402b|H - D" "$(read_xbtinfo B 2402b)"
check eof_next_self       "2402a|2402b|H - D" "$(read_xbtinfo B 2402b)"
# file C: header x3, 2107 SA, 2201a SA, 2209 SA
check four_char_on_leg_id "2107 |2209 |SA   " "$(read_xbtinfo C 2201)"
# file D: header x3, then 299 filler rows 0001..0299, then 0300 at line 303, 0301 at line 304
check scan_line_303_found "0299 |0301 |SA   " "$(read_xbtinfo D 0300)"
check scan_line_304_absent 1                  "$(read_xbtinfo D 0301 >/dev/null; echo $?)"
# file E: file A converted with sed 's/$/\r/'
check crlf_same_as_lf     "$(read_xbtinfo A 0103)" "$(read_xbtinfo E 0103)"
```

In file D, every filler row has track `SA`. Some pairs of checks use the same call on purpose, each pinning a different rule:
- `dash_skipped` and `first_match_wins` (file A)
- `p28_leg_match` and `eof_next_self` (file B)

- [ ] **Step 2: Write `test_cli_errors.sh`.** Each case runs in a fresh `mktemp -d` folder and asserts exit status 1, no `*.html` file, and a stderr substring:

| Setup | Command | stderr contains |
| --- | --- | --- |
| no args | `cruisehtml.sh` | `Usage` |
| | `cruisehtml.sh p40` | `Usage` |
| | `cruisehtml.sh p812401` | `unsupported` |
| | `cruisehtml.sh p282402` | `leg letter` |
| empty folder | `cruisehtml.sh p402206` | `xbtinfo.p40` |
| empty folder | `cruisehtml.sh i212507` | `ln -s xbtinfo.p15 xbtinfo.i21` |
| fixture `xbtinfo.p40` linked | `cruisehtml.sh p409999` | `9999` |

- [ ] **Step 3: Run both tests and confirm they fail.**

Run: `tests/cruisehtml/test_functions.sh; tests/cruisehtml/test_cli_errors.sh`
Expected: FAIL on every check, because `cruisehtml.sh` doesn't exist.

- [ ] **Step 4: Implement `cruisehtml.sh`** with:
  - the header comment, which lists the one allowed every-page fix
  - argument validation
  - `read_xbtinfo`
  - a `main` that validates the argument and xbtinfo, calls `read_xbtinfo`, and on success (for now) stops with `not implemented` and exit 1

`read_xbtinfo` rules. These copy `rdxbtinfo1.f:40-100`, plus two decisions of ours: EOF means Next is the cruise itself, and CR characters are stripped.
- Strip a trailing `\r` from every line.
- Ignore file lines 1-3. Match only within file lines 4-303 (the Fortran's 300-read loop).
- A line whose first 5 characters are `-----` is skipped entirely: it isn't a match, and it doesn't count for previous or next.
- Match: the first scanned line whose first `length(ID)` characters equal ID.
- PREV: columns 1-5 of the last non-dash scanned line before the match. If the match is the first non-dash scanned line, PREV is the match's own columns 1-5. Blank and note lines count as previous lines; that's Fortran behavior.
- NEXT: columns 1-5 of the first line after the match (no line limit) that isn't a dash line. If its first 4 characters are spaces, or the file ends first, NEXT is the match's columns 1-5.

- [ ] **Step 5: Run both tests and confirm they pass.**

Run: `tests/cruisehtml/test_functions.sh && tests/cruisehtml/test_cli_errors.sh`
Expected: every check `ok`, exit 0.

- [ ] **Step 6: Commit.**

```bash
git add cruisehtml.sh tests/cruisehtml/test_functions.sh tests/cruisehtml/test_cli_errors.sh
git commit -m "Add cruisehtml.sh argument checks and xbtinfo reader"
```

---

### Task 3: Line settings and page template (fixed-label lines)

**Files:**
- Modify: `cruisehtml.sh`

**Interfaces:**
- Consumes: `read_xbtinfo` (Task 2); `test_pages.sh` (Task 1).
- Produces:
  - `line_settings CODE` sets these globals and returns 1 for an unsupported code: `PAGE_PREFIX IMG_PREFIX DATA_FOLDER DATA_PREFIX FIXED_LABEL STN_W STN_H TEM_H SPACER`. `FIXED_LABEL` is empty for p09, p37 and s37.
  - `write_page FILE LABEL PREV_ID NEXT_ID` writes the page using those globals plus `ID` and `YYMM`.

- [ ] **Step 1: Run the page test for the fixed-label lines and confirm it fails.**

Run: `tests/cruisehtml/test_pages.sh p22 p15 i15 i21 p28 p05 p13 p31 p34 p40`
Expected: every case `FAIL ... not implemented`.

- [ ] **Step 2: Implement `line_settings`** as one `case` row per code. Values are taken from `cruisehtml.x` output. Sizes are exact strings, including the leading-space padding:

| Code | PAGE_PREFIX | IMG_PREFIX | DATA_FOLDER | DATA_PREFIX | FIXED_LABEL | STN_W | STN_H | TEM_H | SPACER |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| p22 | a22 | a22 | ax22 | a22 | AX22 | `155` | `152` | 244 | 50 |
| p15, i15 | i15 | i15 | ix15 | i15 | IX21/IX15 | `300` | `152` | 250 | 20 |
| i21 | i15 | i21 | ix15 | i21 | IX21 | `200` | `113` | 250 | 20 |
| p28 | i28 | i28 | ix28 | i28 | IX28 | `␣90` | `155` | 250 | 50 |
| p05 | p05 | p05 | px05 | p05 | PX05 | `␣78` | `152` | 250 | 50 |
| p09 | p09 | p09 | px09 | p09 | (empty) | `␣95` | `152` | 251 | 50 |
| p13 | p13 | p13 | px13 | p13 | PX13 | `␣95` | `152` | 251 | 50 |
| p31 | p31 | p31 | px31 | p31 | PX30/31 | `225` | `103` | 250 | 50 |
| p34 | p34 | p34 | px34 | p34 | PX34 | `240` | `␣87` | 250 | 50 |
| p37 | p37 | p37 | px37 | p37 | (empty) | `187` | `115` | 252 | 20 |
| s37 | p37 | p37 | p37s | s37 | (empty) | `325` | `114` | 250 | 20 |
| p40 | p40 | p40 | px40 | p40 | PX40 | `325` | `142` | 244 | 20 |

`␣` is a single space, so `␣90` is `" 90"`.

- [ ] **Step 3: Implement `write_page`** as an unquoted `cat <<EOF` heredoc (not `<<-`). Copy it verbatim from `tests/cruisehtml/expected/p402206/p402206.html`, keeping every trailing space. Line 13 is two spaces; lines 15 and 23 end in one space. Then substitute only these lines (line numbers are from that file):

| Line | Value |
| --- | --- |
| 10 | `${PAGE_PREFIX}head.html` |
| 28 | `<td width="${SPACER}">` |
| 30 | `<font size="4" color="red">${LABEL}</font></td>` |
| 35 | `../www-hrx/${DATA_FOLDER}/${DATA_PREFIX}${YYMM}a.10.gz` |
| 42 | `${PAGE_PREFIX}${PREV_ID}.html` |
| 47 | `${PAGE_PREFIX}${NEXT_ID}.html`, with the allowed fix `<font size="3">` |
| 57 | `img/${IMG_PREFIX}${ID}s-b.gif` and `img/${IMG_PREFIX}${ID}s-s.gif` |
| 58 | `width="${STN_W}" height="${STN_H}"` |
| 61 | `img/${IMG_PREFIX}${ID}t-b.gif` and `...t-s.gif`, then **7 trailing spaces, or 3 when `${#ID}` is 5 (p28)** |
| 63 | `height="${TEM_H}"` |
| 66 | `${PAGE_PREFIX}table.html` |

All other lines are identical on every page.

Variables in `main`:
- `ID`: cruise characters 4-7, or 4-8 for p28
- `YYMM`: characters 4-7
- `PREV_ID`, `NEXT_ID`: the first `${#ID}` characters of PREV and NEXT
- page file: `${PAGE_PREFIX}${ID}.html`
- fixed label: `" ${FIXED_LABEL} ${ID}"`

- [ ] **Step 4: Run the page test for the fixed-label lines and confirm it passes.**

Run: `tests/cruisehtml/test_pages.sh p22 p15 i15 i21 p28 p05 p13 p31 p34 p40 && tests/cruisehtml/test_cli_errors.sh`
Expected: every case `PASS`, exit 0.

- [ ] **Step 5: Commit.**

```bash
git add cruisehtml.sh
git commit -m "cruisehtml.sh: line settings and page template"
```

---

### Task 4: Labels built from track letters (p09, p37, s37)

**Files:**
- Modify: `cruisehtml.sh`
- Modify: `tests/cruisehtml/test_functions.sh`

**Interfaces:**
- Consumes: `line_settings` (`FIXED_LABEL` empty) and `write_page` (Task 3).
- Produces: `track_label CODE TRACK YYMM` prints the label text exactly as it follows `color="red">`.

- [ ] **Step 1: Add the label tests to `test_functions.sh`.** The expected values come from `cruisehtml.x` on live cruises:

```bash
check p09_06_09     "PX06/PX09 0106"      "$(track_label p09 'ASH  ' 0106)"
check p09_06        "PX06 1407"           "$(track_label p09 'AS   ' 1407)"
check p09_none      " 0709"               "$(track_label p09 'AF   ' 0709)"
check p09_06_09_39  "PX06/PX09/PX39 9309" "$(track_label p09 'ASW  ' 9309)"
check p09_09        "PX09 1412"           "$(track_label p09 'AH   ' 1412)"
check p09_06_31     "PX06/PX31 0003"      "$(track_label p09 'LSA  ' 0003)"
check p09_06_12_18  "PX06/PX12/PX18 9806" "$(track_label p09 'ASTL ' 9806)"
check p09_06_09_31  "PX06/PX09/PX31 1409" "$(track_label p09 'ASHF ' 1409)"
check p37_none      " 1012"               "$(track_label p37 'S GI@' 1012)"
check p37_px44_flag "PX37 1109"           "$(track_label p37 'S GT@' 1109)"
check p37_37_10     "PX37/PX10 0503"      "$(track_label p37 'SHG  ' 0503)"
check p37_37_10_37  "PX37/PX10/PX37 0002" "$(track_label p37 'SHGK ' 0002)"
check p37_hs        "PX37 2305"           "$(track_label p37 'HS   ' 2305)"
check s37_fixed     "PX37 South 0811"     "$(track_label s37 'LH   ' 0811)"
```

- [ ] **Step 2: Run them and confirm they fail.**

Run: `tests/cruisehtml/test_functions.sh`
Expected: the 14 new checks FAIL (`track_label: command not found`); the Task 2 checks still `ok`.

- [ ] **Step 3: Implement `track_label`.** Port `rdtrack`'s p09 branch (`rdxbtinfo1.f:125-187`) and p37 branch (`rdxbtinfo1.f:280-304`), and `nameit` (`cruisehtml.f:575-697`):
  - **Port letters:** only track characters 1-4 count.
  - **Name order:**
    - p09: PX06, PX09, PX39, PX31, PX12, PX18. Apply the "PX12 clears PX31" fix, and ignore the PX13 flag (`linename(7)`), which `nameit` never prints.
    - p37: `linename(3)` PX37, then `linename(2)` PX10, then `linename(1)` (the PX44 flag) printed as PX37.
  - **Label:** names joined with `/`, then a space, then YYMM. With no names, it's a space then YYMM.
  - **s37:** always `PX37 South YYMM`.

Wire it into `main` for codes whose `FIXED_LABEL` is empty.

- [ ] **Step 4: Run all tests and confirm they pass.**

Run: `tests/cruisehtml/test_functions.sh && tests/cruisehtml/test_cli_errors.sh && tests/cruisehtml/test_pages.sh`
Expected: all `ok`/`PASS`, 48 of 48 pages, exit 0.

- [ ] **Step 5: Commit.**

```bash
git add cruisehtml.sh tests/cruisehtml/test_functions.sh
git commit -m "cruisehtml.sh: PX09/PX37 labels from xbtinfo track letters"
```

---

### Task 5: Live comparison against every cruise

**Files:**
- Create: `tests/cruisehtml/compare_live.sh`

**Interfaces:**
- Consumes: the repo's `cruisehtml.x` and `cruisehtml.sh`.
- Produces: `compare_live.sh <live xbtinfo dir>` prints `MATCH`, `DIFF` or `SKIP` per cruise, then the totals. It exits 1 on any `DIFF`.

- [ ] **Step 1: Write `compare_live.sh`.** For each supported code:
  1. **Enumerate cruise IDs** from file lines 4-303 of `<dir>/xbtinfo.<code>`, de-duplicated:
     - non-p28 codes: lines starting with 4 digits; the ID is columns 1-4
     - p28: lines starting with 4 digits and a lowercase letter; the ID is columns 1-5
  2. **Run both programs** in separate fresh `mktemp -d` folders, with the xbtinfo symlinked in. Feed `cruisehtml.x` the same input `make_fixtures.sh` uses.
  3. **SKIP** when the `cruisehtml.x` page contains a NUL byte; the Fortran's output is broken there.
  4. **Compare.** Otherwise, `MATCH` when file name and bytes are equal after the allowed fix is applied to the `cruisehtml.x` page, and `DIFF` (with the diff) when they aren't.

- [ ] **Step 2: Run it on the workstation.**

Run: `tests/cruisehtml/compare_live.sh /home/jbrzensk/XBT | tail -3`
Expected: `1302 MATCH, 0 DIFF, 0 SKIP`. The count was surveyed on 2026-10-20; it grows as cruises are added.

If a DIFF traces back to the Fortran rather than the port, record the cruise in the commit message instead of copying the bug. For example, `rdtrack` writes `linename(7)` past `cruisehtml.f`'s 6-element array.

- [ ] **Step 3: Commit.**

```bash
git add tests/cruisehtml/compare_live.sh
git commit -m "Add live comparison of cruisehtml.sh against cruisehtml.x"
```

---

### Task 6: Switch line_2025.sh to cruisehtml.sh

**Files:**
- Modify: `line_2025.sh:615-662`: the html block, from `# html file:` through the `mv *html` chain.

**Interfaces:**
- Consumes: `cruisehtml.sh <cruise>` (Task 2) and its exit status.

- [ ] **Step 1: Replace both `cruisehtml.x` heredoc calls with one call.**
  - Build `cruise_name`:
    - line 28: `p${line}$(basename "$PWD")`. Check that the folder name matches `^[0-9][0-9][0-9][0-9][a-z]$`; if it doesn't, print an error and treat it like a cruisehtml failure.
    - every other line: `${ch}${line}${i}`
  - Run `cruisehtml.sh "$cruise_name"`.
  - **If it succeeds,** run the existing `mv *html` chain unchanged.
  - **If it fails,** print `cruisehtml.sh failed for ${cruise_name} - no html moved. Fix the xbtinfo file, rerun cruisehtml.sh ${cruise_name} here, then move the page by hand.` Skip the `mv` chain, but don't exit, so the `a.10` zip-and-copy step still runs (Review Focus 5).

- [ ] **Step 2: Verify the script and the calls it now makes.**

Run: `bash -n line_2025.sh && ! grep -n 'cruisehtml\.x' line_2025.sh && test -x cruisehtml.sh && echo OK`
Expected: `OK`.

With `REPO=/home/jbrzensk/github/XBT-prog`, run, in a scratch copy of `/home/jbrzensk/XBT/p15/250707` (data files plus a symlink `xbtinfo.i21` → `/home/jbrzensk/XBT/xbtinfo.i21`):
`read line_number prefix < <(extract_prefix.sh); ch=${line_number:0:1}; line=${line_number:1:2}; i=${prefix:3:4}; cruisehtml.sh "${ch}${line}${i}" && cmp i152507.html <(sed 's/<font size=3">/<font size="3">/' $REPO/tests/cruisehtml/expected/i212507/i152507.html)`
Expected: `Wrote i152507.html`, and no output from `cmp`.

Run, in a scratch folder named `2402b` with a symlink `xbtinfo.p28` → `/home/jbrzensk/XBT/xbtinfo.p28`: `cruisehtml.sh "p28$(basename "$PWD")"`
Expected: `Wrote i282402b.html`.

Run, in a scratch folder with no xbtinfo, the new block's failure branch (`cruisehtml.sh p409999 || echo FAILED-BRANCH`)
Expected: the error, then `FAILED-BRANCH`; no `.html` file created.

- [ ] **Step 3: Commit.**

```bash
git add line_2025.sh
git commit -m "line_2025.sh: build cruise pages with cruisehtml.sh"
```
