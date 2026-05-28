# Deploy Guide — Push Get Ripped to Your GitHub Pages Site

This folder is set up to publish your plan as a live site at:

**🌐 https://longvy24.github.io/Get_Ripped/**

You'll do this **once** with `setup.command`, then use `deploy.command` for all future updates.

---

## One-Time First Push

### Step 1 — Get a GitHub Personal Access Token (PAT)

GitHub no longer accepts your account password for `git push`. You need a PAT:

1. Go to https://github.com/settings/tokens
2. Click **Generate new token → Generate new token (classic)**
3. Note: `Get Ripped deploy`
4. Expiration: 1 year (or whatever feels right)
5. Check the box: **repo** (gives full control of your repos)
6. Scroll down, click **Generate token**
7. **Copy the token now** — looks like `ghp_xxxxxxxxxxxxxxxxxx`. You won't see it again.

Stash that token somewhere safe (password manager, Notes app — anywhere you can find it once).

### Step 2 — Run setup.command

1. Open Finder → navigate to this folder
2. Right-click `setup.command` → **Open** (first time only — bypasses the macOS "unidentified developer" warning)
3. Hit ENTER through the prompts
4. When git asks for your username: type `longvy24`
5. When git asks for your password: **paste the PAT** (your characters won't show — that's normal — just paste and hit ENTER)
6. macOS will offer to save it in Keychain — say **yes**. You won't have to paste it again.

If everything worked, you'll see `✅ Done!` at the end.

### Step 3 — Enable GitHub Pages

1. Go to https://github.com/longvy24/Get_Ripped/settings/pages
2. Under **Build and deployment** → Source: **Deploy from a branch**
3. Branch: **main** · Folder: **/ (root)** · Click **Save**
4. GitHub shows a yellow circle for 1–2 minutes while it builds
5. When it turns green, visit **https://longvy24.github.io/Get_Ripped/**

You now have a live, public site.

---

## Updating the Site (Every Future Push)

Whenever I (or you) make changes to `index.html`, or you want to back up your saved progress:

1. Double-click **deploy.command**
2. (Optional) Type a commit message, or press ENTER to use the timestamp
3. Wait ~5 seconds
4. GitHub Pages rebuilds in 1–2 minutes — your live site is updated

That's it. No git knowledge required.

---

## Common Issues

**"setup.command can't be opened because the developer is unidentified"**
→ Right-click the file → Open. Click Open again in the dialog. Only needed the first time per file.

**"Authentication failed"**
→ Your PAT expired or was typed wrong. Generate a new one at https://github.com/settings/tokens and re-run setup.command.

**"fatal: refusing to merge unrelated histories"**
→ The setup script handles this automatically. If you see it manually, run: `git pull origin main --allow-unrelated-histories`

**"Permission denied (publickey)"**
→ You're trying to use SSH but the remote is HTTPS. The scripts use HTTPS, so this shouldn't happen — but if it does, run: `git remote set-url origin https://github.com/longvy24/Get_Ripped.git`

**Want to push from a different device?**
→ Clone the repo there: `git clone https://github.com/longvy24/Get_Ripped.git`. Then the scripts work from that copy too.

---

## What Each Command Does

| File | Run when | What it does |
|---|---|---|
| `setup.command` | One time, first push | Initializes git, connects to GitHub, makes initial commit, pushes |
| `deploy.command` | Every update | `git add -A && git commit && git push` |
| `index.html` | (don't run) | The actual app — served by GitHub Pages |
| `README.md` | (don't run) | Shown on the GitHub repo page |
| `.gitignore` | (don't run) | Tells git to skip `.DS_Store`, backups, etc |

---

## Alternative: GitHub Desktop (No Terminal)

If you'd rather not use the .command scripts:

1. Install [GitHub Desktop](https://desktop.github.com/)
2. Open it, sign in to GitHub
3. File → Add Local Repository → choose this folder
4. It'll detect the files; commit and push with the UI
5. Auth is handled automatically via GitHub Desktop's OAuth — no PAT needed

The .command scripts are faster for ongoing updates, but Desktop is great if you want a visual git workflow.
