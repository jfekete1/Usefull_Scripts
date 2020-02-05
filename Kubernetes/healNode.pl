#!/usr/bin/perl

my $masterIP = $ARGV[0];
my $nodeIP   = $ARGV[1];

my $newHosts = `cat /etc/hosts | sed -r \"s/^\\s*[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+(\\s+master)/$masterIP\\1/\"`;
`echo \"$newHosts\" > /etc/hosts`;
$newHosts = `cat /etc/hosts | sed -r \"s/^\\s*[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+(\\s+node01)/$nodeIP\\1/\"`;
`echo \"$newHosts\" > /etc/hosts`;

`systemctl stop docker`;
`rm -rf /var/lib/cni`;
`systemctl start docker`;
`kubeadm reset`;
`rm -rf /etc/cni`;
`systemctl daemon-reload`;
`systemctl restart kubelet`;
`swapoff -a`;

print "Megadhatod a join commandot...";
