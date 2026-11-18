# TaxDraft MY

A single-file browser app that produces a **first-draft Malaysian corporate tax computation** from your documents, plus a **variance report** comparing last year's financials to this year's, with tax-risk flags under Malaysian tax law (ITAA 1967 — s.33, s.39, s.133, etc.).

## Running

Double-click **`Start TaxDraft MY.bat`** (or open `index.html` in Chrome/Edge).

## Setup

Fully pre-configured — the launcher starts a small local proxy (needed because the API doesn't allow direct browser calls) and the API key is built in. Just double-click **`Start TaxDraft MY.bat`** and start working. No settings changes required.

> If you ever need to use a different endpoint or key, change them in the **Settings** tab.

## Workflow

1. **Clients** — add each client company and its year of assessment.
2. **Documents** — upload per client:
   - Last year's tax computation (PDF or Excel)
   - Last year's financial statements
   - This year's financial statements / trial balance
3. **Draft & Variance** — click *Generate*. The AI returns:
   - A draft tax computation in the prior year's format (untraceable figures marked `[ASSUMPTION]`)
   - A variance table (prior vs current, >15% movements, new/removed items, margin shifts)
   - Malaysian tax-specific items to investigate (s.33/s.39 disallowables, s.133 interest restriction, related-party balances, ECL provisions, etc.)
   - Assumptions and data gaps
4. Export the draft and reports to **Excel** for review.

## Important

- The output is a **draft only** — every figure must be reviewed, traced to source, and approved by a qualified tax professional before filing.
- All client data stays in this browser's local storage on this machine. Nothing is uploaded except the extracted document text sent to the LLM endpoint when you click Generate.
- To wipe all stored data: Settings → *Erase all stored data*.
- PDF parsing extracts text; scanned (image-only) PDFs need OCR before upload.
