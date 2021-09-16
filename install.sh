#!/bin/bash

# Locate yourself
CURRENT_DIR=$(pwd)
LOCAL=/home/$USER/.local

# Install necessary perl modules
cpan Clipboard::Xclip
cpan Crypt::GPG
cpan Switch

# If $LOCAL/repo and $LOCAL/bin don't exist, create them
mkdir -p $LOCAL/repo $LOCAL/bin

# Copy PassGen into $LOCAL/repo
cp -rv $CURRENT_DIR/PassGen $LOCAL/repo

# Create a symlink from ~/.local/repo to ~/.local/bin
ln -s $LOCAL/repo/PassGen/ppm.pl $LOCAL/bin/ppm

# Clean up
rm -rv $CURRENT_DIR/PassGen
