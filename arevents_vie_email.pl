#!/usr/bin/perl
##############################
# Set parameters
##############################
$situationname= $ARGV[0];
$transactionname= $ARGV[1];
$responsetime = $ARGV[2];
$responsetime= $responsetime/1000;
$timestamp = $ARGV[3];
$time = localtime(time);
$mailon= "1";
$maillist = q{valvonta@arek.fi};
$mail2 = q{richard.gabor.sipos@hu.ibm.com};
if($mailon eq "0")
{
exit 0;
}
#chomp $situationname;
#print "1$situationname\\1\n";
#print "2$transactionname\\2\n";
if($situationname =~ /rpevp/ && ($transactionname =~ /arek_TUOT/ || $transactionname =~ /arek_ADA_/))
{       
$sendmail = `echo  "PLEASE DO NOT REPLY TO THIS E-MAIL. It was sent from IBM Tivoli Monitoring System.\n\n$time $transactionname transaction failed.\n\nIBM Tivoli Monitoring System" | mail -r root\@arek.fi -s "IBM end-to-end monitoring: $transactionname transaction failed" -c \"$mail2\" $maillist`;
open(LOG, ">> /opt/IBM/ITM/new_tools/test2.log");
print LOG "$timestamp $situationname $transactionname $responsetime\n";
close(LOG);
}

if($situationname =~ /resptime_gt6c/ && ($transactionname =~ /arek_TUOT/ || $transactionname =~ /arek_ADA_/))
{
$sendmail = `echo  "PLEASE DO NOT REPLY TO THIS E-MAIL. It was sent from IBM Tivoli Monitoring System.\n\n$time $transactionname was slow. Response Time was $responsetime sec.\n\nIBM Tivoli Monitoring System" | mail -r root\@arek.fi -s "IBM end-to-end monitoring: $transactionname transaction was slow" -c \"$mail2\" $maillist`;
open(LOG, ">> /opt/IBM/ITM/new_tools/test_slow2.log");
print LOG "$timestamp $situationname $transactionname $responsetime\n";
if ($transactionname =~ /arek_VAKTYHY/ || $transactionname =~ /arek_VAKTYLA/ || $transactionname =~ /arek_VAKNOLA/)
{
        print LOG "arek_VAKTYHY vagy VAKTYLA vagy VAKNOLA jelzett\n";
}

close(LOG);
}
