#!/usr/bin/env perl
#
# PPM - The Perl Password Manager
#
# Passwords are stored one per file, encrypted with GnuPG, under
# $PPM_DIR (default: ~/.password-store). No shell is ever spawned:
# gpg is driven through GnuPG::Interface, and the few external
# programs (xclip, dmenu) are started with list-form pipes.

use strict;
use warnings;
use feature qw(say);

use Fcntl qw(O_WRONLY O_CREAT O_EXCL);
use File::Basename qw(dirname);
use File::Copy qw(copy move);
use File::Find ();
use File::Path qw(make_path);
use File::Spec;
use GnuPG::Interface;
use IO::Handle;
use IPC::Open2 qw(open2);
use Term::ANSIColor qw(colored);
use Term::ReadKey qw(ReadMode ReadLine);

## Configuration ##

my $HOME  = $ENV{HOME} // die "HOME is not set\n";
my $STORE = $ENV{PPM_DIR} // File::Spec->catdir($HOME, '.password-store');
my $GPG_ID_FILE = File::Spec->catfile($STORE, '.gpg-id');

my @CHARSET = ('A' .. 'Z', 'a' .. 'z', 0 .. 9, split(//, '!@#$%^&*()[]'));

## Commands ##

my %COMMANDS = (
    init     => \&cmd_init,
    generate => \&cmd_generate,
    list     => \&cmd_list,
    show     => \&cmd_show,
    clip     => \&cmd_clip,
    add      => \&cmd_add,
    rm       => \&cmd_rm,
    mv       => \&cmd_mv,
    cp       => \&cmd_cp,
    dmenu    => \&cmd_dmenu,
    help     => \&cmd_help,
);

sub main {
    my ($command, @args) = @ARGV;
    $command //= 'help';

    my $handler = $COMMANDS{$command};
    unless ($handler) {
        print STDERR colored("Unknown command: $command\n", 'red');
        cmd_help();
        exit 1;
    }

    eval { $handler->(@args); 1 } or do {
        my $error = $@ || "unknown error\n";
        print STDERR colored("Error: $error", 'red');
        exit 1;
    };
}

# Initialize the password store and its .gpg-id file
sub cmd_init {
    make_path($STORE, { mode => 0700 }) unless -d $STORE;
    say colored("Password store: $STORE", 'green');

    if (-e $GPG_ID_FILE) {
        say "$GPG_ID_FILE already exists, nothing to do.";
        return;
    }

    my $user = $ENV{USER} // 'there';
    print "Hello $user, please enter the email address (or key ID) you use with gnupg: ";
    STDOUT->flush;
    my $key_id = <STDIN>;
    chomp($key_id) if defined $key_id;
    die "No key ID provided\n" unless defined $key_id && length $key_id;

    my @keys = GnuPG::Interface->new->get_public_keys($key_id);
    warn "Warning: no public key found for '$key_id'; encryption will fail.\n"
        unless @keys;

    open(my $fh, '>', $GPG_ID_FILE) or die "Cannot write $GPG_ID_FILE: $!\n";
    print {$fh} "$key_id\n";
    close($fh) or die "Cannot write $GPG_ID_FILE: $!\n";
    say colored("Created $GPG_ID_FILE", 'green');
}

# Generate a random password of the requested length and store it
sub cmd_generate {
    my ($name, $length) = @_;
    $length //= 20;
    die "Usage: ppm generate <name> [length]\n" unless defined $name;
    die "Length must be a number between 1 and 4096\n"
        unless $length =~ /\A\d+\z/ && $length >= 1 && $length <= 4096;

    my $password = join('', map { $CHARSET[random_index(scalar @CHARSET)] } 1 .. $length);
    store_password($name, $password);
    say colored("Your password: $password", 'green');
}

# Ask for a password and store it
sub cmd_add {
    my ($name) = @_;
    die "Usage: ppm add <name>\n" unless defined $name;

    my $password = prompt_secret('Enter a password: ');
    die "Empty password, aborting\n" unless defined $password && length $password;
    my $confirm = prompt_secret('Retype the password: ');
    die "Passwords do not match\n" unless defined $confirm && $password eq $confirm;

    store_password($name, $password);
}

# Print the entries as a tree
sub cmd_list {
    die "Password store not initialized, run: ppm init\n" unless -d $STORE;
    say colored('Password Store', 'green');
    print_tree($STORE, '');
}

sub cmd_show {
    my ($name) = @_;
    die "Usage: ppm show <name>\n" unless defined $name;
    say read_password($name);
}

sub cmd_clip {
    my ($name) = @_;
    die "Usage: ppm clip <name>\n" unless defined $name;
    copy_to_clipboard(read_password($name));
    say colored("Copied $name to the clipboard", 'green');
}

# Pick an entry with dmenu, then copy it to the clipboard
sub cmd_dmenu {
    my @entries = list_entries();
    die "The password store is empty\n" unless @entries;

    my $pid = open2(my $from_dmenu, my $to_dmenu, 'dmenu', '-p', 'Passwords:');
    print {$to_dmenu} join("\n", @entries), "\n";
    close($to_dmenu);
    my $choice = <$from_dmenu>;
    close($from_dmenu);
    waitpid($pid, 0);

    return unless defined $choice;    # dmenu cancelled
    chomp $choice;
    return unless length $choice;
    copy_to_clipboard(read_password($choice));
}

sub cmd_rm {
    my ($name) = @_;
    die "Usage: ppm rm <name>\n" unless defined $name;
    my $path = entry_path($name);
    die "No such password: $name\n" unless -e $path;
    unlink($path) or die "Cannot remove $path: $!\n";
    say "Removed password $name";
}

sub cmd_mv {
    my ($old, $new) = @_;
    die "Usage: ppm mv <old_name> <new_name>\n" unless defined $old && defined $new;
    my ($from, $to) = transfer_paths($old, $new);
    move($from, $to) or die "Cannot rename $old -> $new: $!\n";
    say "Renamed password $old -> $new";
}

sub cmd_cp {
    my ($old, $new) = @_;
    die "Usage: ppm cp <old_name> <new_name>\n" unless defined $old && defined $new;
    my ($from, $to) = transfer_paths($old, $new);
    copy($from, $to) or die "Cannot copy $old -> $new: $!\n";
    say "Copied password $old -> $new";
}

sub cmd_help {
    my $line = '=' x 55;
    print <<"HELP";
$line
====================== PPM HELP =======================
$line
1.  ppm init                            initialize the store and .gpg-id
2.  ppm generate <name> [length]        generate and store a random password
3.  ppm add <name>                      type in a password and store it
4.  ppm show <name>                     print a password
5.  ppm clip <name>                     copy a password to the clipboard
6.  ppm list                            list the store as a tree
7.  ppm dmenu                           pick a password with dmenu and copy it
8.  ppm cp <old_name> <new_name>        copy an entry
9.  ppm mv <old_name> <new_name>        rename an entry
10. ppm rm <name>                       remove an entry
11. ppm help                            display this help

Store location: \$PPM_DIR, default ~/.password-store
$line
================== Philippe Iannetta ==================
================== blog.phiannetta.xyz ================
$line
HELP
}

## GnuPG (native, through GnuPG::Interface: no shell involved) ##

sub encrypt_string {
    my ($plaintext, $recipient) = @_;

    my $gnupg = GnuPG::Interface->new;
    $gnupg->options->push_recipients($recipient);
    $gnupg->options->meta_interactive(0);

    my ($stdin, $stdout) = (IO::Handle->new, IO::Handle->new);
    my $handles = GnuPG::Handles->new(stdin => $stdin, stdout => $stdout);

    my $pid = $gnupg->encrypt(handles => $handles);
    print {$stdin} $plaintext;
    close($stdin);

    binmode($stdout);
    my $ciphertext = do { local $/; <$stdout> };
    close($stdout);
    waitpid($pid, 0);
    die "gpg failed to encrypt (exit status " . ($? >> 8) . ")\n" if $? != 0;

    return $ciphertext;
}

sub decrypt_file {
    my ($path) = @_;

    open(my $in, '<:raw', $path) or die "Cannot read $path: $!\n";
    my $ciphertext = do { local $/; <$in> };
    close($in);

    my $gnupg = GnuPG::Interface->new;
    my ($stdin, $stdout) = (IO::Handle->new, IO::Handle->new);
    my $handles = GnuPG::Handles->new(stdin => $stdin, stdout => $stdout);

    my $pid = $gnupg->decrypt(handles => $handles);
    binmode($stdin);
    print {$stdin} $ciphertext;
    close($stdin);

    binmode($stdout);
    my $plaintext = do { local $/; <$stdout> };
    close($stdout);
    waitpid($pid, 0);
    die "gpg failed to decrypt $path (exit status " . ($? >> 8) . ")\n" if $? != 0;

    return $plaintext;
}

## Store helpers ##

# Encrypt in memory and write the .gpg file: the plaintext never touches the disk
sub store_password {
    my ($name, $secret) = @_;

    my $path = entry_path($name);
    die "$name already exists, remove it first with: ppm rm $name\n" if -e $path;

    my $ciphertext = encrypt_string("$secret\n", read_key_id());

    make_path(dirname($path), { mode => 0700 });
    sysopen(my $fh, $path, O_WRONLY | O_CREAT | O_EXCL, 0600)
        or die "Cannot create $path: $!\n";
    binmode($fh);
    print {$fh} $ciphertext;
    close($fh) or die "Cannot write $path: $!\n";

    say colored("Created $path", 'green');
}

sub read_password {
    my ($name) = @_;
    my $path = entry_path($name);
    die "No such password: $name\n" unless -e $path;
    my $plaintext = decrypt_file($path);
    $plaintext =~ s/\r?\n\z//;
    return $plaintext;
}

sub read_key_id {
    open(my $fh, '<', $GPG_ID_FILE)
        or die "Cannot open $GPG_ID_FILE (did you run 'ppm init'?): $!\n";
    my $key_id = <$fh>;
    close($fh);
    chomp($key_id) if defined $key_id;
    die "$GPG_ID_FILE is empty\n" unless defined $key_id && length $key_id;
    return $key_id;
}

# Turn a user-supplied name into a path, refusing anything that escapes the store
sub entry_path {
    my ($name) = @_;
    die "Missing password name\n" unless defined $name && length $name;
    die "Invalid password name: $name\n"
        if $name =~ m{\A/} || $name =~ m{(?:\A|/)\.\.?(?:/|\z)} || $name =~ /\0/;
    return File::Spec->catfile($STORE, "$name.gpg");
}

sub transfer_paths {
    my ($old, $new) = @_;
    my $from = entry_path($old);
    my $to   = entry_path($new);
    die "No such password: $old\n"  unless -e $from;
    die "$new already exists\n"     if -e $to;
    make_path(dirname($to), { mode => 0700 });
    return ($from, $to);
}

sub list_entries {
    die "Password store not initialized, run: ppm init\n" unless -d $STORE;
    my @entries;
    File::Find::find(
        {
            no_chdir => 1,
            wanted   => sub {
                return unless -f $_ && /\.gpg\z/;
                (my $name = File::Spec->abs2rel($_, $STORE)) =~ s/\.gpg\z//;
                push @entries, $name;
            },
        },
        $STORE
    );
    return sort @entries;
}

# Pure-Perl replacement for `tree`
sub print_tree {
    my ($dir, $prefix) = @_;

    opendir(my $dh, $dir) or die "Cannot open $dir: $!\n";
    my @items = sort grep { !/\A\./ && (-d "$dir/$_" || /\.gpg\z/) } readdir($dh);
    closedir($dh);

    for my $i (0 .. $#items) {
        my $last = ($i == $#items);
        my $item = $items[$i];
        my $path = "$dir/$item";
        my $branch = $last ? '└── ' : '├── ';

        if (-d $path) {
            say $prefix, $branch, colored($item, 'blue');
            print_tree($path, $prefix . ($last ? '    ' : '│   '));
        }
        else {
            (my $label = $item) =~ s/\.gpg\z//;
            say $prefix, $branch, $label;
        }
    }
}

## Misc helpers ##

# Uniform random integer in [0, $max) from the kernel CSPRNG (no modulo bias)
{
    my $urandom;

    sub random_index {
        my ($max) = @_;
        open($urandom, '<:raw', '/dev/urandom')
            or die "Cannot open /dev/urandom: $!\n"
            unless $urandom;

        my $limit = 256 - (256 % $max);
        while (1) {
            read($urandom, my $byte, 1) == 1 or die "Cannot read /dev/urandom\n";
            my $n = ord($byte);
            return $n % $max if $n < $limit;
        }
    }
}

sub prompt_secret {
    my ($prompt) = @_;
    print $prompt;
    STDOUT->flush;
    ReadMode('noecho');
    my $secret = ReadLine(0);
    ReadMode('restore');
    print "\n";
    chomp($secret) if defined $secret;
    return $secret;
}

# xclip is started with a list-form pipe: no shell, no quoting issues
sub copy_to_clipboard {
    my ($text) = @_;
    open(my $xclip, '|-', 'xclip', '-selection', 'clipboard')
        or die "Cannot run xclip: $!\n";
    print {$xclip} $text;
    close($xclip) or die "xclip failed\n";
}

## Entry point ##

main();
