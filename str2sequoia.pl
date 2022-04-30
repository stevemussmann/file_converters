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
getopts( 'hm:o:s:', \%opts );

# if -h flag is used, or if no command line arguments were specified, kill program and print help
if( $opts{h} ){
  &help;
  die "Exiting program because help flag was used.\n\n";
}

# parse the command line
#my( $str, $out, $map ) = &parsecom( \%opts );
my( $str, $out ) = &parsecom( \%opts );


# data structures to hold data
my @strlines; # array to hold lines from structure file
my %tempDataHash; # hash to hold intermediate data
my %allelesHash; # hash to hold allele counts per locus
my %convHash;

&filetoarray( $str, \@strlines );

my $header = shift( @strlines );
my @loci = split(/\s+/, $header);

# read data into structures
foreach my $line( @strlines ){
	my @temp = split( /\s+/, $line );
	my $name = shift( @temp );
	my $newline = join( ',', @temp );
	$tempDataHash{$name} = $newline;
	my $locCount=0;
	for( my $i=1; $i<@temp; $i+=2 ){
		$allelesHash{$loci[$locCount]}{$temp[$i-1]}++;
		$allelesHash{$loci[$locCount]}{$temp[$i]}++;
		$locCount++;
	}
}

# make conversion hash
foreach my $locus( sort keys %allelesHash ){
	my $alleleCount=0;
	foreach my $allele( sort keys %{$allelesHash{$locus}} ){
		if($allele == -9){
			$convHash{$locus}{$allele} = -9;
		}else{
			$convHash{$locus}{$allele} = $alleleCount;
			$alleleCount++;
		}
	}
}

open( OUT, '>', $out ) or die "can't open $out: $!\n\n";
# convert and print data
foreach my $ind( sort keys %tempDataHash ){
	my $locCount=0;
	my @temp = split( /,/, $tempDataHash{$ind} );
	print OUT $ind;
	for( my $i=1; $i<@temp; $i+=2 ){
		print OUT "\t", $convHash{$loci[$locCount]}{$temp[$i-1]};
		print OUT "\t", $convHash{$loci[$locCount]}{$temp[$i]};
		$locCount++;
	}
	print OUT "\n";

}
close OUT;

#print Dumper(\%allelesHash);
#print Dumper(\%convHash);

exit;

#####################################################################################################
############################################ Subroutines ############################################
#####################################################################################################

# subroutine to print help
sub help{

  print "\nstr2sequoia.pl is a perl script developed by Steven Michael Mussmann\n\n";
  print "To report bugs send an email to mussmann\@email.uark.edu\n";
  print "When submitting bugs please include all input files, options used for the program, and all error messages that were printed to the screen\n\n";
  print "Program Options:\n";
  #print "\t\t[ -h | -m | -o | -s ]\n\n";
  print "\t\t[ -h | -o | -s ]\n\n";
  print "\t-h:\tUse this flag to display this help message.\n";
  print "\t\tThe program will die after the help message is displayed.\n\n";
  #print "\t-m:\tUse this flag to specify your population map text file.\n";
  #print "\t\tThis is a tab delimited file specifying the sample name in the first column and population name in the second.\n\n";
  print "\t-o:\tUse this flag to specify the output file name.\n";
  print "\t\tIf no name is provided, the file extension \".seq\" will be appended to the input file name.\n\n";
  print "\t-s:\tUse this flag to specify the name of the structure fil.\n\n";

}

#####################################################################################################
# subroutine to parse the command line options

sub parsecom{

  my( $params ) =  @_;
  my %opts = %$params;

  # set default values for command line arguments
  my $str = $opts{s} || die "No input file specified.\n\n"; #used to specify input file name.  This is the input snps file produced by pyRAD
  my $out = $opts{o} || "$str.seq"  ; #used to specify output file name.  If no name is provided, the file extension ".seq" will be appended to the input file name.

  #my $map = $opts{m} || die "No input population map file specified.\n\n"; #used to specify tab-delimited population map file

  #return( $str, $out, $map );
  return( $str, $out );

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
