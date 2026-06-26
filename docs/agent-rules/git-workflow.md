# Git Workflow, Workspaces, Releases, and Recovery

Read this file when tasks touch:
- branches,
- worktrees,
- commits,
- pushes,
- tags,
- releases,
- rollback/recovery,
- versioning,
- CI/release flow,
- App Store/TestFlight/distribution workflows,
- or when repository workflow materially affects risk.

This file defines repository workflow philosophy and operational safety.
Project-specific release docs override these defaults when they explicitly define a different workflow.

---

# Core Philosophy

Git workflow exists to:
- protect stable states,
- preserve recoverability,
- reduce accidental regressions,
- isolate risky work,
- and make release history understandable.

The goal is not "perfect Git hygiene."
The goal is safe, understandable iteration with minimal surprise.

Prefer:
- simple workflows,
- explicit transitions,
- visible release boundaries,
- reversible operations,
- and small understandable changes.

Avoid:
- hidden workspace manipulation,
- unnecessary branching complexity,
- silent history rewrites,
- or automation that obscures what actually shipped.

---

# Project Maturity Modes

## Exploratory / Personal Projects

For:
- quick utilities,
- internal tools,
- experiments,
- vibe-coded prototypes,
- personal automation,
- or unpublished projects.

Default workflow:
- working directly on `main` is acceptable,
- commit-to-main is normal,
- worktrees are optional,
- tags are optional except for known-good anchors.

Do not impose enterprise Git workflow unnecessarily.

---

## Release-Managed / User-Facing Projects

For:
- App Store/TestFlight apps,
- public releases,
- distributed binaries,
- external users,
- supported versions,
- or meaningful rollback requirements.

Treat:
- `main` as stable/shippable,
- release boundaries as intentional,
- tags as durable release anchors,
- workspaces as operationally important.

In these projects:
- unfinished future-release work should usually not live directly on `main`,
- release and hotfix flows should be explicit,
- and release artifacts should map cleanly to Git history.

---

# Workspace and Worktree Philosophy

## Workspaces Are User-Level Decisions

Branches, worktrees, clones, and release lanes are architectural workflow choices.

Agents must not:
- silently create worktrees,
- silently switch branches,
- silently rebase/rewrite history,
- or invent release topology.

Agents may:
- recommend safer workflows,
- suggest worktrees,
- suggest tags,
- suggest release separation.

But user approval is required before:
- creating,
- deleting,
- switching,
- merging,
- or restructuring workspaces.

---

# Worktree Model

When worktrees exist:

```text
Project-main/
Project-1.1/
Project-hotfix/
```

Treat each folder as:
- its own active workspace,
- with its own branch,
- uncommitted state,
- build artifacts,
- editor state,
- and active task context.

Mental model:

```text
Folder == active branch/workspace
```

Prefer opening the correct folder over repeatedly switching branches inside one folder.

---

# Codex / AI Workspace Rules

Do not create Codex-managed temporary worktrees unless explicitly approved.

Preferred model:
- user-managed visible worktrees,
- long-lived release lanes,
- stable workspace identity.

One Codex project per worktree is preferred.

Examples:

```text
RollCall-main
RollCall-1.1
RollCall-hotfix-audio
```

Within a project/worktree:
- many threads/tasks are acceptable.

Avoid:
- one giant multi-month thread covering unrelated work,
- or one thread spanning multiple unrelated branches/workspaces.

---

# Before Material Edits

Before risky or material edits, report:

- current working directory,
- current branch,
- `git status --short`.

If the workspace/branch does not match the requested task:
- stop,
- explain the mismatch,
- ask before proceeding.

---

# Branch Philosophy

Use the simplest workflow that safely fits the project.

Do not create branch complexity for its own sake.

---

# Common Branch Roles

## `main`

Usually:
- stable,
- primary,
- default branch.

In exploratory projects:
- direct iteration on `main` is acceptable.

In release-managed projects:
- `main` should remain reasonably shippable/stable.

---

## `release/*`

Used for:
- future releases,
- ongoing version work,
- major feature trains,
- release stabilization.

Examples:

```text
release/1.1
release/v2
```

---

## `hotfix/*`

