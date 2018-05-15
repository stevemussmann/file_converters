#! /usr/bin/perl

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
getopts( 'ho:p:', \%opts );

# if -h flag is used, or if no command line arguments were specified, kill program and print help
if( $opts{h} ){
  &help;
  die "Exiting program because help flag was used.\n\n";
}

# parse the command line
my( $phy, $out ) = &parsecom( \%opts );

#declare variables
my @phyliplines; #array for holding input from file
my %hash; #hash of hashes to hold counts of each base at each site in alignment
my $A=0;
my $C=0;
my $G=0;
my $T=0;

#put phylip file into array
&filetoarray( $phy, \@phyliplines );

#remove phylip header
shift(@phyliplines);

foreach my $ind( @phyliplines ){
	my @temp = split( /\s+/, $ind );
	my @seq = split( //, $temp[1] );
	for( my $i=0; $i<@seq; $i++ ){
		if(($seq[$i] ne "-") && ($seq[$i] ne "N")){
			$hash{$i}{$seq[$i]}++;
		}
	}
}

foreach my $site( sort keys %hash ){
	if((keys %{$hash{$site}} ) == 1){
		foreach my $base(sort keys %{$hash{$site}}){
			#print $base;
			if($base eq "A"){
				$A++;
			}elsif($base eq "C"){
				$C++;
			}elsif($base eq "G"){
				$G++;
			}elsif($base eq "T"){
				$T++;
			}
		}
	#print "\n";
	}
}

print "A = ", $A, "\n";
print "C = ", $C, "\n";
print "G = ", $G, "\n";
print "T = ", $T, "\n\n";

open(BIAS, '>', "$out.stamatakis") or die "Can't open $out.stamatakis: $!\n\n";
print BIAS "$A $C $G $T\n";
close BIAS;

print "Total = ", $A+$C+$G+$T, "\n\n";

open(BIAS, '>', "$out.felsenstein") or die "Can't open $out.felsenstein: $!\n\n";
print BIAS $A+$C+$G+$T, "\n";
close BIAS;

#print Dumper( \%hash );

exit;

#####################################################################################################
############################################ Subroutines ############################################
#####################################################################################################

# subroutine to print help
sub help{
  
  print "\nascbias.pl is a perl script developed by Steven Michael Mussmann\n\n";
  print "To report bugs send an email to mussmann\@email.uark.edu\n";
  print "When submitting bugs please include all input files, options used for the program, and all error messages that were printed to the screen\n\n";
  print "Program Options:\n";
  print "\t\t[ -h | -o | -p ]\n\n";
  print "\t-h:\tUse this flag to display this help message.\n";
  print "\t\tThe program will die after the help message is displayed.\n\n";
  print "\t-o:\tUse this flag to specify the output file name.\n";
  print "\t\tIf no name is provided, the file extension \".bias\" will be appended to the input file name.\n\n";
  print "\t-p:\tUse this flag to specify the input phylip file.\n\n";
  
}

#####################################################################################################
# subroutine to parse the command line options

sub parsecom{ 
  
  my( $params ) =  @_;
  my %opts = %$params;
  
  # set default values for command line arguments
  my $phylip = $opts{p} || die "No input file specified.\n\n"; #used to specify input file name.  This is the input snps file produced by pyRAD
  my $out = $opts{o} || "$phylip.bias"  ; #used to specify output file name.  If no name is provided, the file extension ".out" will be appended to the input file name.
  
  return( $phylip, $out );

}

#####################################################################################################
# subroutine to put a file into an array

sub filetoarray{

	my( $infile, $array ) = @_;

	#open the input file
	open( FILE, $infile ) or die "Can't open $infile: $!\n\n";

	# loop through input file, pushing lines onto array
	while( my $line = <FILE> ){
		chomp( $line );
		next if( $line =~ /^\s*$/ );
		push( @$array, $line );
	}

	close FILE;

}

#####################################################################################################
