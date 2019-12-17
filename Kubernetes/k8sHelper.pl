#!/usr/bin/perl
use strict;
use warnings;
use 5.010;
no warnings 'experimental';
use Term::ANSIColor;

my $object = "";
if ($ARGV[0]){ $object = $ARGV[0];}

sub createDescription {
    print color('bold blue');
    say "Imperative $_[0] example:";
    print color('reset');
    say $_[1];
    print color('bold yellow');
    say "Declarative $_[0] example:";
    print color('reset');
    say $_[2];
}

given ($object) {
   when ($_ eq "pod") {
       createDescription($_, "kubectl run --generator=run-pod/v1 nginx-pod --image=nginx:alpine\n", "apiVersion: v1 \nkind: Pod \nmetadata:\n  name: nginx-pod\nspec:\n  containers:\n  - name: nginx-container\n    image: nginx:alpine\n" );
   }
   when ($_ eq "service") {
       createDescription($_, "kubectl expose pod redis --port=6379 --name redis-service", "apiVersion: v1\nkind: Service\nmetadata:\n  labels:\n    run: redis\n  name: redis-service\nspec:\n  ports:\n  - port: 6379\n    protocol: TCP\n    targetPort: 6379\n  selector:\n    run: redis\n  sessionAffinity: None\n  type: ClusterIP\n");
   }
   default {
       print color('bold red');
       say "No information on object $_ !!";
       print color('reset');
   }
}
