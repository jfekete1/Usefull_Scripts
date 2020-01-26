#!/usr/bin/perl
use Net::SSH::Perl;
use Config::Hosts;
 
my $hosts = Config::Hosts->new();
    $hosts->read_hosts(); # reads default /etc/hosts
    $hosts->insert_host(ip => "8.8.8.8", hosts => [qw(host1 host2)]);
    $hosts->write_hosts("/tmp/hosts");
    
my $nodeIP='192.168.0.129';
my $username = 'osboxes';
my $password = 'osboxes.org';
#TODO GET IP FOR node01
my $ssh = Net::SSH::Perl->new($nodeIP);
$ssh->login($username, $password);

my ($stdout,$stderr) = $ssh->cmd("hostname");
print $stdout;
