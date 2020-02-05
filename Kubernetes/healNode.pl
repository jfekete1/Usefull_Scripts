#!/usr/bin/perl

my $masterIP = $ARGV[0];
my $nodeIP   = $ARGV[1];

`echo \"$masterIP master\n$nodeIP node01\n\" >> /etc/hosts`;
`systemctl stop docker`;
`rm -rf /var/lib/cni`;
`systemctl start docker`;
`kubeadm reset`;
`rm -rf /etc/cni`;
`systemctl daemon-reload`;
`systemctl restart kubelet`;
`swapoff -a`;

print "Megadhatod a join commandot...";
