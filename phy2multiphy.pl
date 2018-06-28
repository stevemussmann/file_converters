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
getopts( 'hp:P:', \%opts );

# if -h flag is used, or if no command line arguments were specified, kill program and print help
if( $opts{h} ){
	&help;
	die "Exiting program because help flag was used.\n\n";
}

# parse the command line
my( $phy, $part ) = &parsecom( \%opts );

# declare variables
my @phylines; # array to hold lines from input unlinked_snps file
my @partlines; # array to hold lines from partition file
my @names; # array to hold sequence names
my @seqs; # array to hold sequences

&filetoarray( $phy, \@phylines );
&filetoarray( $part, \@partlines );

# get rid of phylip header
shift( @phylines );

# separate sample names from sequences
foreach my $line( @phylines ){
	my @temp = split( /\s+/, $line );
	push( @names, $temp[0] );
	push( @seqs, $temp[1] );
}


foreach my $line( @partlines ){
	my @temp = split( /\s+/, $line );
	my @temp2 = split( /\=/, $temp[1] );
	my $name = shift( @temp2 );
	my @coords = split( /\-/, $temp2[0] );
	my @tempseqs;
	foreach my $thing( @seqs ){
		push( @tempseqs, substr( $thing, $coords[0]-1, $coords[1]-$coords[0] ) );
	}

	my @finalseqs;
	my @finalnames;
	my $length;
	for( my $i=0; $i<@names; $i++ ){
		#if( $tempseqs[$i] =~ /^N+N$/ ){
		if( $tempseqs[$i] !~ /^N+N$/ ){
			#print $tempseqs[$i], "\n";
			push( @finalseqs, $tempseqs[$i] );
			push( @finalnames, $names[$i] );
			$length = length($tempseqs[$i]);
		}	
	}

	open( OUT, '>', "$name.phy" ) or die "Can't open $name.phy: $!\n\n";
	my $ntax = scalar(@finalnames);
	print OUT $ntax, " ", $length, "\n";
	for( my $i=0; $i<@finalnames; $i++ ){
		print OUT $finalnames[$i], "\t", $finalseqs[$i], "\n";
	}
	close OUT;
	
}

=pod
foreach my $line( @phylines ){
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
=cut

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
	print "\t\t[ -h | -p | -P ]\n\n";
	print "\t-h:\tUse this flag to display this help message.\n";
	print "\t\tThe program will die after the help message is displayed.\n\n";
	print "\t-p:\tUse this flag to specify the name of a phylip file.\n\n";
	print "\t-P:\tUse this flag to specify the name of a partition file from pyrad.\n\n";

}

#####################################################################################################
# subroutine to parse the command line options

sub parsecom{
	my( $params ) =  @_;
	my %opts = %$params;

	# set default values for command line arguments
	my $file = $opts{p} || die "No input phylip file specified.\n\n"; #used to specify input fasta file name.
	my $part = $opts{P} || die "No partition file specified.\n\n"; #used to specify partition file from pyrad

	return( $file, $part );
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

  close FILE;

}

#####################################################################################################