Temporary branches created from stable release lines.

Examples:

```text
hotfix/audio-crash
hotfix/import-failure
```

Typical lifecycle:

```text
create
→ fix
→ merge/cherry-pick
→ delete
```

---

# Commit Philosophy

Prefer:
- small,
- reviewable,
- intentional commits.

Do not automatically commit at session end.

Exploratory/WIP state may remain uncommitted unless explicitly requested otherwise.

---

# Commit Messages

Use short imperative subject lines.

Examples:

```text
Fix audio playback race
Add onboarding state tracking
Prevent empty lineup export
```

≤72 characters preferred.

Add a body only when:
- rationale is non-obvious,
- migration/recovery matters,
- or future maintainers need context.

---

# Push / Rewrite Safety

Do not:
- push,
- force-push,
- merge,
- rebase,
- cherry-pick,
- reset,
- rewrite history,
- modify remotes,
- or move/delete tags

unless explicitly instructed.

History rewrites always require approval.

---

# Tags and Release Anchors

Tags are durable historical markers.

Use tags for:
- App Store submissions,
- public releases,
- known-good milestones,
- rollback anchors,
- meaningful stable states.

Branches move.
Tags do not.

Example tag formats:

```text
v1.0-build53
v1.0.1-build81
v2.0
known-good-2026-05-27
```

Project-specific docs may define stricter formats.

---

# Known-Good Anchors

If the user identifies a state as:
- stable,
- trusted,
- releasable,
- or important,

recommend:
- a tag,
- branch,
- or other durable rollback anchor.

Do not silently create anchors unless instructed.

---

# Rollback and Recovery

Before rollback/reset-like actions, explain:
- what state would be restored,
- what work could be lost,
- whether recovery is still possible afterward.

Prefer:
- reversible recovery,
- targeted restoration,
- narrow rollback,
- and preserving recoverability.

Avoid destructive cleanup unless explicitly approved.

---

# Versioning Philosophy

Prefer deterministic versioning from source-controlled files.

Do not derive release identity from:
- DerivedData,
- `.build`,
- local caches,
- machine-local state,
- or generated temporary outputs.

Same source commit should produce same release identity.

---

# Build Numbers and Marketing Versions

These are separate concepts.

Example:

```text
Marketing version: 1.0.1
Build number: 81
```

Build numbers:
- may increase independently,
- may skip,
- should never be reused once published/uploaded.

Marketing versions:
- represent intentional release boundaries,
- should not change automatically unless the project explicitly defines that behavior.

---

# Release-Managed Project Recommendations

For user-facing projects:
- tag shipped releases,
- keep release lanes understandable,
- prefer explicit hotfix flow,
- avoid hidden release automation,
- preserve reproducibility.

---

# App Store / TestFlight Guidance

For App Store/TestFlight workflows:

Prefer:
- public release archives from stable branches/workspaces,
- explicit release tagging,
- stable reproducible version/build state.

Before archive/release operations, report:
- current folder,
- current branch,
- `git status --short`,
- version/build values,
- latest relevant tag if applicable.

Stop if:
- local state could produce an unintended release,
- version/build appears inconsistent,
- or the workspace is ambiguous.

---

# Worktree Examples

Example stable + future-release layout:

```text
Coding/
├── RollCall/
├── RollCall-1.1/
└── RollCall-hotfix-audio/
```

Possible meanings:

```text
RollCall/              → main
RollCall-1.1/          → release/1.1
RollCall-hotfix-audio/ → hotfix/audio-fix
```

Benefits:
- reduced branch-switching confusion,
- clearer AI workspace identity,
- separate editor/build state,
- reduced accidental release contamination.

---

# Hotfix Flow Example

Typical release-managed hotfix flow:

```text
main
→ create hotfix branch/worktree
→ implement fix
→ merge into main
→ merge/cherry-pick into active release branch
→ tag if released
→ remove temporary hotfix workspace
```

---

# Release Philosophy

A release should be:
- intentional,
- understandable,
- reproducible,
- recoverable,
- and traceable back to source.

Avoid workflows where:
- nobody knows what commit shipped,
- release identity depends on machine-local state,
- or release topology becomes too confusing to reason about safely.