# Botlab Agent Guide

Use `botlab` only when work should use the `shravangoswami-bot` GitHub account. Most work is normal personal/project work and should keep using regular `git` and regular `gh`.

`botlab` keeps bot GitHub CLI auth separate from the main account:

```text
~/.config/botlab/gh
```

## Basic Rules

- Never print tokens.
- Never commit `.env`, token files, or bot auth/config directories.
- Run `git status` before committing or pushing.
- Use short, clear PR titles and simple PR bodies.
- If opening a bot PR, mention it was opened by `@shravangoswami-bot` for `@shravanngoswamii`.

## What Each Command Means

```bash
botlab gh ...
```

Runs GitHub CLI as the bot account. Use for bot auth, forks, PRs, issues, and repo operations.

```bash
botlab git push origin branch-name
```

Pushes using the bot token. This does not change commit authors.

```bash
botlab identity
```

Sets repo-local git author to `shravangoswami-bot`. Future commits in that repo become bot-authored.

Undo:

```bash
botlab unidentity
```

```bash
botlab coauthor-hook
```

Adds Shravan as co-author to every future commit in that repo.

Undo:

```bash
botlab remove-coauthor-hook
```

## Common Cases

Normal work in Shravan's own project:

- Use regular `git commit`.
- Use regular `git push` unless bot auth is explicitly needed.
- Do not run `botlab identity` or `botlab coauthor-hook`.

Normal commit, but push with bot token:

```bash
git commit -m "Update files"
botlab git push origin branch-name
```

One bot-authored commit with Shravan as co-author:

```bash
git -c user.name="shravangoswami-bot" \
    -c user.email="shravangoswami-bot@users.noreply.github.com" \
    commit -m "Update files" \
    -m "Co-authored-by: shravanngoswamii <shravanngoswamii@users.noreply.github.com>"
```

One normal commit with bot as co-author:

```bash
git commit -m "Update files" \
  -m "Co-authored-by: shravangoswami-bot <shravangoswami-bot@users.noreply.github.com>"
```

Pure AI-agent work in a bot fork:

```bash
botlab gh repo fork OWNER/REPO --clone=true
cd REPO
botlab identity
botlab coauthor-hook
git checkout -b bot/small-change
git add .
git commit -m "Update files"
botlab git push origin bot/small-change
botlab gh pr create --repo OWNER/REPO --head shravangoswami-bot:bot/small-change
```

Check bot auth:

```bash
botlab gh auth status
```
