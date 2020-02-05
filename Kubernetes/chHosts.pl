#!/usr/bin/perl

my $masterIP = $ARGV[0];
my $nodeIP   = $ARGV[1];

my $asdf = `cat /etc/hosts | sed -r \"s/^\\s*[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+(\\s+master)/$masterIP\\1/\"`;
`echo \"$asdf\" > /etc/hosts`;
my $asdf = `cat /etc/hosts | sed -r \"s/^\\s*[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+(\\s+node01)/$nodeIP\\1/\"`;
`echo \"$asdf\" > /etc/hosts`;

print "$asdf \n";
