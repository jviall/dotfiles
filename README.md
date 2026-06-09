# [jviall](https://github.com/jviall)'s dotfiles

My dotfiles are managed with [chezmoi](https://www.chezmoi.io).

## Linux / macOS

One-liner to install chezmoi and apply dotfiles:

```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply jviall
```

Or if you already have an SSH key set up:

```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply git@github.com:jviall/dotfiles.git
```

## Windows

Windows requires a few manual steps before chezmoi can take over.

**Prerequisites:** winget must be available (included with Windows 11 and Windows 10 1809+).

1. Install chezmoi via winget:

```powershell
winget install twpayne.chezmoi
```

2. Apply dotfiles (chezmoi will install remaining packages via the winget script):

```powershell
chezmoi init --apply jviall
```

Or if you already have an SSH key set up:

```powershell
chezmoi init --apply git@github.com:jviall/dotfiles.git
```

