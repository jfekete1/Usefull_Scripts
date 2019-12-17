#!/usr/bin/perl
use strict;
use warnings;
use 5.010;

open my $fh, '<', 'tmp.yml' or die "Can't open file $!";
read $fh, my $file_content, -s $fh;

my @array = split(/\n/, $file_content);
my $res = join "\\n", @array;

say $res;
