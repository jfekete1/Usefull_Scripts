#!/usr/bin/perl

my $masterIP = $ARGV[0];
my $nodeIP   = $ARGV[1];

`sed -r \"s/^\\s*[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+(\\s+master)/$masterIP\\1/\"`;
`sed -r \"s/^\\s*[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+(\\s+master)/$nodeIP\\1/\"`;
`systemctl stop docker`;
`rm -rf /var/lib/cni`;
`systemctl start docker`;
`kubeadm reset`;
`rm -rf /etc/cni`;
`systemctl daemon-reload`;
`systemctl restart kubelet`;
`swapoff -a`;

print "Megadhatod a join commandot...";
