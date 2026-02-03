# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a chezmoi-managed dotfiles repository for macos, windows, and linux systems--generally in that order of support priority. Chezmoi uses a source-target state model where files in this repository (source state) are applied to the home directory (target state). Files are named with special prefixes that control how chezmoi processes them:

- `dot_` prefix → becomes `.` in target (e.g., `dot_zshenv` → `~/.zshenv`)
- `private_` prefix → sets restrictive permissions (0600)
- `executable_` prefix → makes files executable
- `.tmpl` suffix → file is processed as a Go template with access to chezmoi variables

## Architecture

### File Naming Convention
When working with this repo, always use chezmoi's special prefixes:
- Files destined for `~/.config/` go in `dot_config/`
- Files that should be private use `private_` prefix
- Executables use `executable_` prefix
- Templates use `.tmpl` suffix

Example: `dot_config/bin/executable_ide.tmpl` becomes `~/.config/bin/ide` (executable, templated)

### Templating System
Templates use Go's `text/template` syntax with chezmoi-specific functions, for example:

- `.chezmoi.os` - Operating system (e.g., "darwin")
- `.chezmoi.arch` - Architecture (e.g., "arm64")
- `.chezmoi.username` - Current username
- `onepasswordDetailsFields` / `onepasswordItemFields` - Fetch secrets from 1Password
- and many more. If you're not sure if a function exists or how it works, we can look up the documentation.

I primarily use templates for:
- Environment-specific configurations (work vs personal)
- Secret injection from 1Password
- Cross-platform compatibility

### Shell Configuration Structure
The shell configuration follows XDG Base Directory conventions:

1. `~/.zshenv` (dot_zshenv) - Sets XDG variables, sources first
2. `~/.config/zsh/.zprofile` (dot_config/zsh/dot_zprofile) - PATH setup, secrets, SSH agent, environment variables
3. `~/.config/zsh/.zshrc` (dot_config/zsh/dot_zshrc) - Interactive shell config, sources:
   - `vimrc` - Vi mode keybindings
   - `pluginrc` - Zsh plugins via znap
   - `aliasrc` - Shell aliases
   - `optionrc` - Zsh options

**Important**: Environment variables and secrets should be sourced in `.zprofile`, not `.zshrc`. Currently secrets are sourced from `~/.config/secrets/.env` in zprofile:7.

### Installation Scripts
Scripts in `.chezmoiscripts/` run automatically:

- `run_once_before_*` - Runs once before applying dotfiles
- `run_onchange_before_*` - Runs when the script content changes

Current scripts:
1. `run_onchange_before_install-brew-bundle.sh.tmpl` - Installs Homebrew and all packages
2. `run_once_before_install-init.sh.tmpl` - macOS customization (dock, key repeat, etc.)

Scripts use templating to conditionally install work-related software when username contains "gov" or "nj".

### 1Password Integration
Some templates fetch private credentials from 1Password using the `op` CLI.

There are a few different functions that Chezmoi provides for 1P lookups, such as `onepasswordItemFields` and they have different purposes. 

### Custom Utilities
`dot_config/bin/executable_ide.tmpl` - Creates a tmux IDE session with predefined windows for common projects. Windows array is templated based on username (personal vs work).

## Managing Configurations
My primary editor is NeoVim using LazyVim, the configuration of which is managed in this dotfiles repo. One side effect of how chezmoi manages the source and target files, and how LazyVim manages plugins, is that I often will update plugins using LazyVim which will update the target, which will mean that the target will have drifted from chezmoi's source, and we have to manually merge the changes to the `lazy-lock.json` and `lazyvim.json` files, which if I use `chezmoi merge` will use NeoVim's three-way merge tool. I almost always just take the changes in the target and apply them to the source for these files.

When adding new configurations:
- Use appropriate chezmoi prefixes
- Consider if it needs templating (.tmpl)
- Add to appropriate location following XDG conventions
- For secrets, use 1Password integration and prompt me for the appropriate 1Password item ID and field names, rather than hardcoding private values.
