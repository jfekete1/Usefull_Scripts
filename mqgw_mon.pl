#!/usr/bin/perl
$debug_mode="N";
$mon_path="/opt/IBM/ITM_S/mqgwmon";
#$queue=$ARGV[0];
$environment=$ARGV[0];
$message=$ARGV[1];

############################
# Set time variables
############################
($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)= localtime(time);
$year= $year+1900;
$year2 = $year;
$year=~ s/^..//;
$mon=$mon+1;

if($mon < 10)
{
 $mon="0$mon";
}
if($mday < 10)
{
 $mday="0$mday";
}

$current_date="$year2$mon$mday";

$logfile= "$mon_path\/logs\/$mday$mon$year2\_$environment\_$message.log";


##########################################
# clean up old log files older than 90 days
#########################################
#@clean = `find $mon_path/logs/ -ctime +90 | grep -i "log\$"`;
#foreach(@clean)
#{
#   chop $_;
   #print "delete old log file $_\n";
#   unlink("$_") || print "$!\n";
#}

 

################################################################
#
# Read input & output queue information from properties file
#
################################################################

my %o;
open my $in, "$mon_path/$environment/$environment\_$message.properties" or die $!;
while(<$in>) {
        #$o{$1}=$2 while m/(\S+)=(\S+)/g;
        $o{$1}=$2 while m/(\S+)=(.*)/g;
}
close $in;



################################################################
#
# For debugging purposes 
#
################################################################
if ($debug_mode eq "Y")
{
print "PARAMETERS\n\n";
print "INPUT QUEUE: $o{IN_QUEUE} \n";
print "OUTPUT QUEUE: $o{OUT_QUEUE} \n";
print "SEND MSG: $o{SEND_MSG} \n";
print "RECEIVE MSG: $o{RECEIVE_MSG}\n";


open(MQSEND, "$mon_path/$environment/$o{SEND_MSG}");
@mqmsgs= <MQSEND>;
close(MQSEND);
open(MQRCV, "$mon_path/$environment/$o{RECEIVE_MSG}");
#@mqmsgr= <MQRCV>;
$mqmsgr2 = <MQRCV>;
close(MQRCV);
chomp $mqmsgr2;
#print "Send Message: @mqmsgs\n\n";

#print "Expected receive message: $mqmsgr2\n\n";

#open my $message1, "$mon_path/$environment/$message" or die $!;
#while(<$message1>) {
#   print "TESTISANOMA: $_\n\n";
#}
#close $message1;
 
}
#################################################################
#
# Debug end
#
#################################################################
else
{
open(MQSEND, "$mon_path/$environment/$o{SEND_MSG}");
@mqmsgs= <MQSEND>;
close(MQSEND);
open(MQRCV, "$mon_path/$environment/$o{RECEIVE_MSG}");
#@mqmsgr= <MQRCV>;
$mqmsgr2 = <MQRCV>;
close(MQRCV);
chomp $mqmsgr2;
}


##################################################################
#
# Clear OUT queue before sending a new message
#
##################################################################
$clear_msg = `/usr/bin/su - mqm -c "/usr/mqm/samp/bin/amqsget $o{OUT_QUEUE}"`;
if( $? ne "0")
{
        print "ERROR: $?";
        exit 1;
}

##################################################################
#
#Put message to queue
#
##################################################################
#print "Putting message to the queue...\n";
#print "/usr/mqm/samp/bin/amqsput $o{IN_QUEUE} < $mon_path/$environment/$o{SEND_MSG}\n\n";
#$put_msg = `/usr/bin/su - mqm -c "/usr/mqm/samp/bin/amqsput $o{IN_QUEUE} < $mon_path/$environment/$o{SEND_MSG}"`;
#print "/usr/mqm/samp/ih03/aix/mqputs -f $mon_path/$environment/$environment\_$message.ini";
$put_msg = `/usr/bin/su - mqm -c "/usr/mqm/samp/ih03/aix/mqputs -v -f $mon_path/$environment/$environment\_$message.ini"`;
if( $? ne "0")
{
        print "ERROR: $?";
        exit 1;
}


##################################################################
#
# Check response message from OUT queue
#
##################################################################

$i=0;
do
{

##################################################################
#
# Read message from queue
#
##################################################################

$get_msg = `/usr/bin/su - mqm -c "/usr/mqm/samp/bin/amqsget $o{OUT_QUEUE}"`;
if( $? ne "0")
{
        print "ERROR: $?";
        exit 1;
}

$get_msg =~ s/message\s<(.*)(>|\n>)/$1/s;

my $match = $o{RESULT_STR};
my $count = grep /$match/, $1;

if ( grep( /$match/,$1 )) {
        #print "Ok, correct message founded from $o{OUT_QUEUE} queue\n";
        exit 0;
}

elsif ($1 ne "")
{
        $rmsg= $1;
        $time=localtime(time);
        open(LOG, ">> $logfile");
        print "Correct message not founded from $o{OUT_QUEUE} queue! Response message: $rmsg\n";
        print LOG "$time Correct message not founded from $o{OUT_QUEUE} queue! Response message: $rmsg\n";
        close(LOG);
        exit 1;
}

elsif ($1 eq "" && $i<3)
{
        $rmsg= $1;
        $time=localtime(time);
        if ($rmsg eq "")
        {
                $rmsg = "<EMPTY>";
        }
        open(LOG, ">> $logfile");

        print "Correct message not founded from $o{OUT_QUEUE} queue! Response message: $rmsg\n";
        print LOG "$time Correct message not founded from $o{OUT_QUEUE} queue! Response message: $rmsg\n";
        close(LOG);

        if ( $i eq 2)
        {
        #       print "Correct message not founded from $o{OUT_QUEUE} queue! Response message: $rmsg\n";
                exit 1;
        }
        sleep 5;
        $i++;
}
}
while($i<3);
