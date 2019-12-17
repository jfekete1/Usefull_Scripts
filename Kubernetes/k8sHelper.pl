#!/usr/bin/perl
use strict;
use warnings;
use 5.010;
no warnings 'experimental';
use Term::ANSIColor;

my $object = "";
if ($ARGV[0]){ $object = $ARGV[0];}

sub imperativeText {
   print color('bold blue');
   say "Imperative $_ example:";
   print color('reset');
}
sub declarativeText {
   print color('bold yellow');
   say "Declarative $_ example:";
   print color('reset');
}

given ($object) {
   when ($_ eq "pod") {
       imperativeText($_);
       say "kubectl run --generator=run-pod/v1 nginx-pod --image=nginx:alpine\n";
       declarativeText($_);
       say "apiVersion: v1 \nkind: Pod \nmetadata:\n  name: nginx-pod\nspec:\n  containers:\n  - name: nginx-container\n    image: nginx:alpine\n";
   }
   when ($_ eq "service") {
       imperativeText($_);
       say "$_ asdasdasd";
       declarativeText($_);
       say "dasdasdasd $_";
   }
   default {
       print color('bold red');
       say "No information on object $_ !!";
       print color('reset');
   }
}
