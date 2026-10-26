# Xi Wang — Analytics Portfolio

A bilingual, static portfolio for data, financial product and product analysis. HTML, CSS and JavaScript; no package installation or external font service required.

## Selected work

- `case-etf.html` / `case-etf-en.html` — five CSI 300 ETFs, three predefined windows and an interactive comparison tool. Navy/white financial-research design.
- `case-uniswap.html` / `case-uniswap-en.html` — activity, address return and concentration in one Base Uniswap v3 pool. Cream/green design.
- `index.html` — Chinese/English overview; use `?lang=en` for an English entry.
- `research-etf.html` — redirects the earlier ETF planning URL to the completed case.
- `projects/etf/` and `projects/uniswap/` — reports, portable tools, English summaries, SQL, CSVs and source snapshots.

## Preview and publish

Open `index.html` in a browser. Upload the contents of this folder to the root of the user-site repository, then select Settings → Pages → Deploy from a branch → main → /(root). Keep `.nojekyll` at the root. Local preparation does not establish a live deployment.

## Evidence and limits

ETF: five selected Shanghai-listed RMB CSI 300 ETFs; main window 2025-10-24 to 2026-10-23, with 242 daily returns and a preceding seed date. Market analysis and prototype implementation are complete; real-user effects remain untested.

Uniswap: Base WETH/USDC 1% pool, [2026-07-27, 2026-10-19) UTC; eight displayed weeks after a 28-day buffer. Origins are address proxies; estimated trading-leg USD is not revenue or net inflow.

Reports, source snapshots and result tables retain their research definitions. Checksums are in the project provenance files. The portable ETF tool hides unavailable authoring controls; the presentation-only derivative is recorded without changing calculations or archived files. Third-party data and reports retain their respective rights.

## Languages

The overview and both case studies support Chinese and English. The homepage language toggle also changes case-study destinations. Original reports, tools and some source figures remain in Chinese, with English case narratives and executive summaries. Repository documentation has full English and Chinese versions.
