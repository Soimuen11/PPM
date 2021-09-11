#!/usr/bin/perl
use strict;
use warnings;
use Term::ANSIColor qw(:constants);
use Switch;

## Main function ##
sub main(){
	switch($ARGV[0]) {
	# if first argument given to script == "init"
		case "init" {&init_pass_store();}
	# if first argument given to script == "gen"
		case "gen" {my @password = &gen_password();}
		case "list"{&get_passwords_list();}
	}
}

## Generate a random password with special characters
## Give it a name & the nb of characters that you prefer
sub gen_password {
	print "How many characters do you want in your password:";
	my $characters_in_pass = <>;
	print "Name your password:";
	my $password_name = <>;
	my @character_list = (
		("A".."Z"),
		("a".."z"),
		("!", "@", "#", "\$", "%", "^", "&", "*", "(", ")", "[", "]"),
		(0..9)
	);
	my $array_size = scalar @character_list;
	my @password = ();
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

## If the password-store dir doesn't exist,
## create it
sub init_pass_store() {
	my  $dir = "./password-store";
	if (!-e $dir){
		mkdir $dir;
		print "created password-store directory";
	}
	return $dir;
}

# Generate a list of passwords in the password-store directory in a tree-like
# manner
sub get_passwords_list {
	# if there are not any files, print "there no files"
	# else show list of files
	my $password_list = `tree ./password-store`;
	print GREEN $password_list, RESET;
}

## Function calls ##
main();
