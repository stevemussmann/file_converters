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
getopts( 'hm:o:s:', \%opts );

# if -h flag is used, or if no command line arguments were specified, kill program and print help
if( $opts{h} ){
  &help;
  die "Exiting program because help flag was used.\n\n";
}

# parse the command line
my( $str, $out, $map ) = &parsecom( \%opts );

# declare variables
my @strlines; # array to hold lines from structure file
my @maplines; # array to hold lines from map file
my %popcounts; # hash to hold counts of individuals in each population
#my %names; # hash to store list of names from input file
my %popmap; # hash to hold key/value pairs of individual/population
my $numloci;
my %hohoa;

# put files into array
&filetoarray( $str, \@strlines );
&filetoarray( $map, \@maplines );
=pod
for(my $i = 1; $i < @strlines; $i+=2){
	my @temp = split(/\s+/, $strlines[$i]);
	$names{$temp[0]}++;
}
=cut
# turn map into hash (key = population, value = count)
foreach my $item( @maplines ){
	my @temp = split( /\s+/, $item );
	$popcounts{$temp[1]}++;
}

foreach my $item( @maplines ){
	my @temp = split(/\s+/, $item);
	push(@{$popmap{$temp[1]}}, $temp[0]);
}

for(my $i=1; $i<@strlines; $i+=2){
	my @allele1 = split(/\s+/, $strlines[$i-1]);
	my @allele2 = split(/\s+/, $strlines[$i]);

	my $name = shift(@allele1);
	shift(@allele2);

	$numloci = scalar(@allele1);

	@{$hohoa{$name}{"allele1"}} = @allele1;
	@{$hohoa{$name}{"allele2"}} = @allele2;
}

open(OUT, '>', $out) or die "Can't open $out: $!\n\n";

foreach my $pop( sort keys %popmap ){
	foreach my $ind( @{$popmap{$pop}} ){
		print OUT $ind, " ", $pop;
		for( my $i=0; $i<@{$hohoa{$ind}{"allele1"}}; $i++ ){
			my @array = qw(0.0 0.0 0.0 0.0);
			if( ${$hohoa{$ind}{"allele1"}}[$i] ne "-9" ){
				$array[${$hohoa{$ind}{"allele1"}}[$i]]+=0.5;
				$array[${$hohoa{$ind}{"allele2"}}[$i]]+=0.5;
			}
			for( my $j=0; $j<@array; $j++ ){
				$array[$j] = sprintf("%.1f", $array[$j]);
			}
			my $str = join( ',', @array );
			print OUT " ", $str;
			
		}
		print OUT "\n";
	}
}

close OUT;


#print Dumper(\%names);

#print Dumper(\%popcounts);

#print Dumper(\%popmap);

#print Dumper(\%hohoa);

exit;

#####################################################################################################
############################################ Subroutines ############################################
#####################################################################################################

# subroutine to print help
sub help{
  
  print "\nstr2sp_delim.pl is a perl script developed by Steven Michael Mussmann\n\n";
  print "To report bugs send an email to mussmann\@email.uark.edu\n";
  print "When submitting bugs please include all input files, options used for the program, and all error messages that were printed to the screen\n\n";
  print "Program Options:\n";
  print "\t\t[ -h | -m | -o | -s ]\n\n";
  print "\t-h:\tUse this flag to display this help message.\n";
  print "\t\tThe program will die after the help message is displayed.\n\n";
  print "\t-m:\tUse this flag to specify your population map text file.\n";
  print "\t\tThis is a tab delimited file specifying the sample name in the first column and population name in the second.\n\n";
  print "\t-o:\tUse this flag to specify the output file name.\n";
  print "\t\tIf no name is provided, the file extension \".arp\" will be appended to the input file name.\n\n";
  print "\t-s:\tUse this flag to specify the name of the structure file produced by pyRAD.\n\n";
  
}

#####################################################################################################
# subroutine to parse the command line options

sub parsecom{ 
  
  my( $params ) =  @_;
  my %opts = %$params;
  
  # set default values for command line arguments
  my $str = $opts{s} || die "No input file specified.\n\n"; #used to specify input file name.  This is the input snps file produced by pyRAD
  my $out = $opts{o} || "$str.txt"  ; #used to specify output file name.  If no name is provided, the file extension ".genepop" will be appended to the input file name.

  my $map = $opts{m} || die "No input population map file specified.\n\n"; #used to specify tab-delimited population map file  

  return( $str, $out, $map );

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

  # close input file
  close FILE;

}

#####################################################################################################
