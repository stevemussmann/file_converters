#! /usr/bin/perl

use warnings;
use strict;
use Getopt::Std;

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

# declare variables
my @lines; # array to hold lines from input unlinked_snps file
my @names; # array to hold sequence names
my @seqs; # array to hold sequences

open( PHY, $phy ) or die "Can't open $phy: $!\n\n";

while( my $line = <PHY> ){
	chomp( $line );
	push( @lines, $line );
}

close PHY;

# get rid of phylip header
shift( @lines );

foreach my $line( @lines ){
	my @temp = split( /\s+/, $line );
	push( @names, $temp[0] );
	push( @seqs, $temp[1] );
}

open( OUT, '>', $out ) or die "Can't open $out: $!\n\n";

for(my $i=0; $i<@names; $i++){
	print OUT ">$names[$i]\n";
	print OUT "$seqs[$i]\n";
}

close OUT;

exit;


#####################################################################################################
############################################ Subroutines ############################################
#####################################################################################################
# subroutine to print help

sub help{
	print "\npomo_addpop.pl is a perl script developed by Steven Michael Mussmann\n\n";
	print "To report bugs send an email to mussmann\@email.uark.edu\n";
	print "When submitting bugs please include all input files, options used for the program, and all error messages that were printed to the screen\n\n";
	print "Program Options:\n";
	print "\t\t[ -h | -o | -p ]\n\n";
	print "\t-h:\tUse this flag to display this help message.\n";
	print "\t\tThe program will die after the help message is displayed.\n\n";
	print "\t-o:\tUse this flag to specify the output file name.\n";
	print "\t\tIf no name is provided, the file extension \".fasta\" will be appended to the input file name.\n\n";
	print "\t-p:\tUse this flag to specify the name of a fasta file.\n\n";
}

#####################################################################################################
# subroutine to parse the command line options

sub parsecom{
	my( $params ) =  @_;
	my %opts = %$params;

	# set default values for command line arguments
	my $file = $opts{p} || die "No input file specified.\n\n"; #used to specify input phylip file name.
	my $out = $opts{o} || "$file.fasta"  ; #used to specify output file name.  If no name is provided, the file extension ".fasta" will be appended to the input file name

	return( $file, $out );
}
#####################################################################################################
