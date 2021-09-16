#!/usr/bin/perl
use strict;
use warnings;
use Term::ANSIColor qw(:constants);
use Switch;
use Clipboard::Xclip;
use Crypt::GPG;
#my $USER = $ENV{ 'USER' };
#my $gpg =  new Crypt::GPG( homedir => "/home/$USER/.gnupg" );
#print $gpg;
#croak $gpg->error() if $gpg->error();

## Main function ##
sub main(){
	switch($ARGV[0]) {
	# if first argument given to script == "init"
		case "init" {&init_pass_store();}
	# if first argument given to script == "gen"
		case "generate" { my @password = &gen_password();}
	# if first argument given to script == "list"
		case "list" {&get_passwords_list();}
	# if first argument given to script == "show"
		case "show" {&show_password();}
	# if first argument given to script == "clip"
		case "clip" {&clip_password();}
	# if first argument given to script == "add"
		case "add" {&add_password();}
	# if first argument given to script == "dmenu"
		case "dmenu" {&dmenu_clipper();}
	}
}

## Generate a random password with special characters
## Give it a name & the nb of characters that you prefer
sub gen_password {
	# Ex: ./passgen.pl generate $passwordName $numberOfCharsInPass
	# Ex: ./passgen.pl generate emailpass 50
	my $password_name = $ARGV[1];
	my $characters_in_pass = $ARGV[2];
	# List of characters potentially in generated password
	my @character_list = (
		("A".."Z"),
		("a".."z"),
		("!", "@", "#", "\$", "%", "^", "&", "*", "(", ")", "[", "]"),
		(0..9)
	);
	# Size of the array @character_list for use in loop
	my $array_size = scalar @character_list;
	# Initializing empty array to store the new password
	my @password = ();
	# Get a random character until you have the right wanted by the user.
	for (my $i = 0; $i < $characters_in_pass; $i++) {
		my $random = rand($array_size);
		push @password, $character_list[$random];
	}
	## Get the generated password and save it into
	## A file within password-store directory
	open (PASSWORD_FILE, ">>", "./password-store/$password_name.txt");
	print PASSWORD_FILE @password;
	close(PASSWORD_FILE);
	print GREEN "Your password: ", @password, RESET;
	return @password;
}

# Create the password yourself
sub add_password() {
	my $password_name = $ARGV[1];
	print "Enter a password: ";
	my $password = <STDIN>;
	open (PASSWORD_FILE, ">>", "./password-store/$password_name.txt");
	print PASSWORD_FILE $password;
	close(PASSWORD_FILE);
	print GREEN "Your password: ", $password, RESET;
	return $password;
}

## If the password-store dir doesn't exist,
## create it
sub init_pass_store() {
	my  $dir = "./password-store";
	if (!-e $dir){
		mkdir $dir;
		print "created password-store directory";
	}
}

# Generate a list of passwords in the password-store directory in a tree-like
# manner
sub get_passwords_list() {
	my $password_list = `tree ./password-store`;
	print GREEN $password_list, RESET;
}

# Show requested password
sub show_password() {
	my $requested_password = "./password-store/$ARGV[1].txt";
	open(my $fh, '<:encoding(UTF-8)', $requested_password)
		or die "Could not open file '$requested_password' $!";
	while (my $row = <$fh>) {
		chomp $row;
		print GREEN "Your password: $row", RESET;
	}
}

# Clip password (name provided as second argument to the script)
sub clip_password() {
	# temporarily decript file content
	# copy password to clipboard
	system("cat ./password-store/$ARGV[1].txt | xclip -selection c")
}

sub dmenu_clipper() {
	my $requested_password = `ls ./password-store/ | /usr/bin/dmenu`;
	system("xclip -selection c ./password-store/$requested_password")
}

## Function calls ##
main();
