#!/usr/bin/perl

use warnings;

sub uniq {
    my %seen;
    grep !$seen{$_}++, @_;
}

my @users = `w | awk {'print \$1'}`;
chomp @users;
splice @users, 0, 2;

my $allucnt = scalar @users; #0+@users;

my @filtered = uniq(@users);

my $filtereducnt = scalar @filtered;

if ($filtereducnt > 5){
   print "ERROR too many different users logged in! \n";
   exit 1;	
}
else{
   exit 0;
}
