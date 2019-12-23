use strict;
use warnings;
use 5.010;
use Data::Dumper qw(Dumper);

my $searchString = $ARGV[0];
my $file = 'tmp.yml';
my @leadingSpaceArray;
my @linesArray;
my @parentsArray;
my $currentSpaceCount = 0;
my $currentIndex = 0;
my $initialIndex = 0;

open my $info, $file or die "Could not open $file: $!";

while( my $line = <$info>)  {   
    push @linesArray, $line;
	push @leadingSpaceArray, getLeadingSpaces($line);
}

close $info;

sub getLeadingSpaces {
  my $str = $_[0];
  $str =~ /^(\s*-*\s*)/;
  my $spaceCount = length($1);
  return $spaceCount;
}

my $searchedLines = `grep -nw $searchString $file`;
my @searchLns = split(/\n/, $searchedLines);
#say Dumper \@searchLns;
foreach my $searchedLine (@searchLns) {
  my @searchedArray = split(/:/, $searchedLine, 2);
  $currentIndex = $searchedArray[0] - 1;
  $initialIndex = $currentIndex;
  $currentSpaceCount = getLeadingSpaces($searchedArray[1]);
  getParentsRecursively();
  print reverse(@parentsArray);
  print $linesArray[$initialIndex];
  @parentsArray = ();
}

sub getParentsRecursively {
  for (my $i=scalar(@leadingSpaceArray); $i>0; $i--){
    if($i < $currentIndex){
      if($leadingSpaceArray[$i] < $currentSpaceCount){
	      push @parentsArray, $linesArray[$i];
	      $currentIndex = $i;
	      $currentSpaceCount = $leadingSpaceArray[$i];
	      getParentsRecursively();
	      last;
	    }
    }
  }
}
