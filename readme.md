# The Perl Password Manager [PPM]

Disclaimer: This program is not finished, only use it at your own risks.
Contribute: If you wish to contribute, feel free to make a pull request!

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

For now, here are the available commands:
1. **./ppm.pl list**: list passwords in password-store
2. **./ppm.pl init**: init the password-store directory
3. **./ppm.pl generate** $PASSWORD_NAME $NB_CHARACTERS_IN_PASSWORD
4. **./ppm.pl show** $PASSWORD_NAME
5. **./ppm.pl clip** $PASSWORD_NAME
6. **./ppm.pl add** $PASSWORD_NAME

## How To Install It

Option 1:

3. Clone this repository into /home/$USER/.local/repo
4. Install dependencies: dmenu, tree, gpg
5. Make file executable: chmod u+x ppm.pl
6. Create a symlink: ln -s ~/.local/repos/ppm.pl ~/local/bin/ppm

Option 2:

+ Clone repo in location of choice
+ Run install.sh
