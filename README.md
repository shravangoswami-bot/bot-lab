# Bot Lab

Small local setup for making GitHub PRs from `shravangoswami-bot` without changing the main `gh` account.

The script keeps bot GitHub CLI config in `~/.config/bot-pr/gh`. Git stays normal: clone, edit, commit, and push like usual.

## Install

```bash
curl -fsSL https://github.com/shravangoswami-bot/bot-lab/releases/latest/download/install.sh | sh
```

Re-run the same command later to update. Make sure `~/.local/bin` is in `PATH`.

For local development:

```bash
scripts/bot-pr install
```

## Commands

```bash
cd /home/seeker/Work/vectorly-ai/bot-lab

bot-pr auth
bot-pr auth status
bot-pr gh repo fork OWNER/REPO --clone=true
```

Then work with regular git:

```bash
cd REPO
bot-pr identity
bot-pr coauthor-hook

git checkout -b branch-name
git add .
git commit -m "Update files"
bot-pr git push origin branch-name
```

Open the PR with bot-scoped `gh`:

```bash
bot-pr gh pr create \
  --repo OWNER/REPO \
  --head shravangoswami-bot:branch-name \
  --title "Update files" \
  --body-file pr-body.md
```

You can also run git through the script if you prefer:

```bash
bot-pr git push origin branch-name
```

## AI Agent Notes

Use this flow when asked to contribute from the bot account:

1. Run `bot-pr auth status`.
2. Fork or clone using `bot-pr gh ...`.
3. Run `bot-pr identity` inside the cloned repo.
4. Run `bot-pr coauthor-hook` inside the cloned repo.
5. Use normal `git add`, `git commit`, and `git status`.
6. Push using `bot-pr git push origin branch-name`.
7. Open PRs using `bot-pr gh pr create ...`.

Do not use the normal global `gh` config for bot work. Do not print tokens. Keep PR wording simple and mention that the PR is opened by `@shravangoswami-bot` for `@shravanngoswamii`.

For commits, use the bot as author and add this trailer when useful:

```text
Co-authored-by: shravanngoswamii <shravanngoswamii@users.noreply.github.com>
```

## Example

```bash
bot-pr gh repo fork TuringLang/AbstractMCMC.jl --clone=true
cd AbstractMCMC.jl
bot-pr identity
bot-pr coauthor-hook
git checkout -b bot/update-readme
git status
git add README.md
git commit -m "Update README"
bot-pr git push origin bot/update-readme
bot-pr gh pr create \
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
export GH_CONFIG_DIR=~/.config/bot-pr/gh
```

## Release

Update `package.json` version and push to `main`. The release workflow creates a tag and publishes the install assets.
