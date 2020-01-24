#!/usr/bin/perl
my $IP = `ip addr | grep enp0s3 | grep inet | awk \'{print \$2}\' | cut -d \"/\" -f 1`;

`sed -r \"s/^ *[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+( +master)/$IP\1/\"`;
`systemctl stop kubelet docker`;

# backup old kubernetes data
`mv /etc/kubernetes /etc/kubernetes-backup`;
`mv /var/lib/kubelet /var/lib/kubelet-backup`;

# restore certificates
`mkdir -p /etc/kubernetes`;
`cp -r /etc/kubernetes-backup/pki /etc/kubernetes`;
`rm /etc/kubernetes/pki/{apiserver.*,etcd/peer.*}`;

`systemctl start docker`;

# reinit master with data in etcd
# add --kubernetes-version, --pod-network-cidr and --token options if needed
`kubeadm init --ignore-preflight-errors=DirAvailable--var-lib-etcd --pod-network-cidr=10.244.0.0/16`;
#TODO SAVE JOINTOKEN !!!

# update kubectl config
`cp /etc/kubernetes/admin.conf ~/.kube/config`;

# wait for some time and delete old node
sleep 120
`kubectl get nodes --sort-by=.metadata.creationTimestamp`;
`kubectl delete node \$(kubectl get nodes -o jsonpath=\'{.items[?(\@.status.conditions[0].status==\"Unknown\")].metadata.name}\')`;

# check running pods
`kubectl get pods --all-namespaces`;

########################################################################
ON NODE01
my $username = 'osboxes';
my $password = 'osboxes.org';
#TODO GET IP FOR node01
my $host = 'IP OF NODE01 NEEDED!!';
my $ssh = Net::SSH::Perl->new($host);
$ssh->login($username, $password);

my $chHostfile = "sed -r \"s/^ *[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+( +master)/$IP\1/\"";
my ($stdout,$stderr) = $ssh->cmd("$chHostfile");
my $cmdForIP2 = "ip addr | grep enp0s3 | grep inet | awk \'{print \$2}\' | cut -d \"/\" -f 1";
my $IP2 = $ssh->cmd("$cmdForIP2");
$chHostfile = "sed -r \"s/^ *[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+( +node01)/$IP2\1/\"";
my ($stdout,$stderr) = $ssh->cmd("$chHostfile");

($stdout,$stderr) = $ssh->cmd("systemctl stop kubelet");
($stdout,$stderr) = $ssh->cmd("systemctl stop docker");
($stdout,$stderr) = $ssh->cmd("systemctl start docker");

#TODO befejezni
ON MASTER:
vi /etc/hosts
scp jointoken osboxes@node01:/home/osboxes

ON NODE01:
cat /home/osboxes/jointoken
use command to join !!!!
