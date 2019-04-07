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
getopts( 'c:hl:m:o:s:', \%opts );

# if -h flag is used, or if no command line arguments were specified, kill program and print help
if( $opts{h} ){
  &help;
  die "Exiting program because help flag was used.\n\n";
}

# parse the command line
my( $str, $out, $hlines, $columns, $missing ) = &parsecom( \%opts );

# declare variables
my @strlines; # array to hold lines from structure file

# put files into array
&filetoarray( $str, \@strlines );

# remove header
for( my $i=0; $i<$hlines; $i++ ){
	shift( @strlines );
}

open( OUT, '>', $out ) or die "Can't open $out: $!\n\n";

foreach my $line( @strlines ){
	my @line1; 
	my @line2;
	my @temp = split( /\s+/, $line );
	push( @line1, $temp[0] );
	push( @line2, $temp[0] );
	for( my $i=0; $i<5; $i++ ){
		push( @line1, "" );
		push( @line2, "" );
	}
	for( my $i=0; $i<1+$columns; $i++ ){
		shift( @temp );
	}
	for( my $i=0; $i<@temp; $i+=2 ){
		if( $temp[$i] == $missing ){
			push( @line1, "-9" );
		}else{
			push( @line1, $temp[$i] );
		}
	}
	for( my $i=1; $i<@temp; $i+=2 ){
		if( $temp[$i] == $missing ){
			push( @line2, "-9" );
		}else{
			push( @line2, $temp[$i] );
		}
	}
	my $newline1 = join( "\t", @line1 );
	my $newline2 = join( "\t", @line2 );
	print OUT $newline1, "\n";
	print OUT $newline2, "\n";
}

close OUT;


exit;

#####################################################################################################
############################################ Subroutines ############################################
#####################################################################################################

# subroutine to print help
sub help{
  
  print "\nonelinestr2str.pl is a perl script developed by Steven Michael Mussmann\n\n";
  print "To report bugs send an email to mussmann\@email.uark.edu\n";
  print "When submitting bugs please include all input files, options used for the program, and all error messages that were printed to the screen\n\n";
  print "Program Options:\n";
  print "\t\t[ -c | -h | -l | -m | -o | -s ]\n\n";
  print "\t-c:\tUse this flag to specify the number of extra columns between sample name and the start of the data.\n";
  print "\t\tDefault = 1. Do not count columns of whitespace.\n\n";
  print "\t-h:\tUse this flag to display this help message.\n";
  print "\t\tThe program will die after the help message is displayed.\n\n";
  print "\t-l:\tUse this flag to input the number of header lines for the input file.\n";
  print "\t\tDefault = 2.\n\n";
  print "\t-m:\tUse this flag to specify the missing data value.\n";
  print "\t\tDefault = 0. Missing data values will be converted to -9.\n\n";
  print "\t-o:\tUse this flag to specify the output file name.\n";
  print "\t\tIf no name is provided, the file extension \".str\" will be appended to the input file name.\n\n";
  print "\t-s:\tUse this flag to specify the name of the input structure file.\n\n";
  
}

#####################################################################################################
# subroutine to parse the command line options

sub parsecom{ 
  
  my( $params ) =  @_;
  my %opts = %$params;
  
  # set default values for command line arguments
  my $str = $opts{s} || die "No input file specified.\n\n"; #used to specify input file name.  This is the input snps file produced by pyRAD
  my $out = $opts{o} || "$str.str"  ; #used to specify output file name.  If no name is provided, the file extension ".out" will be appended to the input file name.

  my $hlines = $opts{l} || "2"  ; #used to specify number of header lines in input file
  my $columns = $opts{c} || "1"  ; #used to specify number of columns preceeding start of data
  my $missing = $opts{m} || "0"  ; #used to specify missing data value

  return( $str, $out, $hlines, $columns, $missing );

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
