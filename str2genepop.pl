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
my @singleline; # array to hold structure file as single line per individual
my %popnumbers; # hash to hold codes for population numbers
my %names; # hash to store list of names from input file
my %popmap; # hash to hold key/value pairs of individual/population
my %tosort; # hash of lines to be sorted before printing
my $numloci;
my $popnumcount=0;
my %genepophoh;

# put files into array
&filetoarray( $str, \@strlines );
&filetoarray( $map, \@maplines );

for(my $i = 1; $i < @strlines; $i+=2){
	my @temp = split(/\s+/, $strlines[$i]);
	$names{$temp[0]}++;
}

# turn map into hash (key = population, value = number)
foreach my $item( @maplines ){
	my @temp = split( /\s+/, $item );
	# check if hey exists in hash, if not add it and increase population count
	if( exists $names{$temp[0]} && !exists($popnumbers{$temp[1]}) ){
		$popnumcount++;
		$popnumbers{$temp[1]} = $popnumcount;
	}
	$popmap{$temp[0]} = $temp[1];
}

# make structure file into genepop format
for(my $i = 1; $i < @strlines; $i+=2){
	my @allele1 = split(/\s+/, $strlines[$i-1]);
	my @allele2 = split(/\s+/, $strlines[$i]);

	my $name = shift(@allele1);
	shift(@allele2);

	$numloci = scalar(@allele1);

	#print $name, "\t", $popnumbers{$popmap{$name}}, "\t", $allele1[0], $allele2[0], "\n";
	
	my @all;
	my @allgenepop;
	for(my $j=0; $j<@allele1; $j++){
		#increment each allele because pyrad used 0 based counting for genotyping.  Genepop uses 0 to denote missing data
		$allele1[$j]++;
		$allele2[$j]++;
		# -9 becomes -8, so this must be converted to the genepop missing data value of 0
		if($allele1[$j] == -8){
			$allele1[$j] = 0;
		}	
		if($allele2[$j] == -8){
			$allele2[$j] = 0;
		}
		
		#front pad each allele with a 0.
		my @templocus;
		push(@templocus, sprintf("%02d", $allele1[$j]));
		push(@templocus, sprintf("%02d", $allele2[$j]));
		
		#join the two alleles for a locus together
		my $temp = join("", @templocus);
		
		#push the locus onto the growing array of loci
		push(@allgenepop, $temp);
	}

	#join together all of the loci
	my $tempgenotype = join(" ", @allgenepop);

	#add the individual to the hash
	$genepophoh{$popmap{$name}}{$name}=$tempgenotype;
}

open(OUT, '>', $out) or die "Can't open $out: $!\n\n";
print OUT "Title line: \"File converted from pyRAD\"\n";
for(my $i=0; $i<$numloci; $i++){
	print OUT "Locus", $i+1, "\n";
}
foreach my $pop(sort keys %genepophoh ){
	print OUT "pop\n";
	foreach my $ind(sort keys %{$genepophoh{$pop}}){
		print OUT $ind, ",\t", $genepophoh{$pop}{$ind}, "\n";;
	}
#	print OUT $line, "\n";
}

close OUT;

#print Dumper(\%genepophoh);
#print Dumper(\%popnumbers);
#print Dumper(\%popmap);
#print Dumper(\%names);


# turn map into hash (key = name, value = population)


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
  print "\t\t[ -h | -m | -o | -s ]\n\n";
  print "\t-h:\tUse this flag to display this help message.\n";
  print "\t\tThe program will die after the help message is displayed.\n\n";
  print "\t-m:\tUse this flag to specify your population map text file.\n";
  print "\t\tThis is a tab delimited file specifying the sample name in the first column and population name in the second.\n\n";
  print "\t-o:\tUse this flag to specify the output file name.\n";
  print "\t\tIf no name is provided, the file extension \".genepop\" will be appended to the input file name.\n\n";
  print "\t-s:\tUse this flag to specify the name of the shitty structure file produced by pyRAD.\n\n";
  
}

#####################################################################################################
# subroutine to parse the command line options

sub parsecom{ 
  
  my( $params ) =  @_;
  my %opts = %$params;
  
  # set default values for command line arguments
  my $str = $opts{s} || die "No input file specified.\n\n"; #used to specify input file name.  This is the input snps file produced by pyRAD
  my $out = $opts{o} || "$str.genepop"  ; #used to specify output file name.  If no name is provided, the file extension ".genepop" will be appended to the input file name.

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

  #foreach my $thing( @$array ){
  #	print $thing, "\n";
  #}

  # close input file
  close FILE;

}

#####################################################################################################
