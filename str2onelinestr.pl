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
my $popnumcount=0;

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

# make structure file into single line
for(my $i = 1; $i < @strlines; $i+=2){
	my @allele1 = split(/\s+/, $strlines[$i-1]);
	my @allele2 = split(/\s+/, $strlines[$i]);

	my $name = shift(@allele1);
	shift(@allele2);
	#print $name, "\t", $popnumbers{$popmap{$name}}, "\t", $allele1[0], $allele2[0], "\n";
	
	my @all;
	push(@all, $name);
	push(@all, $popnumbers{$popmap{$name}});
	push(@all, 0);
	for(my $j=0; $j<@allele1; $j++){
		push(@all, $allele1[$j]);
		push(@all, $allele2[$j]);
	}
	my $templine = join("\t", @all);
	#push(@singleline, $templine);
	push(@{$tosort{$popnumbers{$popmap{$name}}}}, $templine);
}

open(OUT, '>', $out) or die "Can't open $out: $!\n\n";
foreach my $item(sort keys %tosort ){
	foreach my $line(@{$tosort{$item}}){
		print OUT $line, "\n";
	}
#	print OUT $line, "\n";
}

close OUT;


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
  
  print "\nstr2onelinestr.pl is a perl script developed by Steven Michael Mussmann\n\n";
  print "To report bugs send an email to mussmann\@email.uark.edu\n";
  print "When submitting bugs please include all input files, options used for the program, and all error messages that were printed to the screen\n\n";
  print "Program Options:\n";
  print "\t\t[ -h | -m | -o | -s ]\n\n";
  print "\t-h:\tUse this flag to display this help message.\n";
  print "\t\tThe program will die after the help message is displayed.\n\n";
  print "\t-m:\tUse this flag to specify your population map text file.\n";
  print "\t\tThis is a tab delimited file specifying the sample name in the first column and population name in the second.\n\n";
  print "\t-o:\tUse this flag to specify the output file name.\n";
  print "\t\tIf no name is provided, the file extension \".str\" will be appended to the input file name.\n\n";
  print "\t-s:\tUse this flag to specify the name of the structure file produced by pyRAD.\n\n";
  
}

#####################################################################################################
# subroutine to parse the command line options

sub parsecom{ 
  
  my( $params ) =  @_;
  my %opts = %$params;
  
  # set default values for command line arguments
  my $str = $opts{s} || die "No input file specified.\n\n"; #used to specify input file name.  This is the input snps file produced by pyRAD
  my $out = $opts{o} || "$str.str"  ; #used to specify output file name.  If no name is provided, the file extension ".out" will be appended to the input file name.

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
