#! /usr/bin/perl

use warnings;
use strict;
use Getopt::Std;

if( scalar( @ARGV ) == 0 ){
	&help;
	die "Exiting program because no command line options were used.\n\n";
}

# take command line arguments
my %opts;
getopts( 'p:ho:', \%opts );

# if -h flag is used kill program and print help
if( $opts{h} ){
	&help;
	die "Exiting program because help flag was used.\n\n";
}

# parse the command line
my( $phy, $out ) = &parsecom( \%opts );

# declare variables
my @lines; # array to hold lines from input unlinked_snps file
my @names; # array to hold sequence names
my @seqs; # array to hold sequences
my $outfile = "$phy.nex";

open( PHY, $phy ) or die "Can't open $phy: $!\n\n";

while( my $line = <PHY> ){
	chomp( $line );
	push( @lines, $line );
}

close PHY;

# print out lines for testing
foreach my $item( @lines ){
	#print $item, "\n";
	my @temp = split( /\s+/, $item );
	push( @names, $temp[0] );
	push( @seqs, $temp[1] );
}

# get rid of phylip header
shift(@names);
shift(@seqs);

my $seq_length = length($seqs[0]);
foreach my $item( @seqs ){
	my $current_length = length($item);
	if($current_length != $seq_length){
		die "Check the alignment.\n\n";
	}
	$seq_length = $current_length;
}

my $align_length = scalar(@names);
if($align_length != scalar(@seqs)){
	die "You have different numbers of sequence names and individuals.\n\n";
}

open( OUT, '>', $outfile ) or die "Can't open $outfile: $!\n\n";

print OUT "#NEXUS\n";
print OUT "Begin data;\n";
print OUT "\tDimensions ntax=$align_length nchar=$seq_length;\n";
print OUT "\tFormat datatype=dna missing=? gap=-;\n";
print OUT "\tMatrix\n";

for( my $i=0; $i<$align_length; $i++){
	print OUT $names[$i], "\t";
	print OUT $seqs[$i], "\n";
}

print OUT "\t;\n";
print OUT "End;\n";

close OUT;

exit;
#####################################################################################################
############################################ Subroutines ############################################
#####################################################################################################

# subroutine to print help
sub help{
  
  print "\nphylip2nexus.pl is a perl script developed by Steven Michael Mussmann\n\n";
  print "To report bugs send an email to mussmann\@email.uark.edu\n";
  print "When submitting bugs please include all input files, options used for the program, and all error messages that were printed to the screen\n\n";
  print "Program Options:\n";
  print "\t\t[ -h | -o | -p ]\n\n";
  print "\t-h:\tUse this flag to display this help message.\n";
  print "\t\tThe program will die after the help message is displayed.\n\n";
  print "\t-o:\tUse this flag to specify the output file name.\n";
  print "\t\tIf no name is provided, the file extension \".nex\" will be appended to the input file name.\n\n";
  print "\t-p:\tSpecify the name of a phylip file.\n\n";
  
}

#####################################################################################################
# subroutine to parse the command line options

sub parsecom{ 
  
  my( $params ) =  @_;
  my %opts = %$params;
  
  # set default values for command line arguments
  my $phy = $opts{p} || die "No input file specified.\n\n"; #used to specify input phylip file.
  my $out = $opts{o} || "$phy.nex"  ; #used to specify output file name.  If no name is provided, the file extension ".nex" will be appended to the input file name.


  return( $phy, $out );

}

#####################################################################################################
