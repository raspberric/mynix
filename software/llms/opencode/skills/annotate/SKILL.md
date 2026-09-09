---
name: annotate
description: Use when asked to annotate, explain, or leave PR-style comments on the committed changes in the current Git branch; stores file-and-line comments in git notes.
compatibility: Git repository with a checked-out branch and git notes support.
---

# Annotate A Branch With Git Notes

Explain the current branch as if reviewing a pull request. Store concise,
file-and-line comments in `refs/notes/pr-comments` on the current `HEAD` commit.
Git notes are local review metadata, not GitHub or forge comments.

## Rules

- Use this workflow for explanations of committed branch changes, not requested
  code changes or a normal defect-focused code review.
- Never edit files, stage changes, create or amend branch commits, switch
  branches, fetch, push, or modify an existing branch commit.
- `git notes` may update only `refs/notes/pr-comments`.
- Analyze `merge-base..HEAD`, not uncommitted worktree or index changes. Report
  that uncommitted changes were excluded when the worktree is dirty.
- Explain intent, behavior, data flow, invariants, interactions, tradeoffs, and
  non-obvious compatibility effects. Do not restate syntax or every changed
  line.
- Do not invent motivation. Clearly label an explanation as an inference when
  the branch does not establish the reason for a change.
- Keep comments concise and independently useful beside the referenced diff.
- Preserve existing notes. Never use `git notes add -f`, `git notes edit`,
  `git notes remove`, or direct ref-update commands.

## Workflow

### 1. Resolve The Comparison

Confirm that `HEAD` is a checked-out branch and inspect repository state:

```bash
git symbolic-ref --quiet --short HEAD
git status --short
```

Use the base branch explicitly named by the user. Otherwise use the remote
default branch only when its symbolic ref makes the choice unambiguous, such as
`refs/remotes/origin/HEAD`. Do not use the feature branch's upstream as the base
and do not guess between possible base branches. Ask one concise question when
the base cannot be determined.

Resolve and record the comparison boundary:

```bash
git merge-base <base-ref> HEAD
git rev-parse HEAD
```

Stop if the merge base equals `HEAD` because the branch has no committed
changes relative to the base.

### 2. Analyze The Branch

Inspect the commit list and complete diff from the merge base through `HEAD`:

```bash
git log --reverse --format=fuller <merge-base>..HEAD
git diff --find-renames --find-copies --stat <merge-base>...HEAD
git diff --find-renames --find-copies --unified=80 <merge-base>...HEAD
```

Use `git show HEAD:<path>` for additional file context so uncommitted file
contents cannot contaminate the explanation. Inspect relevant surrounding
repository code when needed, while keeping every comment grounded in the
committed branch diff.

Select a small set of high-signal comments. Anchor added or modified lines to
the new file with one-based line numbers and side `RIGHT`. Anchor deleted lines
to the base version with their old line number and side `LEFT`. Use the
destination path for renames. Avoid comments on generated, vendored, lock, or
binary files unless they contain an important non-obvious change.

### 3. Write The Notes

First inspect any existing note to avoid duplicating its comments:

```bash
git notes --ref=pr-comments show HEAD
```

Exit status 1 means no note exists yet. Other failures must be resolved before
writing. Append one review block containing all new comments; `append` creates
the note when necessary and preserves existing blocks:

```bash
git notes --ref=pr-comments append -F - HEAD <<'NOTE'
# PR comments

- Branch: `<branch>`
- Base: `<base-ref>`
- Merge base: `<merge-base-sha>`
- Head: `<head-sha>`

## `<path>:<line>` (`RIGHT`)

Concise explanation of this changed line or hunk.

## `<path>:<old-line>` (`LEFT`, deleted)

Concise explanation of the removed behavior.
NOTE
```

Replace every placeholder with resolved values and omit unused examples. Use a
quoted heredoc so code, quotes, dollar signs, and backticks in comments are not
interpreted by the shell. Do not create an empty note when no useful comments
can be made.

### 4. Verify And Report

Verify the exact note attached to `HEAD`:

```bash
git notes --ref=pr-comments show HEAD
git status --short
```

Report the base, head, number of comments added, and affected files. State that
the notes are local and can be viewed with
`git notes --ref=pr-comments show HEAD`. Do not push the notes ref unless the
user explicitly asks; normal branch pushes do not transfer it.
