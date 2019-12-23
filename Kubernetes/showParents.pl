use strict;
use warnings;
use 5.010;

my $searchString = "hostPath";

#find the needed line in file
`grep -in $searchString myfile.txt`

#get the number of leading spaces in searched line
my $str = "        for getopts :h opt;; do       #this is just a comment";
$str =~ /^(\s*)/;
my $count = length($1);
say $count;

#search for lines with smaller amount of leading spaces
#loop through myfile and get the leading space count for all lines, save that to an array
#loop through that array, and find the biggest linenumbered line where the spacecount is 3 smaller than the searched line and the linenumber is smaller too.
#save that linenumber and spacenumber
#call the function recursively again, to find the line which has 3 less space and has the biggest line number smaller than the saved line
