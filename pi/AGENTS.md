## Scope

Change only what the task covers. Put anything else worth doing in a short list at the end of your reply, and ask before touching it.

## Diagnosis

Find the cause before changing anything. A symptom can come from layout, timing or environment rather than the content it shows, such as a truncated label that looks like wrong wording.
Before fixing, get a loop that reproduces the failure, and count a fix only when that loop goes from red to green.
Call a failure flaky only with evidence, such as the same failure on the base branch.
Set thresholds and limits from measured values.

## Environment

The shell is fish, so write commands that run in fish.
Check what the target accepts before writing a command or query for it. For example, a web SQL console may run one statement at a time, and a task runner may not forward env vars.
Before moving or renaming a file or folder, search for its old path and update what references it.

## TypeScript

Narrow types with type guards and schemas. `any`, non-null assertions (`!`) and type assertions (`as Type`) stay out of the code.

## Code comments

Default to no comment. Add one only for a non-obvious why: a library workaround, a security or RLS reason, a hidden constraint.

When changing code, keep existing comments at their length or shorter, and drop the ones the change made redundant. Write new comments by this rule, not by the file's existing style, unless asked to match it.

## Skills

Load every skill that covers the library, tool or workflow at hand before starting, including name-only skills, which list no description. Project instructions win a conflict.

## Subagents

Delegate without asking when a task splits into independent slices, such as server and native clients. Write the shared contract first (schemas, wire examples, spec text), then run one subagent per slice in parallel and send each slice's follow-ups to its own subagent.
Scout the same way: when mapping a change means sweeping several areas, run one read-only subagent per area and keep only their conclusions (locations, constraints, surprises).
Keep small fixes, single-file changes and lookups with a known target inline.
Check every slice's result, screenshots included, before reporting it.

## Review

When a feature is done, offer a review at the end of the final report.
When the user asks for one in any wording or accepts, run both in parallel and report them separately:
- **Fresh**: the `code-review` skill against the branch's merge-base.
- **Forked**: one forked subagent that checks the change against what the conversation settled: the user's intent and corrections, and anything agreed but not done.

## Git

The user makes every commit. Leave changes unstaged and uncommitted for them.
Check whether you are in a worktree or the main checkout before editing.
To test another state of the code, use a worktree or a scratch branch; `git stash` is off-limits.
