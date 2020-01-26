#!/usr/bin/perl
use Net::SSH::Perl;

my $nodeIP='192.168.0.129';
my $username = 'osboxes';
my $password = 'osboxes.org';
#TODO GET IP FOR node01
my $ssh = Net::SSH::Perl->new($nodeIP);
$ssh->login($username, $password);

my ($stdout,$stderr) = $ssh->cmd("hostname");
print $stdout;
