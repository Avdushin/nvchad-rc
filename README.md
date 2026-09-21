# Neovim configuration

My current standalone Neovim configuration.

## Demo

![](./imgs/1.jpg)  
![](./imgs/2.jpg)  
![](./imgs/3.jpg)  
![](./imgs/4.jpg)  
![](./imgs/5.jpg)  
![](./imgs/6.jpg)

> Historical note: this repository used to contain my NvChad configuration.
> The repository name is kept for continuity, but the current config is a
> standalone Neovim configuration installed as the standard `~/.config/nvim` profile.

## Install

The easiest way to install this config on a Linux workstation, Linux server, or macOS machine is:

```bash
curl -fsSL https://raw.githubusercontent.com/Avdushin/nvchad-rc/main/install.sh | bash
```

After installation, start Neovim normally:

```bash
nvim
```

The installer replaces the standard Neovim profile at `~/.config/nvim`.

The installer:

- supports Linux and macOS;
- supports x86_64 / amd64 and arm64 / Apple Silicon;
- installs missing system dependencies;
- installs a recent Neovim when the existing version is too old for this config;
- keeps an existing system Neovim installation untouched;
- installs Node.js, Go and tree-sitter CLI when required;
- clones this repository into `~/.config/nvim`;
- installs plugins with lazy.nvim;
- installs configured LSP servers and formatters with Mason;
- installs the configured Tree-sitter parsers;
- verifies the installation before finishing.

### Existing Neovim configuration

If another Neovim profile already exists, the installer does **not** delete it.

Before installing this config it moves the existing profile into a timestamped backup directory under:

```text
~/.local/share/nvim-bootstrap-backups/
```

The backup can include:

```text
~/.config/nvim
~/.local/share/nvim
~/.local/state/nvim
~/.cache/nvim
```

At the end of the installation the exact backup path is printed.

If the existing `~/.config/nvim` is already this repository, the installer does not create a backup and instead updates it with:

```bash
git pull --ff-only
```

### Linux

The same one-line installer can be used on a desktop or server:

```bash
curl -fsSL https://raw.githubusercontent.com/Avdushin/nvchad-rc/main/install.sh | bash
```

Supported package managers for missing base packages:

- apt;
- dnf;
- pacman.

### macOS

Use the same command on Intel and Apple Silicon Macs:

```bash
curl -fsSL https://raw.githubusercontent.com/Avdushin/nvchad-rc/main/install.sh | bash
```

The installer uses official prebuilt downloads where possible and does not require Homebrew.

If Xcode Command Line Tools are missing, the installer attempts to install them. If macOS requires interactive confirmation, run:

```bash
xcode-select --install
```

once and then re-run the installer.

## Main UX

