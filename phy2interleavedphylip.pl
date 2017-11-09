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

# capture phylip header
my $header = shift( @lines );

foreach my $line( @lines ){
	my @temp = split( /\s+/, $line );
	push( @names, $temp[0] );
	push( @seqs, $temp[1] );
}

#determine how many rounds of printing need to occur
my @headparts = split( /\s+/, $header);
my $prints = int($headparts[1]/50)-1;
my $remainder = $headparts[1]%50;
#print $prints, "\n";
#print $remainder, "\n";

# print first section of file
open( OUT, '>', $out ) or die "Can't open $out: $!\n\n";

print OUT $header, "\n";

if( $prints == 0 ){
	for( my $i=0; $i<@names; $i++ ){
		print OUT $names[$i];
		print OUT "\t";
		print OUT $seqs[$i], "\n";
	}
}else{
	for(my $i=0; $i<@names; $i++){
		print OUT $names[$i];
		print OUT "\t";
		my $sub = substr( $seqs[$i], 0, 50, "" );
		print OUT $sub, "\n";
	}
}

#print middle section of file
if( $prints > 0 ){
	for( my $i=0; $i<$prints; $i++ ){
		print OUT "\n";
		for( my $j=0; $j<@seqs; $j++ ){
			my $sub = substr( $seqs[$j], 0, 50, "" );
			print OUT $sub, "\n";
		}
	}
}

#print final section of file
if( $remainder > 0 && $prints != 0 ){
	print OUT "\n";
	foreach my $line( @seqs ){
		print OUT $line, "\n";
	}
}

#print Dumper(\@seqs);

close OUT;

exit;


#####################################################################################################
############################################ Subroutines ############################################
#####################################################################################################
# subroutine to print help

sub help{
	print "\nphy2interleavedphylip.pl is a perl script developed by Steven Michael Mussmann\n\n";
	print "To report bugs send an email to mussmann\@email.uark.edu\n";
	print "When submitting bugs please include all input files, options used for the program, and all error messages that were printed to the screen\n\n";
	print "Program Options:\n";
	print "\t\t[ -h | -o | -p ]\n\n";
	print "\t-h:\tUse this flag to display this help message.\n";
	print "\t\tThe program will die after the help message is displayed.\n\n";
	print "\t-o:\tUse this flag to specify the output file name.\n";
	print "\t\tIf no name is provided, the file extension \".phy\" will be appended to the input file name.\n\n";
	print "\t-p:\tUse this flag to specify the name of a fasta file.\n\n";
}

#####################################################################################################
# subroutine to parse the command line options

sub parsecom{
	my( $params ) =  @_;
	my %opts = %$params;

	# set default values for command line arguments
	my $file = $opts{p} || die "No input file specified.\n\n"; #used to specify input phylip file name.
	my $out = $opts{o} || "$file.phy"  ; #used to specify output file name.  If no name is provided, the file extension ".phy" will be appended to the input file name

	return( $file, $out );
}
#####################################################################################################
