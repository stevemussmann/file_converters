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
getopts( 'c:hm:o:s:', \%opts );

# if -h flag is used, or if no command line arguments were specified, kill program and print help
if( $opts{h} ){
  &help;
  die "Exiting program because help flag was used.\n\n";
}

# parse the command line
my( $str, $out, $map, $col ) = &parsecom( \%opts );

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

# turn map into hash (key = population, value = count)
foreach my $item( @maplines ){
	my @temp = split( /\s+/, $item );
	$popcounts{$temp[1]}++;
}

foreach my $item( @maplines ){
	my @temp = split(/\s+/, $item);
	push(@{$popmap{$temp[1]}}, $temp[0]);
}

foreach my $line( @strlines ){
	my @temp = split(/\s+/, $line);
	my $name = shift( @temp );
	for( my $i=0; $i<($col+1); $i++ ){
		shift(@temp);
	}
	my @allele1;
	my @allele2;
	for( my $i=1; $i<@temp; $i++ ){
		push( @allele1, $temp[$i-1] );
		push( @allele2, $temp[$i] );
	}

	$numloci = scalar(@allele1);

	@{$hohoa{$name}{"allele1"}} = @allele1;
	@{$hohoa{$name}{"allele2"}} = @allele2;
}

open(OUT, '>', $out) or die "Can't open $out: $!\n\n";

print OUT "[Profile]\n";
print OUT "\tTitle=\"File converted from $str\"\n\n";
print OUT "\tNbSamples=", scalar( keys %popcounts), "\n";
print OUT "\tDataType=STANDARD\n";
print OUT "\tGenotypicData=1\n";
print OUT "\tLocusSeparator=WHITESPACE\n";
print OUT "\tGameticPhase=0\n";
print OUT "\tRecessiveData=0\n";
print OUT "\tMissingData=\"\?\"\n\n";
print OUT "[Data]\n";
print OUT "\t[[Samples]]\n";

foreach my $pop(sort keys %popcounts){
	print OUT "\t  SampleName=\"$pop\"\n";
	print OUT "\t  SampleSize=$popcounts{$pop}\n";
	print OUT "\t  SampleData= {\n";
	my $counter = 0;
	foreach my $ind(@{$popmap{$pop}}){
		$counter++;
		print OUT $counter;
		if($counter < 10){
			print OUT "     1 ";
		}else{
			print OUT "    1 ";
		}
		foreach my $first(@{$hohoa{$ind}{"allele1"}}){
			print OUT "  ";
			if($first == 0){
				print OUT " ?";
			}else{
				print OUT "0";
				print OUT $first+1;
			}
		}
		print OUT "\n\t\t";

		foreach my $second(@{$hohoa{$ind}{"allele2"}}){
			print OUT "  ";
			if($second == 0){
				print OUT " ?";
			}else{
				print OUT "0";
				print OUT $second+1;
			}
		}
		print OUT "\n";
	}
	print OUT "\t  }\n"
}

close OUT;


=pod
print Dumper(\%names);

print Dumper(\%popcounts);

print Dumper(\%popmap);
=cut

#print Dumper(\%hohoa);

exit;

#####################################################################################################
############################################ Subroutines ############################################
#####################################################################################################

# subroutine to print help
sub help{
  
  print "\nstr2arlequin.pl is a perl script developed by Steven Michael Mussmann\n\n";
  print "To report bugs send an email to mussmann\@email.uark.edu\n";
  print "When submitting bugs please include all input files, options used for the program, and all error messages that were printed to the screen\n\n";
  print "Program Options:\n";
  print "\t\t[ -c | -h | -m | -o | -s ]\n\n";
  print "\t-c:\tUse this option to input the number of extra columns between population identifier and the first allele.\n";
  print "\t\tThe default number is 0.\n\n";
  print "\t-h:\tUse this flag to display this help message.\n";
  print "\t\tThe program will die after the help message is displayed.\n\n";
  print "\t-m:\tUse this flag to specify your population map text file.\n";
  print "\t\tThis is a tab delimited file specifying the sample name in the first column and population name in the second.\n\n";
  print "\t-o:\tUse this flag to specify the output file name.\n";
  print "\t\tIf no name is provided, the file extension \".arp\" will be appended to the input file name.\n\n";
  print "\t-s:\tUse this flag to specify the name of the shitty structure file produced by pyRAD.\n\n";
  
}

#####################################################################################################
# subroutine to parse the command line options

sub parsecom{ 
  
  my( $params ) =  @_;
  my %opts = %$params;
  
  # set default values for command line arguments
  my $str = $opts{s} || die "No input file specified.\n\n"; #used to specify input file name.  This is the input snps file produced by pyRAD
  my $out = $opts{o} || "$str.arp"  ; #used to specify output file name.  If no name is provided, the file extension ".genepop" will be appended to the input file name.
  my $col = $opts{c} || "0"; #used to specify number of extra columns between population identifier and first allele.
  my $map = $opts{m} || die "No input population map file specified.\n\n"; #used to specify tab-delimited population map file  

  return( $str, $out, $map, $col );

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
