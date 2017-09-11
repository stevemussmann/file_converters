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
getopts( 'hm:o:v:', \%opts );

# if -h flag is used, or if no command line arguments were specified, kill program and print help
if( $opts{h} ){
	&help;
	die "Exiting program because help flag was used.\n\n";
}

# parse the command line
my( $vcf, $cf, $map ) = &parsecom( \%opts );

# Declare variables
my %maphash; #species map in a hash.  Key=sample, Value=pop
#my %cfhash; #allelecounts for populations
my @vcflines; #lines from vcf file

# read species map to hash
&maptohash( $map, \%maphash );

# read VCF file to array
&filetoarray( $vcf, \@vcflines);

# remove header lines from array
splice( @vcflines, 0, 11 );

# convert first line to array
my @header = split( /\s+/, shift(@vcflines) );

#parse header to get alphabetical list of populations
my %poplist;
for( my $i=9; $i<@header; $i++ ){
	$poplist{$maphash{$header[$i]}}++;
}

#get number of populations and sites for output header line
my $npops = keys(%poplist);
my $nsites = scalar( @vcflines );

open( OUT, '>', $cf ) or die "Can't open $cf, $!\n\n";

# print first header line
my @outheader;
push( @outheader, "COUNTSFILE" );
push( @outheader, "NPOP $npops" );
push( @outheader, "NSITES $nsites" );
my $printoutheader = join( "\t", @outheader );
print OUT $printoutheader, "\n";

# print second header line
my @outheadertwo;
push( @outheadertwo, "CHROM" );
push( @outheadertwo, "POS" );
foreach my $pop( sort keys %poplist ){
	push( @outheadertwo, $pop );
}
my $printoutheadertwo = join( "\t", @outheadertwo );
print OUT $printoutheadertwo, "\n";


# read the file line by line
foreach my $line( @vcflines ){
	my @temp = split( /\s+/, $line );
	#get chromosome and position
	my $chrom = $temp[0];
	my $pos = $temp[1];

	#assemble array of nucleotides for locus
	my @nucs;
	push( @nucs, $temp[3] );
	if( length($temp[4]) > 1 ){
		my @temp2 = split( /,/, $temp[4] );
		foreach my $item( @temp2 ){
			push( @nucs, $item );
		}
	}else{
		push( @nucs, $temp[4] );
	}
	my %cfhash;
	for( my $i=9; $i<@temp; $i++ ){
		my $pop = $maphash{$header[$i]};

		#check to see if ${cfhash{$pop}{$A}, etc, are undefined
		if( !defined $cfhash{$pop} ){
			my @arr = qw(A C G T);
			foreach my $base( @arr ){
				if( !defined ${$cfhash{$pop}{$base}} ){
					${$cfhash{$pop}{$base}}+=0;
				}
			}
		}
	
		if( $temp[$i] !~ /\.\/\./ ){
			my @locus = split( /\|/, $temp[$i] );
			for(my $j=0; $j<@locus; $j++ ){
				${$cfhash{$pop}{$nucs[$locus[$j]]}}++;
			}
		}
	}
	my @newline;
	push( @newline, $chrom );
	push( @newline, $pos );
	
	foreach my $pop( sort keys %cfhash ){
		my @locus;
		foreach my $base( sort{ lc($a) cmp lc($b) } keys%{$cfhash{$pop}} ){
			push( @locus, ${$cfhash{$pop}{$base}} );
		}
		my $printout = join( ',', @locus );
		push( @newline, $printout );
	}
	my $printline = join( "\t", @newline );
	print OUT $printline, "\n";
}

close OUT;

#print Dumper( \%maphash );
#print Dumper( \%cfhash );

exit;

#####################################################################################################
############################################ Subroutines ############################################
#####################################################################################################
# subroutine to print help

sub help{

	print "\nvcf2cf.pl is a perl script developed by Steven Michael Mussmann\n\n";
	print "To report bugs send an email to mussmann\@email.uark.edu\n";
	print "When submitting bugs please include all input files, options used for the program, and all error messages that were printed to the screen\n\n";
	print "Program Options:\n";
	print "\t\t[ -h | -m | -o | -v ]\n\n";
	print "\t-h:\tUse this flag to display this help message.\n";
	print "\t\tThe program will die after the help message is displayed.\n\n";
	print "\t-m:\tUse this flag to specify your population map text file. The default file is the speckled dace population map\n";
	print "\t\tThis is a tab delimited file specifying the sample name in the first column and population name in the second.\n\n";
	print "\t-o:\tUse this flag to specify the output file name.\n";
	print "\t\tIf no name is provided, the file extension \".cf\" will be appended to the input file name.\n\n";
	print "\t-v:\tUse this flag to specify the name of a vcf file.\n\n";

}

#####################################################################################################
# subroutine to parse the command line options

sub parsecom{
	my( $params ) =  @_;
	my %opts = %$params;
# set default values for command line arguments
	my $file = $opts{v} || die "No input file specified.\n\n"; #used to specify input fasta file name.
	my $out = $opts{o} || "$file.cf"  ; #used to specify output file name.  If no name is provided, the file extension ".cf" will be appended to the input file name
	my $map = $opts{m} || "/home/mussmann/local/scripts/perl/makemap/sample_map.txt"; #used to specify tab-delimited population map file.  The default file is my master list for speckled dace
	return( $file, $out, $map );

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
    push( @$array, $line );
  }

  close FILE;

}

#####################################################################################################
# subtroutine to read population map into a hash
#
sub maptohash{

	my( $infile, $hash ) = @_;

	open( MAP, $infile ) or die "Can't open $map, $!\n\n";

	while( my $in = <MAP> ){
		chomp $in;
		my @line = split( /\s+/, $in );
		$$hash{$line[0]} = $line[1];
	}
	close MAP;

}

#####################################################################################################
