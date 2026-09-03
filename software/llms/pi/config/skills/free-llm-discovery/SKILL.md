---
name: free-llm-discovery
description: Use when asked to discover, compare, refresh, reorder, or update free LLM API tiers and coding models in software/modules/litellm.nix.
compatibility: Pi with network and repository edit access.
metadata:
  target: software/modules/litellm.nix
---

# Free LLM Discovery

Research current free API LLMs and update the LiteLLM coding pool. Complete
edits; do not stop after recommendations.

## Workflow

### 1. Inspect

Read Git status and:

- `software/modules/litellm.nix`: providers, credentials, routing, and limits.
- `software/modules/litellm.md`: documented order and setup.
- `software/common/opencode/opencode.json`: shared model capabilities and alias.

Preserve unrelated changes and public alias `free-coding`. Never read, print,
edit, or commit `/etc/litellm/credentials.env` or real API keys.

### 2. Research

Search the web using the current date. Verify third-party leads against official
pricing, quota, model, rate-limit, privacy, API docs, or live catalogs.

For incumbents and credible replacements, verify:

- Free-tier type, exact allocation/reset, and separate RPM/TPM/RPD ceilings.
- Exact API model ID, context/output, tools, streaming, reasoning, and coding.
- Account, payment, identity, region, and automatic overage requirements.
- Retention, training, and privacy controls.
- Native support and required parameters in the pinned LiteLLM release.

Treat old blog posts, referral offers, consumer chat quotas, OAuth workarounds,
and web-only plans as stale until officially verified. Report conflicts.

### 3. Rank

Use ongoing free API routes by default; exclude one-time credits and trials
unless requested. Require tool calling and prefer at least 128K context.

Rank by:

1. Coding, reasoning, and reliable tool calling.
2. Recurring allowance and protection against paid overage.
3. Availability and API stability.
4. Context/output limits and privacy.

Report gaps rather than silently weakening requirements.

### 4. Update

- Keep `model_list`, numbered deployment names, `router_settings.fallbacks`, and
  `litellm.md` in identical order.
- Primary name is `free-coding`; fallbacks are
  `free-coding-02-<provider>`, `free-coding-03-<provider>`, etc. Every fallback
  must resolve once.
- Confirm provider support in pinned LiteLLM. A model absent from its cost map
  may still forward. Otherwise use an official OpenAI-compatible endpoint,
  never a reverse-engineered or terms-violating one.
- Preserve host, manual startup, credentials, retries, cooldowns, timeouts, and
  firewall unless asked. Add empty credential variable names, never values.
- Update docs and use minimum shared capabilities for OpenCode model metadata.

### 5. Verify

- `free-coding` exists once and is intended primary.
- Every fallback exists once in documented order.
- Credential names match configuration and docs.
- No paid/trial model or secret entered persistent configuration unnoticed.

Run syntax, formatting, and diff checks. Do not run Nix evaluation/build or
commit unless requested. Validate OpenCode schema if its config changed.

Report the research date, official source URLs, changed order, removed or
rejected candidates, privacy or billing risks, and anything that could not be
verified.
