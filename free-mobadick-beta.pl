use MIME::Base64;
use Modern::Perl; #ez a say miatt kell
use utf8;
use Encode; #ez nem kell
use Data::Dumper qw(Dumper);
use POSIX; #ez a floor miatt kell
use Archive::Zip;

#$license_string előállítása:
#$type=1 #Professional:1, Educational:3, Personal:4
#$username=feketej #lehet bármi
#$major_version=20 #integer
#$minor_version=5  #integer
#$count=1  #hány fős licenszet akarsz
#$major_version . 3 . $minor_version . 6 . $minor_version
#0, 0, 0
my ($username, $version) = @ARGV;
my ($major_version, $minor_version) = split /\./, $version;
my $type=1;
my $count=1;
my $license_string = $type . '#' . $username . '|' . $major_version . $minor_version . '#' . $count . '#' . $major_version . '3' . $minor_version . '6' . $minor_version . '#' . '0' . '#' . '0' . '#' . '0' . '#';
say 'LICENSE STRING:';
say $license_string;
my $string = '1#feketej|205#1#203565#0#0#0#';

my $encrypted = '6k.-#-<-"4zx}kykzx{}~}kxkxkxk';
my $encoded = encode_base64($encrypted);
print $encoded;
print "\n";

#6k. 3 bájtból előállítani 3042102 intet    . * 256**2 + k * 256**1 + 6
my($byte) = unpack("A3", '6k.');
print $byte;
print "\n";

say unpack "N", pack "C4", 0, 171, 52, 33; #big
say unpack "V", pack "C4", 0, 171, 52, 33; #little

say unpack "V", pack "C3", 54, 107, 46;
#say unpack "V", pack "C4", 0, 46, 107, 54;
#3042102 = 46 * 256**2 + 107 * 256 + 54
#3042102 = 3014656 + 27392 + 54


my $VariantBase64Table = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=';
my @VariantBase64Dict = split //, $VariantBase64Table;
#my $sorsz = 0;
#my %VariantBase64ReverseDict  = map { $_ => $sorsz++ } @VariantBase64Dict;
#print Dumper \%VariantBase64ReverseDict ;

sub VariantBase64Encode {
	my $input_string = shift;
	my $len = length($input_string);
	my $blocks_count = floor($len / 3);
	my $left_bytes = $len % 3;
	say $blocks_count;
	my $coding_int = 0;
	my $result = '';
	my $block;

	my @arr = ($input_string =~ m/.../g );
	print Dumper \@arr;
	print "\n";
	foreach my $str (@arr) {
		my @chars = split //, $str;
		my $c0 = shift @chars;
		my $i0 = ord($c0) * 1;
		my $c1 = shift @chars;
		my $i1 = ord($c1) * 256;
		my $c2 = shift @chars;
		my $i2 = ord($c2) * 256 * 256;
		$coding_int = $i2 + $i1 + $i0;
		print "$coding_int\n";
		#ezután jön a bitwise and &
		#$coding_int & 0x3f --> 45
		$block = $VariantBase64Dict[$coding_int & 0x3f];
		$block .= $VariantBase64Dict[(($coding_int >> 6) & 0x3f)];
		$block .= $VariantBase64Dict[(($coding_int >> 12) & 0x3f)];
		$block .= $VariantBase64Dict[(($coding_int >> 18) & 0x3f)];
		#print (($coding_int >> 6) & 0x3f);
		$result .= $block;
	}
	if ($left_bytes == 0){
		return $result;
	} elsif ($left_bytes == 1) {
		my $cn = substr $input_string, -1;
		$coding_int = ord($cn);
		$block = $VariantBase64Dict[$coding_int & 0x3f];
		$block .= $VariantBase64Dict[(($coding_int >> 6) & 0x3f)];
		$result .= $block;
		return $result;
	} else {
		my $cn1 = chop($input_string); #107 * 256 = 27392 -> +120 = 27512
		my $in1 = ord($cn1) * 256;
		my $cn2 = chop($input_string); #120
		my $in2 = ord($cn2);
		$coding_int = $in1 + $in2;
		$block = $VariantBase64Dict[$coding_int & 0x3f];
		$block .= $VariantBase64Dict[(($coding_int >> 6) & 0x3f)];
		$block .= $VariantBase64Dict[(($coding_int >> 12) & 0x3f)];
		$result .= $block;
		return $result;
	}
}

sub EncryptBytes {
	my ($key, $input_string) = @_;
	my @bs = split //, $input_string;
	my $result = '';#18477
	for (my $i=0; $i < scalar(@bs); $i++){
		
		if($i == 0){
			$result .= chr(ord($bs[$i]) + 5);
		}
		else {
			$result .= chr(ord($bs[$i]) ^ (($key >> 8) & 0xff));
			$key = (ord($bs[$i - 1]) ^ (($key >> 8) & 0xff) ) & $key | 0x482D;
		}
	}
	say 'and the RESULT is:';
	say $result;
	return $result;
}

my $res = EncryptBytes(18477, $license_string);
my $oui = VariantBase64Encode($encrypted);
my $prokey = VariantBase64Encode($res);
say 'ennek kene lennie: ';
say $oui;
say 'es ez lett:';
say $prokey;


#my $charac = '.';
#my $code = ord($charac);
#my $code = 54;
#my $char = chr($code);

#my $utf8_octets = encode("UTF-8", $ch);
#print sprintf("Decimal: %d, Hex: %x, Bits: %b\n", $code, $code, $code);



#TODO beleírni Pro.key nevű fájlba a $prokey-t és betömöríteni zipfájlként Custom.mxtpro néven.

my $filename = 'Pro.key';
open(my $fh, ">", $filename) or die "Nem sikerult megnyitni a fajlt: $filename mert $!";
print $fh "$prokey";
close $fh;

my $zip = Archive::Zip->new();
my $member = $zip->addFile($filename);
$zip->writeToFileNamed('Custom.mxtpro');

