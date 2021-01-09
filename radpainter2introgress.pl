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
getopts( '1:2:a:hl:m:o:r:', \%opts );

# if -h flag is used, or if no command line arguments were specified, kill program and print help
if( $opts{h} ){
  &help;
  die "Exiting program because help flag was used.\n\n";
}

# parse the command line
my( $first, $second, $admix, $loc, $map, $paint, $out ) = &parsecom( \%opts );

# declare variables
my @paintlines; # holds lines from radpainter file
my @maplines; # holds lines from population map file
my @loclines; # holds lines from locus list
my %mapData; # holds population map information
my %mapCounts; # holds number of individuals found in each population in radpainter file
my %paintData; # holds genotype data from radpainter file
my %NA; # counts missing data per pop per locus
my %printYN; # keeps track of if a locus should be printed;

# read input files into arrays
&filetoarray( $paint, \@paintlines );
&filetoarray( $map, \@maplines );
&filetoarray( $loc, \@loclines );

# convert population map to hash
foreach my $line( @maplines ){
	chomp( $line );
	my @temp = split( /\s+/, $line );
	$mapData{$temp[0]} = $temp[1];
}

# get hashes of individuals representing groups
my %firstParent;
my %secondParent;
my %admixGroup;
&getGroup($first, \%firstParent );
&getGroup($second, \%secondParent );
&getGroup($admix, \%admixGroup );

# catch header from input radpainter file
my $catch = shift(@paintlines);
chomp($catch);
my @header = split( /\t/, $catch );

# record number of individuals in each population in radpainter file
foreach my $ind( @header ){
	$mapCounts{$mapData{$ind}}++;
}

# read in haplotype data
my $counter=0;
foreach my $line( @paintlines ){
	$counter++;
	my @temp = split( /\t/, $line );
	#print scalar(@temp), "\n";
	for( my $i=0; $i<@temp; $i++ ){
		chomp($temp[$i]);
		# convert missing data to NA values
		if( $temp[$i] eq "" ){
			$temp[$i]="NA";
			$NA{$counter}{$mapData{$header[$i]}}++;
			#print $mapData{$header[$i]}, "\n";
			#print scalar(@header), "\t";
			#print scalar(@temp), "\n";
		}
		# show both alleles of homozygotes
		if( $temp[$i] !~ /\// ){
			$temp[$i] = join( "/", $temp[$i], $temp[$i] );
		}
		push( @{$paintData{$header[$i]}}, $temp[$i] );
	}
}

foreach my $loc( sort keys %NA ){
	#print $loc, "\n";
	my $pr = 1;
	foreach my $pop( sort keys %{$NA{$loc}} ){
		if( $NA{$loc}{$pop} == $mapCounts{$pop} ){
			$pr=0;
			#print( "Locus $loc has no data for a population.\n");
		}
		#print $pop, "\n";
	}
	$printYN{$loc}=$pr;
}

# write admix files for each requested population group
&writeGroupFile( \%firstParent, "$out.p1", \%printYN );
&writeGroupFile( \%secondParent, "$out.p2", \%printYN );
&writeGroupFile( \%admixGroup, "$out.admix", \%printYN );

# print locus information file
my $locusout = "$paint.loci.txt";
open( LOUT, '>', $locusout ) or die "Can't open $locusout: $!\n\n";
print LOUT "locus,type\n";
#foreach my $line( @loclines ){
#	chomp( $line );
#	print LOUT $line, ",C\n";
#}

for( my $i=0; $i<@loclines; $i++ ){
	chomp( $loclines[$i] );
	if( exists( $printYN{$i} ) ){
		if($printYN{$i} == 1){
			print LOUT $loclines[$i], ",C\n";
		}
	}else{
		print LOUT $loclines[$i], ",C\n";
	}

}

close LOUT;

#print Dumper( \%firstParent );
#print Dumper( \%mapData );
#print Dumper( \@header );
#print Dumper( \%paintData );
#print Dumper( \%NA );
#print Dumper( \%mapCounts );
#print Dumper( \%printYN );

exit;

#####################################################################################################
############################################ Subroutines ############################################
#####################################################################################################

