# Bot Lab

Small local helper for making GitHub PRs from `shravangoswami-bot` without changing the main `gh` account.

`botlab` keeps bot GitHub CLI config in `~/.config/botlab/gh`. Git stays normal: clone, edit, commit, and push like usual.

## Install

```bash
curl -fsSL https://github.com/shravangoswami-bot/bot-lab/releases/latest/download/install.sh | sh
```

Re-run the same command later to update. The installer adds `~/.local/bin` to your shell profile when needed.

For local development:

```bash
scripts/botlab install
```

## Commands

```bash
cd /home/seeker/Work/vectorly-ai/bot-lab

botlab gh auth login
botlab gh auth status
botlab gh repo fork OWNER/REPO --clone=true
```

Then work with regular git:

```bash
cd REPO
botlab identity
botlab coauthor-hook

git checkout -b branch-name
git add .
git commit -m "Update files"
botlab git push origin branch-name
```

Open the PR with bot-scoped `gh`:

```bash
botlab gh pr create \
  --repo OWNER/REPO \
  --head shravangoswami-bot:branch-name \
  --title "Update files" \
  --body-file pr-body.md
```

You can also run git through the script if you prefer:

```bash
botlab git push origin branch-name
```

## AI Agent Notes

Use this flow when asked to contribute from the bot account:

1. Run `botlab gh auth status`.
2. Fork or clone using `botlab gh ...`.
3. Run `botlab identity` inside the cloned repo.
4. Run `botlab coauthor-hook` inside the cloned repo.
5. Use normal `git add`, `git commit`, and `git status`.
6. Push using `botlab git push origin branch-name`.
7. Open PRs using `botlab gh pr create ...`.

For pure AI-agent work in a bot fork, always use `botlab`. For your own org projects, you can still work directly in the repo; some commits can be authored by you, and bot commits can use `botlab identity` with you as co-author.

Do not use the normal global `gh` config for bot work. Do not print tokens. Keep PR wording simple and mention that the PR is opened by `@shravangoswami-bot` for `@shravanngoswamii`.

For commits, use the bot as author and add this trailer when useful:

```text
Co-authored-by: shravanngoswamii <shravanngoswamii@users.noreply.github.com>
```

## Example

```bash
botlab gh auth status
botlab gh repo fork TuringLang/AbstractMCMC.jl --clone=true
cd AbstractMCMC.jl
botlab identity
botlab coauthor-hook
git checkout -b bot/update-readme
git status
git add README.md
git commit -m "Update README"
botlab git push origin bot/update-readme
botlab gh pr create \
  --repo TuringLang/AbstractMCMC.jl \
  --head shravangoswami-bot:bot/update-readme \
  --title "Update README" \
  --body-file pr-body.md
```

## Config

Optional environment variables:

```bash
export BOT_OWNER=shravangoswami-bot
export BOT_EMAIL=shravangoswami-bot@users.noreply.github.com
export COAUTHOR_NAME=shravanngoswamii
export COAUTHOR_EMAIL=shravanngoswamii@users.noreply.github.com
export GH_CONFIG_DIR=~/.config/botlab/gh
```

## Release

Update `package.json` version and push to `main`. The release workflow creates a tag and publishes the install assets.
