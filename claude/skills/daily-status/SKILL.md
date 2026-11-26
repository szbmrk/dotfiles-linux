---
name: daily-status
description: Draft today's daily status message for the #internal-team thread from yesterday's commits and PRs.
disable-model-invocation: true
---

Draft the **status** the user pastes into today's "Daily Status Message Request" thread in Slack `#internal-team` (`C048SNGT57D`). The status goes on the clipboard as HTML; the reply shows it as rendered Markdown, followed only by the one-line note from step 4 when it applies.

## 1. Last status

Search Slack for the user's latest status: `slack_search_public_and_private`, filters `from:<@U0AL60DEVN3> in:<#C048SNGT57D>`, keyword `workday`, sorted by timestamp, limit 3. Take the newest one posted before today (if one was already posted today, tell the user and stop).

Done when you hold its post date and its `Today:` items. If Slack is unreachable, use the last weekday as the post date and an empty plan.

## 2. Evidence

The **window** runs from the last status's post date through yesterday, so a Monday status covers Friday and the weekend. Run:

```
bash ~/.claude/skills/daily-status/evidence.sh <post date, YYYY-MM-DD>
```

It prints the user's commits on every branch of the repos under `~/travlrd`, their PRs touched in the window, and the follow-ups those PRs list in their description. The PR list decides merged or open; the branch name beside a commit is only a hint.

Done when every commit and every PR in the output is assigned to an item or to noise (step 3), and every follow-up to a `Today:` item or to work already done (step 4).

## 3. Previous workday items

An **item** is one piece of work a teammate would recognise. List every one; a busy day has 10 to 15 items.

- A PR whose commits all serve its title is one item, named after the PR (`fix/design-unification` with four small design `feat` commits is `design unification`).
- **Split** a PR that holds more than its title says: every `feat` commit on a subject the title does not cover becomes its own item, with the commits that follow it on the same subject folded in. A 45-commit `feat/new-deadline-module` yields `digest preview layout switcher`, `shared searchable select`, `native needs attention pages` and the rest, each as an item.

- Start with the last status's `Today:` items, in their order, reusing their wording with typos fixed. Then add an item for every piece of work the plan did not name.
- A **placeholder** in the plan (`TBD`, or an umbrella such as `analysis dev`) is replaced by the specific items found; it is never listed itself.
- Merged by now: `:white_check_mark:`. A planned item whose branch is still unmerged keeps its own line with `:octagonal_sign:`. On an unmerged branch holding several items, the newest is `:octagonal_sign:` and the ones it was stacked on are `:white_check_mark:`.
- A planned item with no evidence is **unverified**: leave it out of `Previous workday:` and carry it to `Today:`.
- Noise folds into its parent item: `fix` commits on the feature they follow, stale-test fixes, merges from staging, lint and knip cleanups, review-finding fixes, dependabot merges.
- A `staging -> main` PR is the item `prod release`.
- Wording: `<Project> - <topic>`. The topic is the user's own phrasing, which is the branch name or the PR or commit subject with its prefix stripped, keeping its verb and word order, in lowercase:
  - branch `feat/remove-company-grouping` gives `remove company grouping`
  - `chore(ci): optimize tests` gives `optimize CI`
  - `feat(timeline): migrate pdf gen to react-pdf` gives `analysis timeline migrate to react-pdf`
  - `fix: dynamic react-email loading` gives `react-email dynamic import`
  - `fix(windows): start after updating` gives `windows autostart problem`
- Project comes from the repo: `dddownload` is DDDownload, `bibiugyke` is Iktix, `hellobrand` is Hellobrand; any other repo uses its capitalised name. Group items by project, the plan's project first.
- An empty window gives the single item `-`.

## 4. Output

Show the status in the reply as rendered Markdown:

```
**Previous workday:**
- DDDownload - analysis role management :white_check_mark:
- DDDownload - analysis timeline daily PDF gen :octagonal_sign:

**Today:**
- DDDownload - analysis timeline daily PDF gen
- TBD

**Next workday:**
- TBD
```

`Today:` is every `:octagonal_sign:` item without its mark, then every unverified item, then one item per **follow-up** that no commit in the window already covers, then `TBD` only if the list is still empty. A follow-up item uses the same `<Project> - <topic>` wording, with the topic boiled down to what a teammate would recognise: `**Zooming** into the day strip, down to the minute` on a timeline PR gives `analysis timeline zoom handling`. `Next workday:` is `TBD`.

Then put the same status on the clipboard as HTML with nothing between elements, since any whitespace or `<p>` pastes into Slack as an empty line. Write it to a scratchpad file and copy it with `setsid -f`, so `wl-copy` outlives the shell:

```
<b>Previous workday:</b><ul><li>DDDownload - analysis role management :white_check_mark:</li></ul><b>Today:</b><ul><li>TBD</li></ul><b>Next workday:</b><ul><li>TBD</li></ul>
```

```
setsid -f wl-copy --type text/html < <file>
```

Done when `wl-paste --type text/html` in a separate command prints the status. End the reply with the line `On your clipboard: paste it straight into Slack.`, since copying the rendered reply brings the empty lines back.

If there are unverified items, add one line under the status, after a `---` rule, naming them, so the user can move the ones they did (meetings, specs, research, releases leave no commits) up into `Previous workday:`.
