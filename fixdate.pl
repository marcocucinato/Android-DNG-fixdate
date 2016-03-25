#!/usr/bin/perl
use Image::ExifTool qw(:Public);
use strict;
use Getopt::Std;
use File::Copy qw(cp);

$Getopt::Std::STANDARD_HELP_VERSION = 1;
our $VERSION = 0.1;


my %options=();
getopts ("hqdb:", \%options);

if (defined $options{h}) {
	HELP_MESSAGE();
exit 0;
}

if ($#ARGV + 1 < 1)  {
	print "I need at least 1 argument; -h for help.";
	exit 1;
}

my $quiet = 0;
$quiet = 1 if defined $options{q};

my $dryrun = 0;
$dryrun = 1 if defined $options{d};

my $backup;
if (defined $options{b}) {
	$backup = ".".$options{b};
} else {
	undef $backup;
}

my $exifTool = new Image::ExifTool;

my @args = <$ARGV[0]>;

foreach (@args) {
	main($_);
}

sub HELP_MESSAGE {
	print <<END;
fixdate - fixes Exif DateTimeOriginal in Android generated DNG files 
(see bug https://code.google.com/p/android/issues/detail?id=157238 )

Usage: $0 -h -q -d -b <ext> filename
	-h: this help
	-q: quiet mode
	-d: Dry run
	-b <ext>: create a backup copy with <ext> extension

END
	exit 0;
}

sub message {
	my $msg = shift(@_);
	if (! $quiet) {
		print $msg;
	}
}

sub main {

	my $fileName = $_;
	my $info = $exifTool->ImageInfo($fileName);

	message("Processing file $fileName\n");

	my $currentTS = $exifTool->GetValue('DateTimeOriginal');

	my ($YY,$MM,$DD,$hh,$mm,$ss) = ($fileName =~ /.*?_(\d\d\d\d)(\d\d)(\d\d)_(\d\d)(\d\d)(\d\d).*/);
	my $newTS = "$YY:$MM:$DD $hh:$mm:$ss";

	message "Old TS: $currentTS\n";
	message "New TS: $newTS\n";

	if ($currentTS eq $newTS) {
		message "Nothing to do, exiting...\n";
		return;
	} 

	return if $dryrun;
	
	my ($success, $errStr) = $exifTool->SetNewValue('DateTimeOriginal', $newTS);

	if (! $success) {
		message "ERROR:\n$errStr";
		return;
	}

	if (defined $backup) {
		my $newFile = $fileName.$backup;
		cp ($fileName, $newFile);
	}
	my $result = $exifTool->WriteInfo($fileName);

	if ($result == 0) {
		my $errorMessage = $exifTool->GetValue('Error');
		my $warningMessage = $exifTool->GetValue('Warning');
		message "ERROR:\n$errorMessage";
	}
}
