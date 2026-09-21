#!/usr/bin/env bash
set -Eeuo pipefail

REPO_URL="${REPO_URL:-https://github.com/Avdushin/nvchad-rc.git}"
CONFIG_ROOT="${XDG_CONFIG_HOME:-$HOME/.config}"
DATA_ROOT="${XDG_DATA_HOME:-$HOME/.local/share}"
STATE_ROOT="${XDG_STATE_HOME:-$HOME/.local/state}"
CACHE_ROOT="${XDG_CACHE_HOME:-$HOME/.cache}"

CONFIG_DIR="$CONFIG_ROOT/nvim"
DATA_DIR="$DATA_ROOT/nvim"
STATE_DIR="$STATE_ROOT/nvim"
CACHE_DIR="$CACHE_ROOT/nvim"

LOCAL_BIN="$HOME/.local/bin"
LOCAL_OPT="$HOME/.local/opt"
BACKUP_ROOT="${BACKUP_ROOT:-$HOME/.local/share/nvim-bootstrap-backups}"
BACKUP_STAMP="$(date +%Y%m%d%H%M%S)"
BACKUP_DIR="$BACKUP_ROOT/${BACKUP_STAMP}-nvim"
BACKUP_USED=0

MIN_NVIM_VERSION="0.12.0"
MIN_TREE_SITTER_VERSION="0.26.1"
RIPGREP_VERSION="15.2.0"

OS=""
CPU_ARCH=""
NVIM_ASSET=""
NODE_PLATFORM=""
GO_OS=""
GO_ARCH=""
TREE_SITTER_ASSET=""
RIPGREP_TRIPLE=""
NVIM_BIN=""

log() {
  printf '\n\033[1;34m==>\033[0m %s\n' "$*"
}

warn() {
  printf '\033[1;33mwarning:\033[0m %s\n' "$*" >&2
}

die() {
  printf '\033[1;31merror:\033[0m %s\n' "$*" >&2
  exit 1
}

