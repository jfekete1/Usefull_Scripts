#!/usr/bin/perl

# Program Name: check_dbvrep_process.pl
# Jozsef Fekete
# 11.11.2016
#
# This script is used to check dbvrep process is running properly.
# If not, the script waits for 11 mins and writes into log.
#

my $rc = 0;
my $cmdresult = `ps -fA | grep \"dbvrep MINE PROD --daemon\"`;

my @tab = split(/\s+/, $cmdresult);

open LOG, '>', '/opt/IBM/ITM_S/dbvisit/dbvisit.log';

print LOG "$tab[0]";
print LOG "\n";
print LOG "$tab[1]";
print LOG "\n";
print LOG "$tab[2]";
print LOG "\n";
print LOG "$tab[3]";
print LOG "\n";
print LOG "$tab[4]";
close LOG;
