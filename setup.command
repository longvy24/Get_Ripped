#!/bin/bash
# ============================================================
# Get Ripped — One-Time GitHub Setup
# ============================================================
# Double-click this file to set up git locally and push to
# your GitHub repo for the first time. After this runs once,
# use deploy.command for all future updates.
# ============================================================

set -e
cd "$(dirname "$0")"

echo ""
echo "🏋️  GET RIPPED — Git/GitHub Setup"
echo "================================="
echo ""
echo "This will:"
echo "  1. Clean up any partial git folder from the sandbox"
echo "  2. Initialize a fresh git repo here"
echo "  3. Connect it to https://github.com/longvy24/Get_Ripped"
echo "  4. Make the initial commit"
echo "  5. Push to GitHub (you'll authenticate when prompted)"
echo ""
read -p "Press ENTER to continue, or Ctrl+C to cancel..." _

# ----- Clean any prior init -----
if [ -d ".git" ]; then
  echo ""
  echo "→ Removing partial .git folder..."
  rm -rf .git
fi

# ----- Verify git is installed -----
if ! command -v git &> /dev/null; then
  echo ""
  echo "⚠️  Git isn't installed. Install it with:"
  echo "    xcode-select --install"
  echo ""
  echo "Then double-click this file again."
  exit 1
fi

# ----- Initialize -----
echo ""
echo "→ Initializing git repo..."
git init -b main

git config user.email "longvy24@gmail.com"
git config user.name "Long"

# ----- Add the remote -----
echo "→ Connecting to https://github.com/longvy24/Get_Ripped.git ..."
git remote add origin https://github.com/longvy24/Get_Ripped.git

# ----- Stage files -----
echo "→ Adding files..."
git add -A
git status --short

# ----- Commit -----
echo ""
echo "→ Creating initial commit..."
git commit -m "Initial commit: 120-day Get Ripped plan as standalone app"

# ----- Push -----
echo ""
echo "→ Pushing to GitHub. You'll be asked to authenticate."
echo "  • Username: longvy24"
echo "  • Password: paste a Personal Access Token (NOT your GitHub password)"
echo "    Create one at: https://github.com/settings/tokens"
echo "    Permissions needed: repo (full control)"
echo ""

# If GitHub has an existing README on main, this may fail with non-fast-forward.
# In that case, pull --rebase and retry.
if ! git push -u origin main; then
  echo ""
  echo "⚠️  Push failed. The repo likely already has commits."
  echo "→ Pulling remote changes and retrying..."
  git pull --rebase origin main --allow-unrelated-histories || true
  git push -u origin main
fi

echo ""
echo "✅  Done! Your site is deploying."
echo ""
echo "Next steps:"
echo "  1. Wait 1-2 minutes for GitHub Pages to build"
echo "  2. Go to: https://github.com/longvy24/Get_Ripped/settings/pages"
echo "  3. Source: 'Deploy from a branch' → Branch: main → Folder: / (root) → Save"
echo "  4. After build finishes, visit: https://longvy24.github.io/Get_Ripped/"
echo ""
echo "For future updates, double-click deploy.command"
echo ""
read -p "Press ENTER to close this window..." _
