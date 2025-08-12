# [jviall](https://github.com/jviall)'s dotfiles

My dotfiles are managed with [chezmoi](https://www.chezmoi.io).

To install there's a slick one-liner:

```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply jviall

```

or if you already have an SSH key setup:

```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply git@github.com:jviall/dotfiles.git
```
