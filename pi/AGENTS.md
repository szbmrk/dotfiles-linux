## Scope

Change only what the task covers. Ask before touching anything outside it.

## TypeScript

Narrow types with type guards and schemas. `any`, non-null assertions (`!`) and type assertions (`as Type`) stay out of the code.

## Code comments

Default to no comment. Add one only for a non-obvious why: a library workaround, a security or RLS reason, a hidden constraint.

When changing code, keep existing comments at their length or shorter, and drop the ones the change made redundant. Write new comments by this rule, not by the style already in the file, unless asked to match it.

## Skills

Load every skill that covers the library, tool or workflow at hand before starting, including name-only skills, which list no description: Drizzle schema and migrations, Effect code, a module redesign, a review. Project instructions win a conflict.

## Subagents

Delegate without asking when a task splits into independent slices, such as server and native clients, or Android and desktop. Write the shared contract yourself first (schemas, wire examples, spec text), then run one subagent per slice in parallel, and send each slice's follow-ups to its own subagent. Scout the same way without asking: when mapping what a change touches means sweeping several areas, run one read-only subagent per area in parallel and keep only their conclusions (locations, constraints, surprises). Keep small fixes, single-file changes and lookups with a known target inline. Check every slice's result, screenshots included, before reporting it.

## Commits

The user makes every commit. Leave changes unstaged and uncommitted for them.
