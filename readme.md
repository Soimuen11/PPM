# The Perl Password Manager [PPM]

**Disclaimer:** This program is not finished, only use it at your own risks.

**Contribute:** If you wish to contribute, feel free to make a pull request! If
you feel like something is missing, send me suggestions!

## Future Features

1. Save password in a file (with a name) in a .password-store
   directory [done]
2. Add color to output password [done]
3. List them in tree-like manner [done]
4. copy password to clipboard [done]
5. Encrypt files storing passwords
6. Make it work with dmenu
7. Add a install.sh script [work in progress]

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
	- gpg

+ Set up gpg:
	
```bash
gpg --full-gen-key # Initialize /home/$USER/.gnupg and RSA key
```

+ Clone this repository in the location of choice:

```bash
git clone git@github.com:Soimuen11/PassGen.git
```

+ Run the installer script:

```bash
cd PassGen/ && chmod u+x installer.sh && /bin/bash installer.sh
```
