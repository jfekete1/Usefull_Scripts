#!/usr/bin/perl
use Net::SSH::Perl;
use Config::Hosts;
 
my $nodeIP   = $ARGV[0];
my $masterIP = `ip addr | grep enp0s3 | grep inet | awk \'{print \$2}\' | cut -d \"/\" -f 1`;
chomp $masterIP;

my $hosts = Config::Hosts->new();
    $hosts->read_hosts(); # reads default /etc/hosts
    $hosts->delete_host('master');
    $hosts->insert_host(ip => $masterIP, hosts => [qw(master)]);
    $hosts->delete_host('node01');
    $hosts->insert_host(ip => $nodeIP, hosts => [qw(node01)]);
    $hosts->write_hosts("/etc/hosts");

print "Stopping Docker... \n";
my $cmdOut = `systemctl stop kubelet docker`;
print $cmdOut;
print "\n";

print "backup old kubernetes data... \n";
$cmdOut = `mv /etc/kubernetes /etc/kubernetes-backup`;
print $cmdOut;
print "\n";
my $cmdOut = `mv /var/lib/kubelet /var/lib/kubelet-backup`;
print $cmdOut;
print "\n";

print "restore certificates... \n";
$cmdOut = `mkdir -p /etc/kubernetes`;
print "" . $cmdOut . "\n";
$cmdOut = `cp -r /etc/kubernetes-backup/pki /etc/kubernetes`;
print "" . $cmdOut . "\n";
$cmdOut = `rm /etc/kubernetes/pki/{apiserver.*,etcd/peer.*}`;
print "" . $cmdOut . "\n";

$cmdOut = `systemctl start docker`;
print "" . $cmdOut . "\n";

print "reinit master with data in etcd... \n";
# add --kubernetes-version, --pod-network-cidr and --token options if needed
`kubeadm init --ignore-preflight-errors=DirAvailable--var-lib-etcd --pod-network-cidr=10.244.0.0/16 > output.txt`;
my $joincmd = `cat output.txt | grep "kubeadm join" -A1`;
print $joincmd;
print "\n";

print "update kubectl config... \n";
`cp /etc/kubernetes/admin.conf ~/.kube/config`;

# wait for some time and delete old node
`kubectl get nodes --sort-by=.metadata.creationTimestamp`;
`kubectl delete node \$(kubectl get nodes -o jsonpath=\'{.items[?(\@.status.conditions[0].status==\"Unknown\")].metadata.name}\')`;

# check running pods
`kubectl get pods --all-namespaces`;

########################################################################
#ON NODE01
my $username = 'osboxes';
my $password = 'osboxes.org';
#TODO GET IP FOR node01
my $ssh = Net::SSH::Perl->new($nodeIP);
$ssh->login($username, $password);

my $chHostfile = "sed -r \"s/^\\s*[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+(\\s+master)/$masterIP\\1/\"";
my ($stdout,$stderr) = $ssh->cmd("$chHostfile");
my $cmdForIP2 = "ip addr | grep enp0s3 | grep inet | awk \'{print \$2}\' | cut -d \"/\" -f 1";
my $IP2 = $ssh->cmd("$cmdForIP2");
$chHostfile = "sed -r \"s/^\\s*[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+(\\s+node01)/$IP2\\1/\"";
my ($stdout,$stderr) = $ssh->cmd("$chHostfile");

($stdout,$stderr) = $ssh->cmd("systemctl stop kubelet");
($stdout,$stderr) = $ssh->cmd("systemctl stop docker");
($stdout,$stderr) = $ssh->cmd("systemctl start docker");

($stdout,$stderr) = $ssh->cmd("$joincmd");
print($stdout, $stderr);

#curl -L http://cpanmin.us | perl - --sudo App::cpanminus
#cpanm Net::SSH::Perl
#date --set="2 OCT 2006 18:00:00"
