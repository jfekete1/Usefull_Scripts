use strict;
use warnings;
use 5.010;
use Data::Dumper qw(Dumper);

my $searchString = $ARGV[0];
my $file = 'tmp.yml';
my @leadingSpaceArray;
my @linesArray;
my @parentsArray;
my @childrenArray;
my $currentSpaceCount = 0;
my $currentIndex = 0;
my $initialIndex = 0;
my $initialSpaceCount = 0;

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
if($searchedLines eq ""){say "Use plural form instead of singular !! For example \"volumes\" instead of \"volume\"";}
my @searchLns = split(/\n/, $searchedLines);

foreach my $searchedLine (@searchLns) {
  my @searchedArray = split(/:/, $searchedLine, 2);
  $currentIndex = $searchedArray[0] - 1;
  $initialIndex = $currentIndex;
  $currentSpaceCount = getLeadingSpaces($searchedArray[1]);
  $initialSpaceCount = $currentSpaceCount;
  getParentsRecursively();
  print reverse(@parentsArray);
  print $linesArray[$initialIndex];
  if($ARGV[1]){
    if($ARGV[1] eq "--withChildren" || $ARGV[1] eq "--withChilds" || $ARGV[1] eq "-wc"){
      getChildren();
	  foreach my $children (@childrenArray){
	    print $children;
	  }
    }
  }
  @parentsArray = ();
  @childrenArray = ();
  say "\n";
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

sub getChildren {
  for(my $i=$initialIndex; $i<scalar(@leadingSpaceArray); $i++){
    if($initialSpaceCount < $leadingSpaceArray[$i+1]){
	  push @childrenArray, $linesArray[$i+1];
	}else{
	  last;
	}
  }
}
