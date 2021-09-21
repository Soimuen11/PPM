# The Perl Password Manager [PPM]

* [To-Dos](#to-dos)
* [How To Use It](#how-to-use-it)
* [How To Install It](#how-to-install-it)

**Disclaimers:**

+ This program is still being tested, only use it at your own risks.
+ This is mainly a CLI utility. For efficiency purposes, I recommend having a
  keybinding for the **ppm dmenu** command in your Tiling Window Manager
  configuration.
+ Yes, this project is inspired by another password manager called **pass**.

**Contribute:**

If you wish to contribute, feel free to make a pull request! If
you feel like something is missing, send me suggestions!

## To-Dos

1. Add following functionalities:
	+ Remove a password with **passgen rm** [done]
	+ Rename a password with **passgen mv** [done]
	+ Copy a password with **passgen cp** [done]
	+ Help with **passgen help** [done]
	+ Make it work from anywhere in filesystem
	+ Add possibility to create directories in password-store
2. Package PPM for debian and arch-based distros.
3. Write **man** page.
4. Re-write subroutines which use bash to strive and only use Perl syntax.
   Potential modules to implement to do so: 
   + IO::Handle
   + GnuPG::Interface
   + Clipboard::Xclip
7. Add a simple GUI or ncurses interface.

## How To Use It

Once installed, this program has been designed to be used in a terminal. For
now, here are the available commands:

1. passgen **list**
2. passgen **init**
3. passgen **generate** [password_name] [nb_characters_in_password]
4. passgen **show** [password_name]
5. passgen **clip** [password_name]
6. passgen **add** [password_name]
7. passgen **dmenu**
8. passgen **rm** [password_name]
9. passgen **mv** [old_password_name] [new_password_name]
10. passgen **cp** [old_password_name] [new_password_name]
11. passgen **help**: displays help

As a first step, it is important to run **ppm init** to set up the password
store. You may then generate passwords with **ppm generate** (randomly
generates a password with the number of characters which you specified), or
**ppm add**. To show a password or add it to your clipboard, you can
respectively use the commands **ppm show** and **ppm clip**. Finally, you may
list all the passwords in your password store with the command **ppm list**.
If you run **ppm dmenu**, it will output a list of your passwords within the
password-store into dmenu. If you select one, the passwords will be copied into
your clipboard.

## How To Install It

+ Dependencies:

	- Perl 5 (should already be installed)
	- Dmenu
	- Tree
	- Gpg
	- Xclip
	- Git

```bash
# For Debian & Ubuntu-based Linux systems
sudo apt update && sudo apt upgrade -y && sudo apt install perl dmenu tree gpg xclip git

# For Arch-based Linux systems
sudo pacman -Syu perl dmenu tree gpg xclip git
```

+ Set up gpg:

```bash
gpg --full-gen-key # Initialize /home/$USER/.gnupg and RSA key
```

+ To install from source, run the following commands:

```bash
# Create /home/$USER/.local/repos && /home/$USER/.local/bin
# If they do not already exist
mkdir -p /home/$USER/.local/repos /home/$USER/.local/bin

# Cd into /home/$USER/.local/repos
cd /home/$USER/.local/repos

# Clone the repository
git clone https://github.com/Soimuen11/PPM.git

# Cd into the project repository
cd PPM/

# Install required CPAN modules
cpan Switch
cpan Term::ANSIColor	
cpan File::Copy

# Give execute permissions to ppm.pl
chmod u+x ppm.pl

# Create a symlink from .local/repo to .local/bin
ln -s /home/$USER/.local/repo/PPM/ppm.pl /home/$USER/.local/bin/passgen

# Optional step: Add the **ppm dmenu** command to your tiling window manager's
# list of keybindings.  
```
