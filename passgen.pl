#!/usr/bin/perl
use strict;
use warnings;

sub main(){
	gen_password();
}

sub gen_password{
	print "How many characters do you want in your password:";
	my $characters_in_pass = <>;
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
	print @password;
	return @password;
}

# sub init_pass_store(){
	# $dir = password-store;
	# if it doesn't exist already, create $dir 
# }

# sub save_password(){
	# takes generated password as argument
	# cd into password-store
	# open a file called "however-the-user-wants-to-call-it"
	# print password into it
	# close file
# }

main()
