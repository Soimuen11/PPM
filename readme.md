# A Perl Password Generator

Disclaimer: this program is not finished, only use it at your own risks.

## Future Features

1. Save password in a file (with a name) in a .password-store
   directory [done]
2. Add color to output password [done]
3. List them in tree-like manner [done but can be perfected]
4. Be able to find passwords with a simple command
5. Encrypt files storing passwords
6. Make it work with dmenu

## How To Use It

1. Clone this repository into /home/$USER/.local/repo
2. Install dependencies: dmenu, tree
3. Make file executable: chmod u+x passgen.pl
4. Create a symlink: ln -s ~/.local/repos/passgen.pl ~/local/bin/passgen
