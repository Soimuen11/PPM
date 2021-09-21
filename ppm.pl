#!/usr/bin/perl
use strict;
use warnings;
use Term::ANSIColor qw(:constants);
use Switch;

## Main function ##
sub main(){
	switch($ARGV[0]) {
		case "init" {&init_env();}
		case "generate" {&gen_password();}
		case "list" {&get_passwords_list();}
		case "show" {&show_password();}
		case "clip" {&clip_password();}
		case "add" {&add_password();}
		case "rm" {&remove_password();}
		case "dmenu" {&dmenu_clipper();}
	}
}

## Generate a random password with special characters
## Give it a name & the nb of characters that you prefer
sub gen_password {
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
	open (PASSWORD_FILE, ">>", "./password-store/$password_name");
	print PASSWORD_FILE @password;
	close(PASSWORD_FILE);
	print GREEN "Your password: ", @password, RESET;
	&encrypt_password_file($password_name);
}

# Create the password yourself
sub add_password() {
	my $password_name = $ARGV[1];
	print "Enter a password: ";
	my $password = <STDIN>;
	open (PASSWORD_FILE, ">>", "./password-store/$password_name");
	print PASSWORD_FILE $password;
	close(PASSWORD_FILE);
	print GREEN "Your password: ", $password, RESET;
	&encrypt_password_file($password_name);
}

# Initialize password store and .gpg-id
sub init_env() {
	my $dir = "./password-store";
	my $config_file = "./.gpg-id";
	my $USER = $ENV{'USER'};
	if (!-e $dir) {
		mkdir $dir;
		print GREEN "Created password-store directory\n", RESET;
	}
	if (!-e $config_file) {
		print GREEN "Hello $USER, please enter the email address you use with gnupg:\n", RESET;
		my $keyId = <STDIN>;
		open (CONFIG_FILE, ">>", "$config_file");
		print CONFIG_FILE $keyId;
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
	my $requested_password = `gpg -d ./password-store/$ARGV[1].gpg`;
	chomp($requested_password);
	print "$requested_password\n";
	#open(my $fh, '<:encoding(UTF-8)', $requested_password)
	#	or die "Could not open file '$requested_password' $!";
	#while (my $row = <$fh>) {
	#	chomp $row;
	#	print GREEN "Your password: $row", RESET;
	#}
}

# Temporarily decrypt password file
# && Clip password (name provided as second argument to the script)
sub clip_password() {
	system("gpg -d ./password-store/$ARGV[1].gpg | xclip -selection c")
}

sub dmenu_clipper() {
	print my $dmenu_choice = `ls ./password-store/ | /usr/bin/dmenu`;
	chomp($dmenu_choice);
	system("gpg -d ./password-store/$dmenu_choice | xclip -selection c");
}

sub remove_password() {
	unlink "./password-store/$ARGV[1].gpg";
	print "Removed password $ARGV[1].gpg";
}

sub encrypt_password_file() {
	my ($password_name) = @_;
	my $config_file = "./.gpg-id";
	my $keyId = "";
	open(DATA, "<$config_file") or die "Couldn't open config file .gpg-id";
	while (<DATA>) { $keyId = "$_";	}
	chomp($keyId);
	system("/usr/bin/gpg -r $keyId --encrypt ./password-store/$password_name");
	unlink "./password-store/$password_name";
	if (-e "./password-store/$password_name.gpg") {
		print "\nCreated file ./password-store/$password_name.gpg";
	}else{
		print "\nError, file has not been created.";
	}
}

## Function Calls ##
main();