# subroutine to print help
sub help{
  
  print "\nradpainter2introgress.pl is a perl script developed by Steven Michael Mussmann\n\n";
  print "To report bugs send an email to mussmann\@email.uark.edu\n";
  print "When submitting bugs please include all input files, options used for the program, and all error messages that were printed to the screen\n\n";
  print "Program Options:\n";
  print "\t\t[ -1 | -2 | -a | -h | -l | -m | -o | -r ]\n\n";
  print "\t-1:\tUse this flag to specify the first parental group.\n";
  print "\t\tMultiple populations can be listed using commas as delimiters.\n\n";
  print "\t-2:\tUse this flag to specify the second parental group.\n";
  print "\t\tMultiple populations can be listed using commas as delimiters.\n\n";
  print "\t-a:\tUse this flag to specify the admixed group.\n";
  print "\t\tMultiple populations can be listed using commas as delimiters.\n\n";
  print "\t-h:\tUse this flag to display this help message.\n";
  print "\t\tThe program will die after the help message is displayed.\n\n";
  print "\t-l:\tUse this flag to specify the locus list (required).\n\n";
  print "\t-m:\tUse this flag to specify the population map file (required).\n\n";
  print "\t-o:\tUse this flag to specify the output file name.\n";
  print "\t\tIf no name is provided, the file extension \".introgress\" will be appended to the input file name.\n\n";
  print "\t-r:\tUse this flag to specify the input radpainter file name (required).\n\n";
  
}

#####################################################################################################
# subroutine to parse the command line options

sub parsecom{ 
  
  my( $params ) =  @_;
  my %opts = %$params;
  
  # set default values for command line arguments
  my $first = $opts{1} || die "First parental population(s) not listed.\n\n";
  my $second = $opts{2} || die "Second parental population(s) not listed.\n\n";
  my $admix = $opts{a} || die "Admixed population(s) not listed.\n\n";
  my $loc = $opts{l} || die "No locus list file specified.\n\n"; #used to specify locus list. This is a file containing names for all loci in the radpainter file (one locus name per line).
  my $map = $opts{m} || die "No population map file specified.\n\n"; #used to specify population map file.  This is a tab-delimited file containing data in the format of individual<tab>population.
  my $paint = $opts{r} || die "No input file specified.\n\n"; #used to specify input file name.  This is the input radpainter file.
  my $out = $opts{o} || "$paint.introgress"  ; #used to specify output file name.  If no name is provided, the file extension ".str" will be appended to the input file name.

  return( $first, $second, $admix, $loc, $map, $paint, $out );

}

#####################################################################################################
# subroutine to put file into an array

sub filetoarray{

  my( $infile, $array ) = @_;

  
  # open the input file
  open( FILE, $infile ) or die "Can't open $infile: $!\n\n";

  # loop through input file, pushing lines onto array
  while( my $line = <FILE> ){

    #chomp( $line );
	#$line =~ s/[\n]{1}//g;
    next if($line =~ /^\s*$/);
    push( @$array, $line );
  }

  close FILE;

}

#####################################################################################################
# subroutine to create hashes of individuals representing different groups

sub getGroup{

	my( $popnames, $hash ) = @_;

	my @list = split( /,/, $popnames );
	foreach my $pop( @list ){
		foreach my $ind( sort keys %mapData ){
			if( $mapData{$ind} eq $pop ){
				$$hash{$ind}++;
			}
		}
	}

}
#####################################################################################################
# subroutine to write output files for each group

sub writeGroupFile{

	my( $group, $outname, $yn  ) = @_;

	my @newheader;
	my @newpops;
	foreach my $ind( sort keys %paintData ){
		chomp( $ind );
		if( exists $$group{$ind} ){
			push( @newheader, $ind );
			push( @newpops, $mapData{$ind} );
		}
	}

	my $headerstring = join( ",", @newheader );
	my $popstring = join( ",", @newpops );

	open( OUT, '>', $outname ) or die "Can't open $outname: $!\n\n";

	print OUT $headerstring, "\n";
	print OUT $popstring, "\n";

	for( my $i=0; $i<$counter; $i++ ){
		if(exists($$yn{$i}) ){
			if($$yn{$i}==1){
				my @locus;
				foreach my $ind( sort keys %paintData ){
					if( exists $$group{$ind} ){
						push( @locus, $paintData{$ind}[$i] );
					}
				}
				my $locusstring = join( ",", @locus );
				print OUT $locusstring, "\n";
			#}else{
			#	print("not printing locus $i.\n");
			}
		}else{
			my @locus;
			foreach my $ind( sort keys %paintData ){
				if( exists $$group{$ind} ){
					push( @locus, $paintData{$ind}[$i] );
				}
			}
			my $locusstring = join( ",", @locus );
			print OUT $locusstring, "\n";
		}
	}

	close OUT;

}
#####################################################################################################
