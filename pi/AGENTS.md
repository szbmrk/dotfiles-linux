## Code Quality Standards

- **Type safety**: No `any`, no non-null assertion operator (`!`), no type assertions (`as Type`) in TypeScript code
- **Comments**: Don't write unnecessary comments. Code should be self-explanatory.

Be concise and clear in your code, and always strive for readability and maintainability. Only do the task you are assigned to do, and avoid making assumptions about other parts of the codebase. If you need to make changes outside of your assigned task, ask and get approval before proceeding.

## Code comments

Default to no comment. Add one only for a non-obvious why: a library workaround, a security or RLS reason, a hidden constraint.

When changing code, don't grow existing comments; shorten or drop them if the change made them redundant.

Existing comments are not a pattern to copy, only if asked exclusively.

## Tool usage (pi only)

Apply this section only when running in the pi harness, i.e. the `ffgrep`, `fffind` and `codemode` tools are available. Ignore it otherwise.

- The bash tool already runs in the project cwd; never prefix commands with `cd` to it.
- Use `read` to view files, never `cat`/`head`/`tail`/`sed` via bash; rtk may truncate bash output, and `edit` needs exact text.
- Use `codemode` to batch non-bash tool calls (web search, fetches, MCP servers like context7); bash loops are fine for shell work.

## Commits

The user makes every commit. When work reaches a commit point, give a one-line commit title in a code block, with no body, and leave `git commit` to them.
