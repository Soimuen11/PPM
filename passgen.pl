#!/usr/bin/perl
use strict;
use warnings;

## Main function ##
sub main(){
	my @password = &gen_password();
	&init_pass_store();
}

## Generate a random password with special characters
## Give it a name & the nb of characters that you prefer
sub gen_password{
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
	for (my $i = 0; $i < $characters_in_pass; $i++){
		my $random = rand($array_size);
		push @password, $character_list[$random];
	}
	## Get the generated password and save it into
	## A file within password-store directory
	open (PASSWORD_FILE, ">", "$password_name.txt");
	print PASSWORD_FILE @password;
	close(FH);
	print @password;
	return @password;
}

## If the password-store dir doesn't exist,
## create it
sub init_pass_store(){
	my  $dir = "./password-store";
	if (!-e $dir){
		mkdir $dir;
		print "created password-store directory";
	}
	return $dir;
}


## Function calls ##
main()
