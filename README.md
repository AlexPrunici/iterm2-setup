# ⚡ iterm2-minimal-setup

> A one-shot script to turn stock iTerm2 into a fast, clean, minimalistic, dev-ready terminal.  

---

## What you get

**Prompt — [Starship](https://starship.rs)**  
Written in Rust. Shows git branch, status, and language versions (Node, Python, Rust, Go) — only when you're inside a relevant project. Nothing else.

**Shell — raw zsh**  
100k history with timestamps, case-insensitive completion, `AUTO_CD` so you can just type a directory name and enter it. No plugin manager, no framework.

**Plugins — standalone**  
- `zsh-autosuggestions` — grey ghost text from your history, press `→` to accept  
- `zsh-syntax-highlighting` — commands turn green when valid, red when not

**CLI tools**  
- [`fzf`](https://github.com/junegunn/fzf) — fuzzy finder, `Ctrl+R` for history search
- [`bat`](https://github.com/sharkdp/bat) — `cat` with syntax highlighting
- [`eza`](https://github.com/eza-community/eza) — `ls` with icons and git status per file
- [`zoxide`](https://github.com/ajeetdsouza/zoxide) — smarter `cd` that learns your dirs, `z proj` gets you there
- [`ripgrep`](https://github.com/BurntSushi/ripgrep) — fast `grep` for searching codebases
- [`fd`](https://github.com/sharkdp/fd) — faster, friendlier `find`
- [`lazygit`](https://github.com/jesseduffield/lazygit) — terminal UI for git

**Visuals**  
- Color scheme: [Catppuccin Macchiato](https://github.com/catppuccin/iterm)
- Font: [JetBrains Mono Nerd Font](https://www.nerdfonts.com/)

---

## Install

```bash
git clone https://github.com/AlexPrunici/iterm2-setup.git
cd iterm2-setup
chmod +x iterm2-setup.sh
./iterm2-setup.sh
```

The script is idempotent — safe to run multiple times. It skips anything already installed and backs up your `.zshrc` before modifying it.

---

## After running

Three things to do manually inside iTerm2 (these can't be scripted without touching raw plist files):

**1. Apply the color scheme**  
`Settings → Profiles → Colors → Color Presets` → select **Catppuccin Macchiato**

**2. Set the font**  
`Settings → Profiles → Text → Font` → select **JetBrainsMono Nerd Font**, size **13**, thin

**3. Enable natural text editing**  
`Settings → Profiles → Keys → Key Bindings → Presets` → **Natural Text Editing**  
This makes `Option+←/→` jump words and `Cmd+Delete` clear the line — like any text editor.

Then reload your shell:

```bash
source ~/.zshrc
```

---

## Aliases added to your shell

```bash
ls    → eza                       # icons, colors
ll    → eza -la --git             # long list with git status
la    → eza -a                    # show hidden files
tree  → eza --tree                # directory tree
cat   → bat                       # syntax highlighted
grep  → rg                        # ripgrep
find  → fd                        # fd
lg    → lazygit                   # git TUI
..    → cd ..
...   → cd ../..
....  → cd ../../..
reload → source ~/.zshrc
```

---

## Requirements

- macOS (Intel or Apple Silicon)
- Internet connection

---

## License

MIT
