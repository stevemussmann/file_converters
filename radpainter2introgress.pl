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
getopts( 'hm:o:p:', \%opts );

# if -h flag is used, or if no command line arguments were specified, kill program and print help
if( $opts{h} ){
  &help;
  die "Exiting program because help flag was used.\n\n";
}

# parse the command line
my( $paint, $map, $out ) = &parsecom( \%opts );

# declare variables
my @paintlines; # holds lines from radpainter file
my @maplines; # holds lines from population map file
my %mapData; # holds population map information
my %paintData; # holds genotype data from radpainter file

# read input files into arrays
&filetoarray( $paint, \@paintlines );
&filetoarray( $map, \@maplines );

# convert population map to hash
foreach my $line( @maplines ){
	chomp( $line );
	my @temp = split( /\s+/, $line );
	$mapData{$temp[0]} = $temp[1];
}

# catch header from input radpainter file
my @header = split( /\t/, shift( @paintlines ) );

my $counter=0;
foreach my $line( @paintlines ){
	$counter++;
	my @temp = split( /\t/, $line );
	#print scalar(@temp), "\n";
	for( my $i=0; $i<@temp; $i++ ){
		chomp($temp[$i]);
		if( $temp[$i] eq "" ){
			$temp[$i]="NA";
		}
		if( $temp[$i] !~ /\// ){
			$temp[$i] = join( "/", $temp[$i], $temp[$i] );
		}
		push( @{$paintData{$header[$i]}}, $temp[$i] );
	}
}

my @newheader;
my @newpops;
foreach my $ind( sort keys %paintData ){
	chomp( $ind );
	push( @newheader, $ind );
	push( @newpops, $mapData{$ind} );
}

my $headerstring = join( ",", @newheader );
my $popstring = join( ",", @newpops );

open( OUT, '>', $out ) or die "Can't open $out: $!\n\n";

print OUT $headerstring, "\n";
print OUT $popstring, "\n";

for( my $i=0; $i<$counter; $i++ ){
	my @locus;
	foreach my $ind( sort keys %paintData ){
		push( @locus, $paintData{$ind}[$i] );
	}
	my $locusstring = join( ",", @locus );
	print OUT $locusstring, "\n";
}

close OUT;

#foreach my $ind( sort keys %paintData ){
#	print scalar(@{$paintData{$ind}}), "\n";;
#}

#print Dumper( \%mapData );
#print Dumper( \%paintData );

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
  print "\t\t[ -h | -m | -o | -p ]\n\n";
  print "\t-h:\tUse this flag to display this help message.\n";
  print "\t\tThe program will die after the help message is displayed.\n\n";
  print "\t-m:\tUse this flag to specify the population map file (required).\n\n";
  print "\t-o:\tUse this flag to specify the output file name.\n";
  print "\t\tIf no name is provided, the file extension \".introgress\" will be appended to the input file name.\n\n";
  print "\t-p:\tUse this flag to specify the input radpainter file name (required).\n\n";
  
}

#####################################################################################################
# subroutine to parse the command line options

sub parsecom{ 
  
  my( $params ) =  @_;
  my %opts = %$params;
  
  # set default values for command line arguments
  my $map = $opts{m} || die "No population map file specified.\n\n"; #used to specify population map file.  This is a tab-delimited file containing data in the format of individual<tab>population.
  my $paint = $opts{p} || die "No input file specified.\n\n"; #used to specify input file name.  This is the input phylip file.
  my $out = $opts{o} || "$paint.introgress"  ; #used to specify output file name.  If no name is provided, the file extension ".str" will be appended to the input file name.

  return( $paint, $map, $out );

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
