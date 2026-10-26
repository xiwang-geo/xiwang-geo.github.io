# Xi Wang — Analytics Portfolio

A bilingual, static portfolio of two source-backed data projects. Plain HTML, CSS and JavaScript; no build step, no package installation, no external font or analytics service.

**Live site:** https://xiwang-geo.github.io/

## Selected work

- **CSI 300 ETF comparison** — [中文案例](case-etf.html) · [English](case-etf-en.html) · [repository](https://github.com/xiwang-geo/csi300-etf-analysis)
  Five same-index Shanghai-listed ETFs across three predefined windows: fees, return, risk, tracking and trading activity, plus an offline screening and comparison tool. Navy/white financial-research design.
- **Uniswap single-pool analysis** — [中文案例](case-uniswap.html) · [English](case-uniswap-en.html) · [repository](https://github.com/xiwang-geo/uniswap-base-analysis)
  Activity, address return and concentration in one Uniswap v3 WETH/USDC 1% pool on Base. Cream/green design.

## Structure

`index.html` overview — Chinese by default, English via `?lang=en`. `case-*.html` the four case pages. `projects/etf/` and `projects/uniswap/` reports, portable tools, English summaries, SQL, CSVs and source snapshots. `research-etf.html` redirects the earlier ETF planning URL to the completed case. `assets/` styles, scripts and figures. `.nojekyll` keeps the folder published as-is on GitHub Pages.

## Evidence and limits

ETF: five selected Shanghai-listed RMB CSI 300 ETFs; main window 2025-10-24 to 2026-10-23, with 242 daily returns and a preceding seed date. Market analysis and prototype implementation are complete; real-user effects remain untested.

Uniswap: Base WETH/USDC 1% pool, [2026-07-27, 2026-10-19) UTC; eight displayed weeks after a 28-day buffer, covering 15,123 Swap events and 2,086 origin addresses. Origins are address proxies; estimated trading-leg USD is not revenue or net inflow.

Reports, source snapshots and result tables retain their research definitions. Checksums are in the project provenance files. The portable ETF tool hides unavailable authoring controls; the presentation-only derivative is recorded without changing calculations or archived files. Third-party data and reports retain their respective rights.

## Languages

The overview and both case studies support Chinese and English. The homepage language toggle also changes case-study destinations. Original reports, tools and some source figures remain in Chinese, with English case narratives and executive summaries. Repository documentation has full English and Chinese versions.