version_ge() {
  local have="$1" need="$2"
  local h1=0 h2=0 h3=0 n1=0 n2=0 n3=0

  IFS=. read -r h1 h2 h3 <<<"${have%%-*}"
  IFS=. read -r n1 n2 n3 <<<"${need%%-*}"

  h1="${h1:-0}"; h2="${h2:-0}"; h3="${h3:-0}"
  n1="${n1:-0}"; n2="${n2:-0}"; n3="${n3:-0}"

  (( 10#$h1 > 10#$n1 )) ||
    { (( 10#$h1 == 10#$n1 )) && (( 10#$h2 > 10#$n2 )); } ||
    { (( 10#$h1 == 10#$n1 )) && (( 10#$h2 == 10#$n2 )) && (( 10#$h3 >= 10#$n3 )); }
}

run_root() {
  if (( EUID == 0 )); then
    "$@"
  elif command -v sudo >/dev/null 2>&1; then
    sudo "$@"
  else
    die "System packages are missing and sudo is not available. Run as root or install the prerequisites manually."
  fi
}

ensure_backup_dir() {
  if (( BACKUP_USED == 0 )); then
    mkdir -p "$BACKUP_DIR"
    BACKUP_USED=1
  fi
}

backup_item() {
  local source="$1" relative="$2"
  if [[ ! -e "$source" && ! -L "$source" ]]; then
    return
  fi

  ensure_backup_dir
  mkdir -p "$(dirname "$BACKUP_DIR/$relative")"
  log "Backing up $source"
  mv "$source" "$BACKUP_DIR/$relative"
}

safe_symlink() {
  local target="$1" link="$2" backup_name="$3"

  if [[ -L "$link" ]]; then
    if [[ "$(readlink "$link" 2>/dev/null || true)" == "$target" ]]; then
      return
    fi
    backup_item "$link" "local-bin/$backup_name"
  elif [[ -e "$link" ]]; then
    backup_item "$link" "local-bin/$backup_name"
  fi

  ln -sfn "$target" "$link"
}

ensure_local_path() {
  mkdir -p "$LOCAL_BIN" "$LOCAL_OPT"
  export PATH="$LOCAL_BIN:$PATH"

  local line='export PATH="$HOME/.local/bin:$PATH"'
  local rc

  for rc in "$HOME/.profile" "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.zprofile"; do
    case "$rc" in
      "$HOME/.profile") ;;
      "$HOME/.bashrc") [[ "${SHELL:-}" == */bash ]] || [[ -f "$rc" ]] || continue ;;
      "$HOME/.zshrc"|"$HOME/.zprofile") [[ "${SHELL:-}" == */zsh ]] || [[ -f "$rc" ]] || continue ;;
    esac

    touch "$rc"
    if ! grep -Fqx "$line" "$rc" 2>/dev/null; then
      printf '\n%s\n' "$line" >>"$rc"
    fi
  done
}

detect_platform() {
  OS="$(uname -s)"
  CPU_ARCH="$(uname -m)"

  case "$OS" in
    Linux)
      GO_OS="linux"
      case "$CPU_ARCH" in
        x86_64|amd64)
          NVIM_ASSET="nvim-linux-x86_64"
          NODE_PLATFORM="linux-x64"
          GO_ARCH="amd64"
          TREE_SITTER_ASSET="tree-sitter-cli-linux-x64.zip"
          ;;
        aarch64|arm64)
          NVIM_ASSET="nvim-linux-arm64"
          NODE_PLATFORM="linux-arm64"
          GO_ARCH="arm64"
          TREE_SITTER_ASSET="tree-sitter-cli-linux-arm64.zip"
          ;;
        *)
          die "Unsupported Linux CPU architecture: $CPU_ARCH. Supported: x86_64, arm64."
          ;;
      esac
      ;;

    Darwin)
      GO_OS="darwin"
      case "$CPU_ARCH" in
        arm64|aarch64)
          NVIM_ASSET="nvim-macos-arm64"
          NODE_PLATFORM="darwin-arm64"
          GO_ARCH="arm64"
          TREE_SITTER_ASSET="tree-sitter-cli-macos-arm64.zip"
          RIPGREP_TRIPLE="aarch64-apple-darwin"
          ;;
        x86_64|amd64)
          NVIM_ASSET="nvim-macos-x86_64"
          NODE_PLATFORM="darwin-x64"
          GO_ARCH="amd64"
          TREE_SITTER_ASSET="tree-sitter-cli-macos-x64.zip"
          RIPGREP_TRIPLE="x86_64-apple-darwin"
          ;;
        *)
          die "Unsupported macOS CPU architecture: $CPU_ARCH. Supported: arm64, x86_64."
          ;;
      esac
      ;;

    *)
      die "Unsupported operating system: $OS. Supported: Linux and macOS."
      ;;
  esac
}

have_linux_dependencies() {
  command -v git >/dev/null 2>&1 &&
    command -v curl >/dev/null 2>&1 &&
    command -v unzip >/dev/null 2>&1 &&
    command -v tar >/dev/null 2>&1 &&
    command -v gzip >/dev/null 2>&1 &&
    command -v cc >/dev/null 2>&1 &&
    command -v rg >/dev/null 2>&1
}

install_linux_dependencies() {
  if have_linux_dependencies; then
    log "System dependencies are already installed"
    return
  fi

  log "Installing Linux system dependencies"

  if command -v apt-get >/dev/null 2>&1; then
    run_root env DEBIAN_FRONTEND=noninteractive apt-get update
    run_root env DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      ca-certificates curl git unzip tar gzip \
      build-essential ripgrep \
      python3 python3-venv
  elif command -v dnf >/dev/null 2>&1; then
    run_root dnf install -y \
      ca-certificates curl git unzip tar gzip \
      gcc gcc-c++ make ripgrep \
      python3
  elif command -v pacman >/dev/null 2>&1; then
    run_root pacman -Sy --needed --noconfirm \
      ca-certificates curl git unzip tar gzip \
      base-devel ripgrep \
      python
  else
    die "Unsupported Linux package manager. Supported: apt, dnf, pacman."
  fi

  have_linux_dependencies || die "Some required Linux system dependencies are still missing."
}