- Fog & Ember colorscheme
- relative line numbers
- wrapped long lines
- Snacks explorer, pickers and terminal
- `Ctrl+B` - toggle explorer
- `Ctrl+H/J/K/L` - move between windows
- `Ctrl+`` - toggle floating terminal
- `Ctrl+Shift+J/K` - add multicursor down/up
- Visual `Tab` / `Shift+Tab` - indent/outdent and keep selection
- Visual surround for quotes and brackets
- `leader+q` - cycle quotes inside parentheses
- `Ctrl+Shift+F` - project search; `Ctrl+R` inside results opens replacement workflow
- `leader+w...` - window management
- `Ctrl+Q`, then `q` or `y` - confirmed Neovim exit

---

# Docs

`<leader>` is `Space`.

## General

| Key | Mode | Action |
| --- | --- | --- |
| `;` | Normal | Enter command mode |
| `jk` | Insert | Return to Normal mode |
| `Ctrl+S` | Normal / Insert / Visual | Save file |
| `Esc` | Normal | Clear search highlight |
| `Ctrl+Q`, then `q` or `y` | Normal | Exit Neovim with confirmation |
| `leader+c` | Normal | Copy relative file path |
| `leader+d` | Normal | Duplicate current line |

The quit mapping uses `:confirm qall`, so modified buffers still get Neovim's
normal save/discard confirmation instead of being silently lost.

## Explorer & buffers

The sidebar is powered by Snacks Explorer.

| Key | Action |
| --- | --- |
| `Ctrl+B` | Toggle Explorer |
| `Ctrl+N` | Create a new buffer |
| `Ctrl+W` | Delete current buffer |
| `leader+bd` | Delete current buffer |
| `leader+bo` | Delete all other listed buffers |
| `[b` | Previous buffer |
| `]b` | Next buffer |
| `Ctrl+1..9` | Jump to buffer 1..9 |

Explorer behavior is intentionally customized:

- pressing `Ctrl+B` again closes the sidebar;
- `Esc` does not close the sidebar;
- `Ctrl+T` is disabled inside Explorer;
- `Ctrl+H/J/K/L` moves between Explorer and editor windows;
- the sidebar stays open when focus moves back to the editor.

## Windows & splits

Fast navigation:

| Key | Action |
| --- | --- |
| `Ctrl+H` | Window left |
| `Ctrl+J` | Window down |
| `Ctrl+K` | Window up |
| `Ctrl+L` | Window right |

Leader-based window management:

| Key | Action |
| --- | --- |
| `leader+wv` | Vertical split |
| `leader+ws` | Horizontal split |
| `leader+wq` | Close current window |
| `leader+w=` | Equalize windows |

An additional `Alt+W` prefix is available:

| Key | Action |
| --- | --- |
| `Alt+W h/j/k/l` | Navigate windows |
| `Alt+W w` | Next window |
| `Alt+W v` | Vertical split |
| `Alt+W s` | Horizontal split |
| `Alt+W q` | Close window |
| `Alt+W =` | Equalize windows |

The same navigation prefix works from Terminal mode.

> `Ctrl+W` is intentionally used for deleting the current buffer in this
> config, so use `leader+w...` or `Alt+W...` for window management.

## Search & replace

| Key | Action |
| --- | --- |
| `Ctrl+P` | Find files |
| `Ctrl+F` | Search lines in the current file |
| `Ctrl+Shift+F` | Grep across the project |
| `leader+Space` | Smart find |
| `leader+ff` | Find files |
| `leader+fg` | Grep project |
| `leader+fb` | Buffer picker |
| `leader+fr` | Recent files |
| `leader+fw` | Search current word / Visual selection |
| `leader+fk` | Search keymaps |
| `leader+fh` | Search help |
| `leader+/` | Grep project |

### Replace project search results

Open project search:

```text
Ctrl+Shift+F
```

Enter a search term, then press:

```text
Ctrl+R
```

inside the Snacks grep picker. The current search text is transferred to
GrugFar and focus moves to the replacement field.

Other GrugFar mappings:

| Key | Mode | Action |
| --- | --- | --- |
| `leader+sr` | Normal | Open project search/replace |
| `leader+sr` | Visual | Search/replace using selection |
| `leader+sR` | Visual | Replace within selection |
| `leader+sw` | Normal | Replace word under cursor |

## Terminals

The config keeps separate terminal sessions for bottom, right and floating
layouts.

| Key | Action |
| --- | --- |
| `Ctrl+`` | Toggle floating terminal |
| `Ctrl+E` | Toggle right terminal |
| `leader+tb` | Toggle bottom terminal |
| `leader+tr` | Toggle right terminal |
| `leader+tf` | Toggle floating terminal |
| `leader+tn` | Open a new bottom terminal |
| `leader+tt` | Open terminal in a new tab |
| `leader+tl` | List terminal sessions |
| `Esc Esc` | Leave Terminal mode |

The Snacks-managed bottom/right/floating terminals are persistent: hiding and
showing them reuses the same shell session.

## Editing

### Move lines and selections

| Key | Mode | Action |
| --- | --- | --- |
| `Alt+J` | Normal / Insert | Move line down |
| `Alt+K` | Normal / Insert | Move line up |
| `Alt+J` | Visual | Move selection down |
| `Alt+K` | Visual | Move selection up |
| `Ctrl+Shift+Down` | Normal / Insert / Visual | Move down |
| `Ctrl+Shift+Up` | Normal / Insert / Visual | Move up |

### Visual indentation

Select one or more lines and use:

| Key | Action |
| --- | --- |
| `Tab` | Indent selection and keep it selected |
| `Shift+Tab` | Outdent selection and keep it selected |

### Visual surround

Select text in Visual mode and directly press one of:

```text
(  )  [  ]  {  }  "  '  `
```

The selected text is wrapped with the corresponding pair.

Example:

```text
hello
```

select it and press `"`:

```text
"hello"
```

### Cycle quotes inside parentheses

`leader+q` cycles the quote style of the contents inside the nearest
parentheses:

```text
foo("bar")
foo('bar')
foo(`bar`)
foo("bar")
```

## Multicursor

Powered by `vim-visual-multi`.

