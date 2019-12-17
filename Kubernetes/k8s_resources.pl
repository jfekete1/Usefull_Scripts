#!/usr/bin/perl
use Term::ANSIColor;

print color('bold blue');
print "This text is bold blue.\n";
print color('reset');

my $k8sResources = `kubectl api-resources | awk '{print \$1}'`;
my @resources = split("\n", $k8sResources);
shift @resources;

foreach $resource (@resources)
{
  my $command = 'kubectl get ' . $resource . ' --all-namespaces';
  print "############################################################################\n";
  print "Getting resources of type: ";
  print color('bold blue');
  print "" . uc($resource);
  print color('reset');
  print "\n   -with command: ";
  print color('bold yellow');
  print "$command \n";
  print color('reset');
  system($command);
  print "############################################################################\n\n\n\n\n";
}