have_macos_clt() {
  /usr/bin/xcode-select -p >/dev/null 2>&1 &&
    command -v git >/dev/null 2>&1 &&
    command -v cc >/dev/null 2>&1
}

install_macos_clt() {
  if have_macos_clt; then
    log "Xcode Command Line Tools are already installed"
    return
  fi

  log "Installing Xcode Command Line Tools"

  local placeholder="/tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress"
  local label=""

  run_root /usr/bin/touch "$placeholder"

  label="$(
    /usr/sbin/softwareupdate -l 2>&1 |
      grep -B 1 -E 'Command Line Tools' |
      awk -F'*' '/^ *\*/ {print $2}' |
      sed -e 's/^ *Label: //' -e 's/^ *//' |
      tail -n1 || true
  )"

  if [[ -z "$label" ]]; then
    run_root /bin/rm -f "$placeholder"
    die "Could not find Xcode Command Line Tools via softwareupdate. Run 'xcode-select --install' once, then re-run this installer."
  fi

  if ! run_root /usr/sbin/softwareupdate -i "$label"; then
    run_root /bin/rm -f "$placeholder"
    die "Xcode Command Line Tools installation failed."
  fi

  run_root /bin/rm -f "$placeholder"
  run_root /usr/bin/xcode-select --switch /Library/Developer/CommandLineTools

  have_macos_clt || die "Xcode Command Line Tools are still unavailable after installation."
}

install_macos_ripgrep() {
  if command -v rg >/dev/null 2>&1; then
    log "ripgrep is already installed"
    return
  fi

  log "Installing ripgrep $RIPGREP_VERSION"

  local tmp archive extracted target
  tmp="$(mktemp -d)"
  archive="$tmp/rg.tar.gz"

  curl -fL --retry 3 \
    "https://github.com/BurntSushi/ripgrep/releases/download/${RIPGREP_VERSION}/ripgrep-${RIPGREP_VERSION}-${RIPGREP_TRIPLE}.tar.gz" \
    -o "$archive"

  tar -xzf "$archive" -C "$tmp"
  extracted="$tmp/ripgrep-${RIPGREP_VERSION}-${RIPGREP_TRIPLE}/rg"
  [[ -x "$extracted" ]] || die "Downloaded ripgrep archive has an unexpected layout."

  target="$LOCAL_OPT/nvim-bootstrap-ripgrep"
  rm -rf "$target"
  mkdir -p "$target/bin"
  mv "$extracted" "$target/bin/rg"
  chmod +x "$target/bin/rg"
  safe_symlink "$target/bin/rg" "$LOCAL_BIN/rg" "rg"
  hash -r
  rm -rf "$tmp"

  command -v rg >/dev/null 2>&1 || die "ripgrep installation verification failed."
}

install_system_dependencies() {
  case "$OS" in
    Linux)
      install_linux_dependencies
      ;;
    Darwin)
      command -v curl >/dev/null 2>&1 || die "curl is required on macOS."
      command -v tar >/dev/null 2>&1 || die "tar is required on macOS."
      command -v unzip >/dev/null 2>&1 || die "unzip is required on macOS."
      command -v gzip >/dev/null 2>&1 || die "gzip is required on macOS."
      install_macos_clt
      install_macos_ripgrep
      ;;
  esac
}

nvim_version() {
  "$1" --version 2>/dev/null | sed -n '1s/^NVIM v\([0-9][0-9.]*\).*$/\1/p'
}

