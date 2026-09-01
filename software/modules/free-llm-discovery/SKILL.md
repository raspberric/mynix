---
name: free-llm-discovery
description: Use when asked to discover, compare, refresh, reorder, or update free LLM API tiers and coding models in software/modules/litellm.nix.
compatibility: OpenCode with web search and repository edit access.
metadata:
  target: software/modules/litellm.nix
---

# Free LLM Discovery

Research current free API-accessible LLMs and keep the repository's LiteLLM
coding fallback pool accurate. Complete the research and edits rather than
stopping after recommendations.

## Target Files

- `software/modules/litellm.nix`: providers, model IDs, credentials names, and
  fallback order.
- `software/modules/litellm.md`: human-readable provider order and setup notes.
- `software/common/opencode/opencode.json`: only when the pool's minimum
  context, output, tool support, endpoint, or public alias changes.

Never read, print, edit, or commit `/etc/litellm/credentials.env` or real API
keys.

## Workflow

### 1. Inspect The Existing Pool

Read the target files and inspect Git status before researching. Preserve
unrelated worktree changes. Record the current public alias, provider order,
model IDs, credential variable names, routing settings, minimum context, and
minimum output limit.

The externally visible primary model must remain `free-coding` unless the user
explicitly requests a breaking rename.

### 2. Search The Web

Search the web using the current date. Prefer official pricing, quota, model,
rate-limit, privacy, and API documentation. Use third-party sources only to
find leads, then verify each claim against an official source or a live official
model catalog.

For every incumbent provider and credible replacement, verify:

- Whether free API usage is recurring, zero-priced but rate-limited, or a
  one-time/expiring trial.
- Exact free tokens, credits, requests, RPM, TPM, RPD, and reset period. Do not
  present a rate ceiling as an allocated quota.
- Exact current API model ID, context window, maximum output, tool calling,
  streaming, reasoning, and coding suitability.
- Account, card, phone, identity, region, and automatic paid-overage
  requirements.
- Prompt retention, training, and privacy controls.
- Native LiteLLM provider prefix and required parameters for the repository's
  pinned LiteLLM version.

Treat old blog posts, referral offers, consumer chat quotas, OAuth workarounds,
and web-only plans as stale until officially confirmed for API use. Flag
conflicting documentation instead of guessing.

### 3. Select And Rank

By default, include only ongoing free API routes in the persistent pool.
Exclude one-time signup credits and expiring trials unless the user asks for
them.

Rank candidates using this priority:

1. Coding, reasoning, and reliable tool-calling capability.
2. Recurring free allowance and hard protection against paid overage.
3. Availability and stable API behavior.
4. Context and output limits suitable for OpenCode agent sessions.
5. Privacy and retention terms.

Prefer models with at least a 128K context window. Do not add a model without
tool calling to the coding pool. If no candidate satisfies those constraints,
report the gap rather than silently weakening the pool.

### 4. Verify LiteLLM Compatibility

Confirm that the pinned LiteLLM release recognizes each native provider prefix.
Do not assume a newly announced model appears in LiteLLM's cost map; arbitrary
model forwarding may still work when the provider integration supports it.

When native support is unavailable but the vendor officially provides an
OpenAI-compatible endpoint, use LiteLLM's generic OpenAI-compatible route with
an environment-referenced API base. Do not use reverse-engineered browser
endpoints or terms-of-service workarounds.

Do not run a Nix evaluation or full NixOS build unless the user explicitly asks
for one.

### 5. Update The Configuration

Keep all three order representations synchronized:

1. Physical order in `model_list`.
2. Numeric deployment names.
3. Order in `router_settings.fallbacks` and `litellm.md`.

The first deployment uses `model_name = "free-coding"`. Name subsequent
deployments `free-coding-02-<provider>`, `free-coding-03-<provider>`, and so on.
Every fallback name must resolve to exactly one `model_list` entry. Do not add
the primary alias to its own fallback list.

Preserve host binding, manual systemd startup, credential-file handling,
timeouts, retries, cooldowns, and firewall settings unless the user asks to
change them. Add new credential environment variable names with empty defaults,
but never add credential values.

Update `litellm.md` whenever providers, models, credentials, order, or behavior
changes. Update OpenCode's model metadata conservatively using the minimum
capabilities shared by every fallback model.

### 6. Verify And Report

Re-read the final model list and fallback chain. Check that:

- `free-coding` exists exactly once and is the intended primary.
- Every fallback exists exactly once and follows the documented order.
- Credential variable names match their provider entries and documentation.
- No paid-only or trial-only model entered the recurring pool unnoticed.
- No secrets entered Git or the Nix store configuration.

Run lightweight syntax, formatting, and diff checks that do not evaluate Nix.
If OpenCode configuration changed, validate it against the current OpenCode
schema. Do not commit unless the user requested a commit.

Report the research date, official source URLs, changed order, removed or
rejected candidates, privacy or billing risks, and anything that could not be
verified.