| Key | Action |
| --- | --- |
| `Ctrl+D` | Select word / next occurrence |
| `Alt+D` | Select previous occurrence |
| `Ctrl+Shift+J` | Add cursor below |
| `Ctrl+Shift+K` | Add cursor above |
| `Ctrl+X` | Skip current region |
| `Ctrl+Q` | Remove current multicursor region |

### Ghostty note

Ghostty uses `Ctrl+Shift+J` for screen capture by default. To let Neovim
receive that key for multicursor-down, add this to
`~/.config/ghostty/config`:

```ini
keybind = ctrl+shift+j=unbind
```

Then reload or restart Ghostty.

## Formatting

Formatting is handled by `conform.nvim`.

Manual formatting:

| Key | Action |
| --- | --- |
| `Ctrl+Shift+I` | Format file or Visual selection |
| `leader+cf` | Format file or Visual selection |

Formatting on save is enabled where configured, but intentionally skipped for:

- Markdown prose;
- `.env` files.

Configured formatters include:

| File type | Formatter |
| --- | --- |
| Lua | Stylua |
| Python | Ruff |
| Go | goimports + gofmt |
| JavaScript / TypeScript | prettierd, fallback prettier |
| JSON / JSONC / YAML | prettierd, fallback prettier |
| Shell / Bash | shfmt |

Useful commands:

```vim
:FormatDisable
:FormatDisable!
:FormatEnable
:ConformInfo
```

## LSP & completion

Completion is provided by `blink.cmp`. LSP servers are managed through
Mason / `mason-lspconfig.nvim`.

Configured servers:

- Bash: `bashls`
- CSS: `cssls`
- ESLint: `eslint`
- Go: `gopls`
- HTML: `html`
- JSON: `jsonls`
- Lua: `lua_ls`
- Markdown: `marksman`
- Python: `pyright`
- Rust: `rust_analyzer`
- TOML: `taplo`
- JavaScript / TypeScript: `ts_ls`
- YAML: `yamlls`

LSP mappings are attached only when an LSP server is active for the buffer:

| Key | Action |
| --- | --- |
| `gd` | Go to definition |
| `gD` | Go to declaration |
| `gr` | References |
| `gI` | Implementations |
| `gy` | Type definition |
| `K` | Hover documentation |
| `leader+ca` | Code action |
| `leader+cr` | Rename symbol |
| `leader+ss` | Document symbols |
| `leader+sS` | Workspace symbols |
| `leader+cl` | LSP information |
| `leader+uh` | Toggle inlay hints |

Mason also installs the configured development tools such as `stylua`,
`ruff`, `shfmt`, `goimports` and `prettierd`.

## Diagnostics

| Key | Action |
| --- | --- |
| `]d` | Next diagnostic |
| `[d` | Previous diagnostic |
| `leader+xx` | Workspace diagnostics |
| `leader+xX` | Current-buffer diagnostics |

Diagnostics use signs, underlines, virtual text and rounded floating windows.

## Markdown

Rendered Markdown is provided by `render-markdown.nvim`.

| Key | Action |
| --- | --- |
| `leader+mt` | Toggle Markdown rendering |
| `leader+me` | Enable rendering |
| `leader+md` | Disable rendering |

## Theme & editor behavior

The default colorscheme is the custom standalone:

```text
Fog & Ember
```

The theme lives in:

```text
colors/fog-and-ember.lua
```

Notable editor defaults:

- absolute + relative line numbers;
- line wrapping with `linebreak` and `breakindent`;
- `scrolloff=6`;
- `sidescrolloff=8`;
- system clipboard via `unnamedplus`;
- persistent undo;
- no swapfile / backup files;
- rounded floating-window borders;
- splits open below and to the right.

## Configuration layout

```text
.
├── colors/
│   └── fog-and-ember.lua
├── imgs/
├── init.lua
├── lazy-lock.json
└── lua/
    ├── core/
    │   ├── autocmds.lua
    │   ├── keymaps.lua
    │   ├── lazy.lua
    │   ├── options.lua
    │   └── terminal.lua
    └── plugins/
        ├── editor.lua
        ├── init.lua
        ├── lsp.lua
        ├── markdown.lua
        ├── treesitter.lua
        └── ui.lua
```

## Maintenance

Useful commands:

```vim
:Lazy
:Lazy update
:Mason
:LspInfo
:ConformInfo
:checkhealth
```

Plugin revisions are pinned in `lazy-lock.json`.
