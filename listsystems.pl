#!/usr/bin/perl
use strict;
use warnings;

my $cmd = " grep";
my $command = "/opt/IBM/ITM/bin/tacmd listsystems |";
my $filename = $ARGV[0];#'updatedServers.txt';
if (not defined $filename) {
  die "Usage: ./listsystems.pl <listfile>\n";
}
open(my $fh, '<:encoding(UTF-8)', $filename)
or die "Could not open file '$filename' $!";
while (my $row = <$fh>) {
    chomp $row;
    $cmd = $cmd . " -e " . $row;
}

my $comm = $command . $cmd;
print "Running command: ";
print $comm;
print "\n";

my $output = `$comm`;
print $output;