install_neovim() {
  local existing="" version=""

  if command -v nvim >/dev/null 2>&1; then
    existing="$(command -v nvim)"
    version="$(nvim_version "$existing")"
    if [[ -n "$version" ]] && version_ge "$version" "$MIN_NVIM_VERSION"; then
      NVIM_BIN="$existing"
      log "Neovim $version is already installed: $NVIM_BIN"
      return
    fi
    warn "Found Neovim ${version:-unknown} at $existing, but this config requires >= $MIN_NVIM_VERSION. The existing installation will be kept untouched."
  fi

  log "Installing latest stable Neovim"

  local tmp archive extracted target
  tmp="$(mktemp -d)"
  archive="$tmp/nvim.tar.gz"

  curl -fL --retry 3 \
    "https://github.com/neovim/neovim/releases/latest/download/${NVIM_ASSET}.tar.gz" \
    -o "$archive"

  if [[ "$OS" == "Darwin" ]] && command -v xattr >/dev/null 2>&1; then
    xattr -c "$archive" 2>/dev/null || true
  fi

  tar -xzf "$archive" -C "$tmp"
  extracted="$tmp/$NVIM_ASSET"
  [[ -x "$extracted/bin/nvim" ]] || die "Downloaded Neovim archive has an unexpected layout."

  target="$LOCAL_OPT/nvim-bootstrap-neovim"
  rm -rf "$target"
  mv "$extracted" "$target"
  safe_symlink "$target/bin/nvim" "$LOCAL_BIN/nvim" "nvim"
  hash -r

  NVIM_BIN="$LOCAL_BIN/nvim"
  version="$(nvim_version "$NVIM_BIN")"
  [[ -n "$version" ]] && version_ge "$version" "$MIN_NVIM_VERSION" \
    || die "Installed Neovim is too old: ${version:-unknown}"

  rm -rf "$tmp"
  log "Installed Neovim $version: $NVIM_BIN"
}

node_version() {
  node --version 2>/dev/null | sed -n '1s/^v\([0-9][0-9.]*\).*$/\1/p'
}

install_node() {
  log "Checking Node.js"

  local latest latest_num current tmp archive extracted target
  latest="$(curl -fsSL --retry 3 https://nodejs.org/dist/index.tab | awk -F '\t' 'NR > 1 && $10 != "-" && !found { print $1; found=1 }')"
  [[ "$latest" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]] || die "Could not determine latest Node.js LTS version."
  latest_num="${latest#v}"
  current="$(node_version || true)"

  if [[ -n "$current" ]] && version_ge "$current" "$latest_num"; then
    log "Node.js $current is already recent enough"
    return
  fi

  log "Installing Node.js LTS $latest"
  tmp="$(mktemp -d)"
  archive="$tmp/node.tar.gz"

  curl -fL --retry 3 \
    "https://nodejs.org/dist/${latest}/node-${latest}-${NODE_PLATFORM}.tar.gz" \
    -o "$archive"

  tar -xzf "$archive" -C "$tmp"
  extracted="$tmp/node-${latest}-${NODE_PLATFORM}"
  [[ -x "$extracted/bin/node" ]] || die "Downloaded Node.js archive has an unexpected layout."

  target="$LOCAL_OPT/nvim-bootstrap-node"
  rm -rf "$target"
  mv "$extracted" "$target"

  local bin
  for bin in node npm npx corepack; do
    if [[ -e "$target/bin/$bin" ]]; then
      safe_symlink "$target/bin/$bin" "$LOCAL_BIN/$bin" "$bin"
    fi
  done

  hash -r
  rm -rf "$tmp"

  current="$(node_version)"
  [[ -n "$current" ]] && version_ge "$current" "$latest_num" \
    || die "Node.js installation verification failed."
  log "Installed Node.js $current"
}

go_version() {
  go version 2>/dev/null | sed -n 's/.* go\([0-9][0-9.]*\) .*/\1/p'
}

install_go() {
  log "Checking Go toolchain"

  local latest latest_num current tmp archive target
  latest="$(curl -fsSL --retry 3 'https://go.dev/VERSION?m=text' | sed -n '1p')"
  [[ "$latest" =~ ^go[0-9]+\.[0-9]+(\.[0-9]+)?$ ]] || die "Could not determine latest Go version."
  latest_num="${latest#go}"
  current="$(go_version || true)"

  if [[ -n "$current" ]] && version_ge "$current" "$latest_num"; then
    log "Go $current is already recent enough"
    return
  fi

  log "Installing Go $latest"
  tmp="$(mktemp -d)"
  archive="$tmp/go.tar.gz"

  curl -fL --retry 3 \
    "https://go.dev/dl/${latest}.${GO_OS}-${GO_ARCH}.tar.gz" \
    -o "$archive"

  tar -xzf "$archive" -C "$tmp"
  [[ -x "$tmp/go/bin/go" ]] || die "Downloaded Go archive has an unexpected layout."

  target="$LOCAL_OPT/nvim-bootstrap-go"
  rm -rf "$target"
  mv "$tmp/go" "$target"
  safe_symlink "$target/bin/go" "$LOCAL_BIN/go" "go"
  safe_symlink "$target/bin/gofmt" "$LOCAL_BIN/gofmt" "gofmt"
  hash -r
  rm -rf "$tmp"

  current="$(go_version)"
  [[ -n "$current" ]] && version_ge "$current" "$latest_num" \
    || die "Go installation verification failed."
  log "Installed Go $current"
}

