# sosreport-triage

This package is a support-engineering workflow for offline analysis of customer-provided `sosreport` bundles.

It is not meant to run on customer production hosts. It helps a support engineer:

- inspect an extracted `sosreport` locally
- gather evidence consistently
- separate facts from inference
- rate severity with a repeatable rubric
- reuse prior incident patterns through case playback

## Package Layout

- `SKILL.md`: primary analysis workflow and guardrails
- `docs/rubric.md`: severity and evidence scoring rules
- `docs/compatibility.md`: distro and path fallback guidance
- `cases/`: replayable incident patterns and templates
- `scripts/sos-summary.sh`: local helper script to extract a first-pass summary

## Recommended Workflow

1. Extract the customer `sosreport` locally.
2. Run `scripts/sos-summary.sh /path/to/extracted-sosreport`.
3. Review the generated fact summary and missing-evidence notes.
4. Apply `SKILL.md` and `docs/rubric.md` to form a conclusion.
5. Compare with a similar case in `cases/` when the pattern looks familiar.
6. Write the final support note using:
   - Observed facts
   - Likely impact or risk
   - Most likely explanations
   - Evidence gaps

## Design Principles

- Offline only: no customer-host execution required
- Evidence first: file-backed observations before diagnosis
- Conservative attribution: risk is not the same as root cause
- Missing files are normal: use fallbacks and lower confidence when needed

## What This Package Now Fixes

- adds a local helper instead of requiring customer-side execution
- adds replayable examples instead of a single minimal example
- adds a scoring rubric for more consistent judgments
- adds compatibility guidance for differing `sosreport` layouts
- creates a base for internal validation and case-library growth
