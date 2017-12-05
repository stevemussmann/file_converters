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
getopts( 'hn:o:', \%opts );

# if -h flag is used, or if no command line arguments were specified, kill program and print help
if( $opts{h} ){
	&help;
	die "Exiting program because help flag was used.\n\n";
}

# parse the command line
my( $nex, $out ) = &parsecom( \%opts );

# declare variables
my @lines; # array to hold lines from input nexus file
my %translate;
my @trees;

open( NEX, $nex ) or die "Can't open $nex: $!\n\n";

while( my $line = <NEX> ){
	chomp( $line );
	$line =~ s/^\s+|\s+$//g;
	push( @lines, $line );
}

close NEX;

my $record = 0;

foreach my $line( @lines ){
	if($line eq "Translate" ){
		$record = 1;
	}
	if( $line eq ";" ){
		$record = 0;
	}
	if( $record == 1 && $line ne "Translate"){
		$line =~ s/\,//g;
		#print $line, "\n";
		my @stuff = split(/\s+/, $line);
		$translate{$stuff[0]} = $stuff[1];
	}
}

foreach my $line( @lines ){
	if( $line =~ /^tree\sB/ ){
		$line =~ s/tree\sB_\d+\.\d+\s=.+\]\s//g;
		push( @trees, $line );
	}	
}

foreach my $key (sort {$b <=> $a}  keys %translate ){
	for( my $i=0; $i<@trees; $i++ ){
		$trees[$i] =~ s/\Q$key/\Q$translate{$key}/g;
	}
}

open( OUT, '>', $out ) or die "Can't open $out: $!\n\n";

foreach my $tree( @trees ){
	print OUT $tree, "\n";
}

close OUT;

#print Dumper(\%translate);
#print Dumper(\@trees);

exit;


#####################################################################################################
############################################ Subroutines ############################################
#####################################################################################################
# subroutine to print help

sub help{
	print "\nnex2newick.pl is a perl script developed by Steven Michael Mussmann\n\n";
	print "To report bugs send an email to mussmann\@email.uark.edu\n";
	print "When submitting bugs please include all input files, options used for the program, and all error messages that were printed to the screen\n\n";
	print "Program Options:\n";
	print "\t\t[ -h | -o | -n ]\n\n";
	print "\t-h:\tUse this flag to display this help message.\n";
	print "\t\tThe program will die after the help message is displayed.\n\n";
	print "\t-o:\tUse this flag to specify the output file name.\n";
	print "\t\tIf no name is provided, the file extension \".tre\" will be appended to the input file name.\n\n";
	print "\t-p:\tUse this flag to specify the name of a nexus tree file.\n\n";
}

#####################################################################################################
# subroutine to parse the command line options

sub parsecom{
	my( $params ) =  @_;
	my %opts = %$params;

	# set default values for command line arguments
	my $file = $opts{n} || die "No input file specified.\n\n"; #used to specify input nexus file name.
	my $out = $opts{o} || "$file.phy"  ; #used to specify output file name.  If no name is provided, the file extension ".tre" will be appended to the input file name

	return( $file, $out );
}
#####################################################################################################
