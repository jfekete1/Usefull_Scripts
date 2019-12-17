#!/usr/bin/perl

my $k8sResources = `kubectl api-resources | awk '{print \$1}'`;
my @resources = split("\n", $k8sResources);
shift @resources;

foreach $resource (@resources)
{
  my $command = 'kubectl get ' . $resource . ' --all-namespaces';
  print "############################################################################\n";
  print "Getting resources of type: " . uc($resource) . "\n   -with command: $command \n";
  system($command);
  print "############################################################################\n\n\n\n\n";
}
