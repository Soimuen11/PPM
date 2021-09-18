# The Perl Password Manager [PPM]

**Disclaimers:**

+ This program is not finished, only use it at your own risks.
+ The installer script has not yet been tested.
+ This is mainly a CLI utility. For efficiency purposes, I recommend having a
  keybinding for the **ppm dmenu** command in your Tiling Window Manager
  configuration.
+ Yes, this project is inspired by another password manager called **pass**.

**Contribute:**

If you wish to contribute, feel free to make a pull request! If
you feel like something is missing, send me suggestions!

## To-Dos

1. Fix "show" function.
2. Write a **make file**.
3. Write **man** page.
4. Re-write subroutines which use bash to strive and only use Perl syntax.
5. Add a simple GUI or ncurses interface.

## How To Use It

Once installed, this program has been designed to be used in a terminal. For
now, here are the available commands:

1. ppm **list**
2. ppm **init**
3. ppm **generate** [password_name] [nb_characters_in_password]
4. ppm **show** [password_name]
5. ppm **clip** [password_name]
6. ppm **add** [password_name]
7. ppm **dmenu**

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

```bash
# For Debian & Ubuntu-based Linux systems
sudo apt update && sudo apt upgrade -y && sudo apt install perl dmenu tree gpg xclip

# For Arch-based Linux systems
sudo pacman -Syu perl dmenu tree gpg xclip
```

+ Set up gpg:

```bash
gpg --full-gen-key # Initialize /home/$USER/.gnupg and RSA key
```

+ Clone this repository in the location of your choice:

```bash
git clone git@github.com:Soimuen11/PassGen.git
```

+ Run the installer script:

```bash
cd PassGen/ && chmod u+x installer.sh && /bin/bash installer.sh
```
