# 🔐 PPM — The Perl Password Manager

**A minimalist, GnuPG-based password manager for the command line, written in Perl and inspired by [`pass`](https://www.passwordstore.org/).**

[![Perl](https://img.shields.io/badge/Perl-39457E?style=for-the-badge&logo=perl&logoColor=white)](https://www.perl.org/)
[![GnuPG](https://img.shields.io/badge/GnuPG-0093DD?style=for-the-badge&logo=gnuprivacyguard&logoColor=white)](https://gnupg.org/)
[![Platform](https://img.shields.io/badge/Platform-Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)](#-requirements)
[![Status](https://img.shields.io/badge/Status-In_development-orange?style=for-the-badge)](#-roadmap)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg?style=for-the-badge)](LICENSE)

---

## 💡 About The Project

**PPM** stores each password in its own GnuPG-encrypted file, inside a plain directory tree. There is no database and no daemon: your store is just files you can back up, sync or version with Git.

It is built around a few ideas:

- **Simple**: one Perl script, a handful of commands.
- **Safe by design**: passwords are encrypted in memory and never written to disk in clear text; names typed on the command line are never interpreted by a shell.
- **Keyboard-driven**: a `dmenu` mode lets you copy any password to the clipboard with a single keybinding.

---

## 🌟 Features

- 🔑 Generate random passwords (cryptographically secure source: `/dev/urandom`)
- ➕ Add your own passwords, with hidden input and confirmation
- 📋 Copy to the clipboard (`xclip`) or print to the terminal
- 🗂️ Nested entries (`web/github`, `mail/work`…) displayed as a tree
- ⚡ `dmenu` integration for quick access from your window manager
- 🔒 GnuPG handled natively through [`GnuPG::Interface`](https://metacpan.org/pod/GnuPG::Interface), with no `system()` call

---

## 📦 Requirements

| Dependency | Purpose |
|:--|:--|
| Perl 5 | Runtime |
| GnuPG (`gpg`) | Encryption and decryption |
| `GnuPG::Interface` | Perl interface to GnuPG |
| `Term::ReadKey` | Hidden password prompt |
| `xclip` | Clipboard access |
| `dmenu` | Optional: `ppm dmenu` command |
| Git | Optional: to clone and version your store |

```bash
# Debian & Ubuntu-based systems
sudo apt update
sudo apt install perl gpg xclip dmenu git libgnupg-interface-perl libterm-readkey-perl

# Arch-based systems
sudo pacman -S perl gnupg xclip dmenu git
cpan GnuPG::Interface Term::ReadKey
```

> `Term::ANSIColor`, `File::Copy`, `File::Find` and the other modules used by PPM ship with Perl.

---

## 🛠️ Installation

**1. Create a GnuPG key** (skip this if you already have one):

```bash
gpg --full-gen-key
```

**2. Install PPM from source:**

```bash
# Clone the repository
mkdir -p ~/.local/repos ~/.local/bin
git clone https://github.com/Soimuen11/PPM.git ~/.local/repos/PPM

# Make it executable and expose it as `ppm`
chmod u+x ~/.local/repos/PPM/ppm.pl
ln -s ~/.local/repos/PPM/ppm.pl ~/.local/bin/ppm
```

Make sure `~/.local/bin` is in your `PATH`.

**3. Initialize your password store:**

```bash
ppm init
```

PPM asks for the email address (or key ID) of your GnuPG key and creates `~/.password-store`.

---

## 🚀 Usage

```bash
ppm generate web/github 24     # generate a 24-character password
ppm add mail/work              # type in a password yourself
ppm list                       # display the store as a tree
ppm show web/github            # print a password
ppm clip web/github            # copy a password to the clipboard
ppm dmenu                      # pick a password with dmenu, then copy it
```

### Commands

| Command | Description |
|:--|:--|
| `ppm init` | Create the password store and register your GnuPG key |
| `ppm generate <name> [length]` | Generate and store a random password (default length: 20) |
| `ppm add <name>` | Store a password you type in |
| `ppm show <name>` | Print a password |
| `ppm clip <name>` | Copy a password to the clipboard |
| `ppm list` | List all entries as a tree |
| `ppm dmenu` | Choose an entry with dmenu and copy it |
| `ppm cp <old> <new>` | Copy an entry |
| `ppm mv <old> <new>` | Rename or move an entry |
| `ppm rm <name>` | Remove an entry |
| `ppm help` | Display the help |

### Keybinding for your window manager

`ppm dmenu` is designed to be bound to a shortcut. For example with **i3** or **sway**:

```
bindsym $mod+p exec ppm dmenu
```

### Configuration

| Variable | Default | Description |
|:--|:--|:--|
| `PPM_DIR` | `~/.password-store` | Location of the password store |

---

## 🗺️ Roadmap

- [x] Work from anywhere in the filesystem
- [x] Create nested directories in the password store
- [x] Replace shell calls with native Perl (`GnuPG::Interface`, `IPC::Open2`, list-form pipes)
- [ ] Clear the clipboard automatically after a delay
- [ ] Package for Debian-based distributions
- [ ] Package for Arch-based distributions
- [ ] Add a `Makefile.PL`
- [ ] Write a `man` page
- [ ] Add a simple GUI or ncurses interface

---

## 🤝 Contributing

Contributions are welcome! Pick an item from the [roadmap](#-roadmap), fork the repository and open a **Pull Request**. Bug reports and suggestions are welcome too: feel free to open an [**Issue**](https://github.com/Soimuen11/PPM/issues).

---

## 👨‍💻 Author

**Philippe Iannetta** ([@Soimuen11](https://github.com/Soimuen11))

- **Blog**: [blog.phiannetta.xyz](https://blog.phiannetta.xyz)
- **Portfolio**: [portfolio.phiannetta.xyz](https://portfolio.phiannetta.xyz)
- **FreeWiki**: [freewiki.phiannetta.xyz](https://freewiki.phiannetta.xyz)

PPM is inspired by [**pass**](https://www.passwordstore.org/), the standard unix password manager.
