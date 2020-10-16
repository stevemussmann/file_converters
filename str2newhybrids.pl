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
getopts( 'hm:o:s:z:Z:', \%opts );

# if -h flag is used, or if no command line arguments were specified, kill program and print help
if( $opts{h} ){
  &help;
  die "Exiting program because help flag was used.\n\n";
}

# parse the command line
my( $str, $out, $z0, $z1 ) = &parsecom( \%opts );

my @lines;
my %locushash; #used to find unique alleles at each locus
my %locusmap; #used to create a map between original allele calls and the numbers they are converted to for newhybrids

# read in the file
open( FILE, $str ) or die "Can't open $str: $!\n\n";
while( my $line = <FILE> ){
	chomp( $line );
	push( @lines, $line );
}
close FILE;

#capture the header line as a list of loci
my @loci = split( /\s+/, shift( @lines ) );

foreach my $line( @lines ){
	my @temp = split( /\s+/, $line );
	my $name = shift( @temp );
	my $pop = shift( @temp );
	shift( @temp );
	for( my $i=0; $i< @temp; $i+=2 ){
		if( $temp[$i] != -9 && $temp[$i+1] != -9 ){
			$locushash{$loci[$i/2]}{$temp[$i]}++;
			$locushash{$loci[$i/2]}{$temp[$i+1]}++;
		}
	}
}

#make map of old allele calls to new alleles
foreach my $locus( sort {lc $a cmp lc $b } keys %locushash ){
	#print $locus, "\n";
	my $counter=1;
	foreach my $allele( sort { $a <=> $b } keys %{$locushash{$locus}} ){
		#print $allele, "\n";
		$locusmap{$locus}{$allele}=$counter;
		$counter++;
	}
}

open( OUT, '>', $out ) or die "Can't open $out: $!\n\n";

print OUT "NumIndivs\t", scalar(@lines), "\n";
print OUT "NumLoci\t", scalar(@loci), "\n";
print OUT "Digits\t2\n";
print OUT "Format\tLumped\n\n";

my $string = join( "\t", @loci );

print OUT "LocusNames\t$string\n";

my $indcounter = 0;
foreach my $line( @lines ){
	$indcounter++;
	my @temp = split( /\s+/, $line );
	print OUT $indcounter, "\t";
	if( $temp[1] eq $z0 ){
		print OUT "z0";
	}elsif( $temp[1] eq $z1 ){
		print OUT "z1";
	}
	for( my $i=3; $i<@temp; $i+=2 ){
		print OUT "\t";
		if( $temp[$i] != -9 && $temp[$i+1] != -9 ){
			my $locus1 = sprintf( "%02d", $locusmap{$loci[($i-3)/2]}{$temp[$i]} );
			print OUT $locus1;
			my $locus2 = sprintf( "%02d", $locusmap{$loci[($i-3)/2]}{$temp[$i+1]} );
			print OUT $locus2;
		}else{
			print OUT "0";
		}
	}
	print OUT "\n";
	
}

close OUT;

#print Dumper(\%locusmap);

exit;
#####################################################################################################
############################################ Subroutines ############################################
#####################################################################################################

# subroutine to print help
sub help{
  
  print "\nstr2newhybrids.pl is a perl script developed by Steven Michael Mussmann\n\n";
  print "To report bugs send an email to mussmann\@email.uark.edu\n";
  print "When submitting bugs please include all input files, options used for the program, and all error messages that were printed to the screen\n\n";
  print "Program Options:\n";
  print "\t\t[ -h | -o | -s | -z | -Z ]\n\n";
  print "\t-h:\tUse this flag to display this help message.\n";
  print "\t\tThe program will die after the help message is displayed.\n\n";
  print "\t-o:\tUse this flag to specify the output file name.\n";
  print "\t\tIf no name is provided, the file extension \".newhybrids\" will be appended to the input file name.\n\n";
  print "\t-s:\tUse this flag to specify the name of a structure file in single line format with a header line of locus values.\n\n";
  print "\t-z:\tUse this flag to specify the population name or number in the structure file that corresponds to one parental population (z0).\n\n";
  print "\t-Z:\tUse this flag to specify the population name or number in the structure file that corresponds to the second parental population (z1).\n\n";
  
}

#####################################################################################################
# subroutine to parse the command line options

sub parsecom{ 
  
  my( $params ) =  @_;
  my %opts = %$params;
  
  # set default values for command line arguments
  my $str = $opts{s} || die "No input file specified.\n\n"; #used to specify input file name.
  my $out = $opts{o} || "$str.newhybrids"  ; #used to specify output file name.
  my $z0 = $opts{z} || ""; #used to specify z0
  my $z1 = $opts{Z} || ""; #used to specify z1

  return( $str, $out, $z0, $z1 );

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