tree_sitter_version() {
  "$1" --version 2>/dev/null | sed -n '1s/^tree-sitter \([0-9][0-9.]*\).*$/\1/p'
}

install_tree_sitter() {
  local existing="" version=""

  if command -v tree-sitter >/dev/null 2>&1; then
    existing="$(command -v tree-sitter)"
    version="$(tree_sitter_version "$existing")"
    if [[ -n "$version" ]] && version_ge "$version" "$MIN_TREE_SITTER_VERSION"; then
      log "tree-sitter CLI $version is already installed: $existing"
      return
    fi
    warn "Found tree-sitter ${version:-unknown}, but nvim-treesitter requires >= $MIN_TREE_SITTER_VERSION"
  fi

  log "Installing latest tree-sitter CLI"

  local tmp archive binary target
  tmp="$(mktemp -d)"
  archive="$tmp/tree-sitter.zip"

  curl -fL --retry 3 \
    "https://github.com/tree-sitter/tree-sitter/releases/latest/download/${TREE_SITTER_ASSET}" \
    -o "$archive"

  unzip -q "$archive" -d "$tmp/tree-sitter-extracted"
  binary="$(find "$tmp/tree-sitter-extracted" -type f -name tree-sitter | sed -n '1p')"
  [[ -n "$binary" ]] || die "Downloaded tree-sitter archive has an unexpected layout."

  if [[ "$OS" == "Darwin" ]] && command -v xattr >/dev/null 2>&1; then
    xattr -c "$binary" 2>/dev/null || true
  fi

  target="$LOCAL_OPT/nvim-bootstrap-tree-sitter"
  rm -rf "$target"
  mkdir -p "$target/bin"
  mv "$binary" "$target/bin/tree-sitter"
  chmod +x "$target/bin/tree-sitter"
  safe_symlink "$target/bin/tree-sitter" "$LOCAL_BIN/tree-sitter" "tree-sitter"
  hash -r
  rm -rf "$tmp"

  version="$(tree_sitter_version "$LOCAL_BIN/tree-sitter")"
  [[ -n "$version" ]] && version_ge "$version" "$MIN_TREE_SITTER_VERSION" \
    || die "Installed tree-sitter CLI is too old or cannot run: ${version:-unknown}"

  log "Installed tree-sitter CLI $version"
}

backup_existing_profile() {
  local found=0
  local path

  for path in "$CONFIG_DIR" "$DATA_DIR" "$STATE_DIR" "$CACHE_DIR"; do
    if [[ -e "$path" || -L "$path" ]]; then
      found=1
      break
    fi
  done

  (( found == 1 )) || return

  warn "Existing Neovim profile detected. It will be moved to a backup before installation."
  backup_item "$CONFIG_DIR" "config"
  backup_item "$DATA_DIR" "data"
  backup_item "$STATE_DIR" "state"
  backup_item "$CACHE_DIR" "cache"
}

clone_config() {
  log "Installing Neovim config into $CONFIG_DIR"
  mkdir -p "$CONFIG_ROOT"
  git clone --depth 1 --branch main "$REPO_URL" "$CONFIG_DIR"
}

run_nvim() {
  env NVIM_BOOTSTRAP=1 "$NVIM_BIN" "$@"
}

install_plugins() {
  log "Installing/restoring Neovim plugins"
  run_nvim --headless "+Lazy! restore" +qa
}

