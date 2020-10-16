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

my %map = (
	'A' => '0,0',
	'C' => '3,3',
	'G' => '2,2',
	'T' => '1,1',
	'M' => '0,3',
	'R' => '0,2',
	'W' => '0,1',
	'S' => '3,2',
	'Y' => '3,1',
	'K' => '2,1',
	'N' => '-9,-9',
	'-' => '-9,-9',
);

# parse the command line
my( $phy, $out ) = &parsecom( \%opts );

# declare variables
my @phylines; # array to hold lines from structure file
my %data;

# put files into array
&filetoarray( $phy, \@phylines );

my $header = shift( @phylines );

foreach my $line( @phylines ){
	#print $line, "\n";
	my @temp = split( /\s+/, $line );
	my @loci = split( //, $temp[1]);
	my @converted;
	foreach my $locus( @loci ){
		$locus = uc($locus);
		#print $locus, "\n";
		push( @converted, $map{$locus} );
	}
	foreach my $locus( @converted ){
		my @alleles = split( /,/, $locus );
		push( @{$data{$temp[0]}{"1"}}, $alleles[0] );
		push( @{$data{$temp[0]}{"2"}}, $alleles[1] );
	}
}

open( OUT, '>', $out ) or die "Can't open $out: $!\n\n";

foreach my $ind( sort keys %data ){
	foreach my $allele( sort keys %{$data{$ind}} ){
		my $len = length($ind);
		$len = 10-$len;
		print OUT $ind;
		for( my $i=0; $i<$len; $i++ ){
			print OUT " ";
		}
		print OUT "\t\t\t\t\t";
		foreach my $num( @{$data{$ind}{$allele}} ){
			print OUT "\t", $num;
		}
		print OUT "\n";
	}
}

close OUT;

#print Dumper( \%map );
#print Dumper( \%data );

exit;

#####################################################################################################
############################################ Subroutines ############################################
#####################################################################################################

# subroutine to print help
sub help{
  
  print "\nstr2genepop.pl is a perl script developed by Steven Michael Mussmann\n\n";
  print "To report bugs send an email to mussmann\@email.uark.edu\n";
  print "When submitting bugs please include all input files, options used for the program, and all error messages that were printed to the screen\n\n";
  print "Program Options:\n";
  print "\t\t[ -h | -o | -p ]\n\n";
  print "\t-h:\tUse this flag to display this help message.\n";
  print "\t\tThe program will die after the help message is displayed.\n\n";
  print "\t-o:\tUse this flag to specify the output file name.\n";
  print "\t\tIf no name is provided, the file extension \".str\" will be appended to the input file name.\n\n";
  print "\t-p:\tUse this flag to specify the input phylip file name (required).\n\n";
  
}

#####################################################################################################
# subroutine to parse the command line options

sub parsecom{ 
  
  my( $params ) =  @_;
  my %opts = %$params;
  
  # set default values for command line arguments
  my $phy = $opts{p} || die "No input file specified.\n\n"; #used to specify input file name.  This is the input phylip file.
  my $out = $opts{o} || "$phy.str"  ; #used to specify output file name.  If no name is provided, the file extension ".str" will be appended to the input file name.

  return( $phy, $out );

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
    push( @$array, $line );
  }

  close FILE;

}

#####################################################################################################
