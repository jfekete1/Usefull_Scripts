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

sub getLeadingSpaces {
  my $str = $_[0];
  $str =~ /^(\s*-*\s*)/;
  my $spaceCount = length($1);
  return $spaceCount;
}

#find the needed line in file
my $searchedLine = `grep -in $searchString $file | head -1`;

#get the number of leading spaces and line number in found line
my @searchedArray = split(/:/, $searchedLine, 2);
$currentIndex = $searchedArray[0] - 1;
my $initialIndex = $currentIndex;
$currentSpaceCount = getLeadingSpaces($searchedArray[1]);
#say $currentIndex;
#say $currentSpaceCount;



#search for lines with smaller amount of leading spaces
#loop through the file and get the leading space count for all lines, save that to an array

open my $info, $file or die "Could not open $file: $!";

while( my $line = <$info>)  {
    push @linesArray, $line;
        push @leadingSpaceArray, getLeadingSpaces($line);
}

close $info;
#loop through that array, and find the biggest linenumbered line where the spacecount is 3 smaller than the searched line and the linenumber is smaller too.
#foreach my $n (@leadingSpaceArray) {
  #say $n;
#}
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
getParentsRecursively();

#save that linenumber and spacenumber
#call the function recursively again, to find the line which has 3 less space and has the biggest line number smaller than the saved line
#say Dumper \@parentsArray;
print reverse(@parentsArray);
print $linesArray[$initialIndex];
#say Dumper \@linesArray;
#say Dumper \@leadingSpaceArray;