install_mason_tools() {
  log "Installing LSP servers, formatters and CLI tools through Mason"

  local packages=(
    bash-language-server
    vscode-langservers-extracted
    eslint-lsp
    gopls
    lua-language-server
    marksman
    pyright
    rust-analyzer
    taplo
    typescript-language-server
    yaml-language-server
    goimports
    prettierd
    ruff
    shfmt
    stylua
  )

  # Load Mason once to ensure its commands are registered. Individual package
  # installs are then executed serially so a stalled package is immediately
  # visible in the bootstrap log.
  run_nvim --headless     "+Lazy! load mason.nvim"     "+lua require('mason').setup({max_concurrent_installers=1})"     +qa

  local package
  for package in "${packages[@]}"; do
    log "Mason: $package"

    if ! run_nvim --headless       "+Lazy! load mason.nvim"       "+lua require('mason').setup({max_concurrent_installers=1})"       "+MasonInstall $package"       +qa; then
      warn "Mason failed while installing: $package"
      warn "Open Neovim and run :MasonLog for the detailed Mason log."
      return 1
    fi
  done
}


install_treesitter_parsers() {
  log "Installing Tree-sitter parsers"

  local jobs=4
  if [[ "$OS" == "Darwin" ]]; then
    # Keep parser extraction/rename deterministic on macOS filesystems.
    jobs=1
  fi

  # Remove only incomplete temp work left by an interrupted previous process.
  if [[ -d "$CACHE_DIR" ]]; then
    find "$CACHE_DIR" -maxdepth 1 -type d -name 'tree-sitter-*-tmp' -exec rm -rf {} + 2>/dev/null || true
  fi

  local lua
  lua="local ts=require('nvim-treesitter'); local parsers={\
'bash','c','css','diff','dockerfile','gitcommit','go','gomod','gosum','html',\
'javascript','json','lua','markdown','markdown_inline','python','regex',\
'rust','toml','tsx','typescript','vim','vimdoc','yaml'\
}; ts.install(parsers,{summary=true,max_jobs=$jobs}):wait(600000); \
local installed={}; for _,lang in ipairs(ts.get_installed('parsers')) do installed[lang]=true end; \
local missing={}; for _,lang in ipairs(parsers) do if not installed[lang] then table.insert(missing,lang) end end; \
assert(#missing==0,'Missing Tree-sitter parsers: '..table.concat(missing,', '))"

  run_nvim --headless "+lua $lua" +qa
}


verify_installation() {
  log "Verifying installation"

  local version
  version="$(nvim_version "$NVIM_BIN")"
  version_ge "$version" "$MIN_NVIM_VERSION" || die "Neovim verification failed."

  command -v git >/dev/null 2>&1 || die "git verification failed."
  command -v rg >/dev/null 2>&1 || die "ripgrep verification failed."
  command -v node >/dev/null 2>&1 || die "Node.js verification failed."
  command -v npm >/dev/null 2>&1 || die "npm verification failed."
  command -v go >/dev/null 2>&1 || die "Go verification failed."
  command -v tree-sitter >/dev/null 2>&1 || die "tree-sitter verification failed."

  run_nvim --headless \
    "+lua assert(pcall(require, 'lazy'), 'lazy.nvim is not available')" \
    "+lua assert(pcall(require, 'nvim-treesitter'), 'nvim-treesitter is not available')" \
    +qa
}

main() {
  ensure_local_path
  detect_platform
  install_system_dependencies
  backup_existing_profile
  install_neovim
  install_node
  install_go
  install_tree_sitter
  clone_config
  install_plugins
  install_treesitter_parsers
  install_mason_tools
  verify_installation

  printf '\n\033[1;32mDone.\033[0m Neovim config is ready.\n\n'
  printf 'Start it with:\n  nvim\n'

  printf '\nConfig: %s\n' "$CONFIG_DIR"
  printf 'Neovim: %s\n' "$NVIM_BIN"

  if (( BACKUP_USED == 1 )); then
    printf 'Backup: %s\n' "$BACKUP_DIR"
  fi
}

main "$@"
