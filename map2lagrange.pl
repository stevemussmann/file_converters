#!/usr/bin/perl

use warnings;
use strict;
use Getopt::Std;
use Data::Dumper;

# kill program and print help if no command line arguments were given
if( scalar( @ARGV ) == 0 ){
  &help;
  die "Exiting program because no command line options were used.\n\n";
}

# take command line arguments
my %opts;
getopts( 'hm:o:', \%opts );

# if -h flag is used, or if no command line arguments were specified, kill program and print help
if( $opts{h} ){
  &help;
  die "Exiting program because help flag was used.\n\n";
}

# parse the command line
my( $config, $data, $map, ) = &parsecom( \%opts );

# declare global variables
my @maplines; #file to hold lines from map file
my %hash; #hash to hold sample -> locality data
my %sites; #hash to hold siteName -> count data

&filetoarray( $map, \@maplines );

foreach my $line ( @maplines ){
	#print $line, "\n";
	my @temp = split( /\s+/, $line);
	$hash{$temp[0]} = $temp[1];
	$sites{$temp[1]}++;
}

my $numsites = keys(%sites);
my $numtax = keys(%hash);

open(CON, '>', $config) or die "Can't open $config: $!\n\n";

print CON "treefile = FILE.tre\n";
print CON "datafile = $data\n";
print CON "areanames =";

foreach my $site(sort keys %sites){
	print CON " $site";
}

print CON "\n";
print CON "ancstate = _all_\n";
print CON "states\n";

close CON;

open(DAT, '>', $data) or die "Can't open $data: $!\n\n";

print DAT "$numtax\t$numsites\n";
foreach my $ind( sort keys %hash ){
	print DAT "$ind\t";
	foreach my $site( sort keys %sites ){
		if( $hash{$ind} eq $site){
			print DAT "1";
		}else{
			print DAT "0";
		}
	}
	print DAT "\n";
}

close DAT;

#print Dumper(\%hash);
#print Dumper(\%sites);

exit;


#####################################################################################################
############################################ subroutines ############################################
#####################################################################################################
# subroutine to print help
sub help{
  
  print "\nstr2immanc.pl is a perl script developed by Steven Michael Mussmann\n\n";
  print "To report bugs send an email to mussmann\@email.uark.edu\n";
  print "When submitting bugs please include all input files, options used for the program, and all error messages that were printed to the screen\n\n";
  print "Program Options:\n";
  print "\t\t[ -h | -m | -o ]\n\n";
  print "\t-h:\tDisplay this help message.\n";
  print "\t\tThe program will die after the help message is displayed.\n\n";
  print "\t-m:\tSpecify your population map text file.\n";
  print "\t\tThis is a tab delimited file specifying the sample name in the first column and population name in the second.\n\n";
  print "\t-o:\tUse this flag to specify the output file name.\n";
  print "\t\tIf no name is provided, the file extension \".data\" will be appended to the input file name.\n\n";
  
}

#####################################################################################################
# subroutine to parse the command line options

sub parsecom{ 
  
	my( $params ) =  @_;
	my %opts = %$params;
  
	# set default values for command line arguments
	my $map = $opts{m} || die "No input population map file specified.\n\n"; #used to specify tab-delimited population map file  
	my $out = $opts{o} || die "No output file prefix specified.\n\n"  ; #used to specify output file name.  If no name is provided, the file extension ".data" will be appended to the input file name.

	my $config = "$out.config";
	my $data = "$out.data";


	return( $config, $data, $map );

}

#####################################################################################################
# subroutine to put file into an array

sub filetoarray{

  my( $infile, $array ) = @_;

  
  # open the input file
  open( FILE, $infile ) or die "Can't open $infile: $!\n\n";

  # loop through input file, pushing lines onto array
  while( my $line = <FILE> ){
    chomp( $line );
    next if($line =~ /^\s*$/);
    #print $line, "\n";
    push( @$array, $line );
  }

  #foreach my $thing( @$array ){
  #	print $thing, "\n";
  #}

  # close input file
  close FILE;

}

#####################################################################################################
