#!/bin/bash
# ============================================================
# Get Ripped — Deploy Updates to GitHub Pages
# ============================================================
# Double-click this file any time you want to push updates
# (or your saved progress) to your live GitHub Pages site.
# ============================================================

cd "$(dirname "$0")"

echo ""
echo "🏋️  GET RIPPED — Deploying to GitHub Pages"
echo "==========================================="

# Check that git is initialized
if [ ! -d ".git" ]; then
  echo ""
  echo "⚠️  Git isn't set up yet."
  echo "→ Double-click setup.command first, then come back here."
  echo ""
  read -p "Press ENTER to close..." _
  exit 1
fi

# Clean up stale lock files from interrupted operations
if [ -f ".git/index.lock" ]; then
  echo "→ Cleaning stale git lock file..."
  rm -f .git/index.lock
fi

# Verify remote is configured
if ! git remote get-url origin &>/dev/null; then
  echo ""
  echo "⚠️  No 'origin' remote configured. Setting it now..."
  git remote add origin https://github.com/longvy24/Get_Ripped.git
fi

# Make sure we're on main
CURRENT_BRANCH=$(git symbolic-ref --short HEAD 2>/dev/null || echo "")
if [ -z "$CURRENT_BRANCH" ]; then
  echo "→ No branch yet. Creating main..."
  git checkout -b main 2>/dev/null || git branch -m main
elif [ "$CURRENT_BRANCH" != "main" ]; then
  echo "→ Switching to main branch (was on: $CURRENT_BRANCH)..."
  git branch -m main 2>/dev/null || git checkout -b main
fi

# Show what's changed
echo ""
echo "→ Files that changed since last push:"
git status --short
echo ""

# Bail if nothing to do (and we already have upstream)
if [ -z "$(git status --porcelain)" ] && git rev-parse --abbrev-ref --symbolic-full-name '@{u}' &>/dev/null; then
  echo "Nothing to commit and upstream is set. Your repo is up to date."
  read -p "Press ENTER to close..." _
  exit 0
fi

# Stage and commit if there are changes
if [ -n "$(git status --porcelain)" ]; then
  DEFAULT_MSG="Update — $(date '+%Y-%m-%d %H:%M')"
  read -p "Commit message (press ENTER for '$DEFAULT_MSG'): " MSG
  MSG="${MSG:-$DEFAULT_MSG}"

  echo ""
  echo "→ Staging files..."
  git add -A
  echo "→ Committing: $MSG"
  if ! git commit -m "$MSG"; then
    echo ""
    echo "⚠️  Commit failed. Trying to fix common issues..."

    # Make sure user identity is set (required for commits)
    if ! git config user.email &>/dev/null; then
      git config user.email "longvy24@gmail.com"
      git config user.name "Long"
      git commit -m "$MSG" || {
        echo "❌ Commit still failed. Check the error above and try again."
        read -p "Press ENTER to close..." _
        exit 1
      }
    fi
  fi
fi

# Push — handle first-push (no upstream) automatically
echo "→ Pushing to GitHub..."
if git rev-parse --abbrev-ref --symbolic-full-name '@{u}' &>/dev/null; then
  # Upstream exists, normal push
  PUSH_CMD="git push"
else
  # First push, set upstream
  echo "  (first push — setting upstream tracking)"
  PUSH_CMD="git push -u origin main"
fi

if $PUSH_CMD; then
  echo ""
  echo "✅  Push complete. GitHub Pages will rebuild in 1-2 minutes."
  echo "    Live at: https://longvy24.github.io/Get_Ripped/"
  echo ""
else
  echo ""
  echo "❌  Push FAILED. Common fixes:"
  echo ""
  echo "  1. Authentication failed?"
  echo "     → Generate a new Personal Access Token:"
  echo "       https://github.com/settings/tokens (check 'repo')"
  echo "     → Re-run this script and paste it as the password"
  echo ""
  echo "  2. 'Updates were rejected because the remote contains work...'"
  echo "     → The repo on GitHub has commits this local copy doesn't."
  echo "     → Run this in Terminal to merge:"
  echo "       cd \"$(pwd)\""
  echo "       git pull --rebase origin main --allow-unrelated-histories"
  echo "       then re-run this script"
  echo ""
  echo "  3. Repository doesn't exist?"
  echo "     → Make sure https://github.com/longvy24/Get_Ripped exists"
  echo ""
  read -p "Press ENTER to close..." _
  exit 1
fi

read -p "Press ENTER to close..." _
