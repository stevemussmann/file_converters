#!/usr/bin/perl

# this appends the non gap character length of each sequence to the sequence name

use warnings;
use strict;
use Getopt::Std;

if( scalar( @ARGV ) == 0 ){
	&help;
	die "Exiting program because no command line options were used.\n\n";
}

# take command line arguments
my %opts;
getopts( 'f:ho:', \%opts );

# if -h flag is used kill program and print help
if( $opts{h} ){
	&help;
	die "Exiting program because help flag was used.\n\n";
}

# parse the command line
my( $fas, $out ) = &parsecom( \%opts );

my @data; #array to hold data
my @seqs;
my @names;

&filetoarray( $fas, \@data );

my $counter=0;
my $seqstr;
my $last;
foreach my $line( @data ){
	if( $line =~ /^>/ ){
		push( @names, $line );
		if( $counter != 0 ){
			push( @seqs, $seqstr );
			$seqstr="";
		}
		$counter++;
	}else{
		$seqstr .= $line;
		$last = $seqstr;
	}
}
push( @seqs, $last );

for( my $i=0; $i<@seqs; $i++ ){
	$seqs[$i] = uc(reverse($seqs[$i]));
	$seqs[$i] =~ tr/ACTG/TGAC/;
}

open( OUT, '>', $out ) or die "Can't open $out: $!\n\n";
for( my $i=0; $i<@names; $i++ ){
	print OUT $names[$i], "\n";
	print OUT $seqs[$i], "\n";
}
close OUT;

exit;

#####################################################################################################
############################################ Subroutines ############################################
#####################################################################################################

# subroutine to print help
sub help{
  
  print "\nrevcomFasta.pl is a perl script developed by Steven Michael Mussmann\n\n";
  print "To report bugs send an email to mussmann\@email.uark.edu\n";
  print "When submitting bugs please include all input files, options used for the program, and all error messages that were printed to the screen\n\n";
  print "Program Options:\n";
  print "\t\t[ -f | -h | -o ]\n\n";
  print "\t-h:\tUse this flag to display this help message.\n";
  print "\t\tThe program will die after the help message is displayed.\n\n";
  print "\t-o:\tUse this flag to specify the output file name.\n";
  print "\t\tIf no name is provided, the file extension \".fasta\" will be appended to the input file name.\n\n";
  print "\t-f:\tSpecify the name of a fasta file.\n\n";
  
}

#####################################################################################################
# subroutine to parse the command line options

sub parsecom{ 
  
  my( $params ) =  @_;
  my %opts = %$params;
  
  # set default values for command line arguments
  my $fasta = $opts{f} || die "No input file specified.\n\n"; #used to specify input fasta file.
  my $out = $opts{o} || "$fasta.fasta"  ; #used to specify output file name.  If no name is provided, the file extension ".fasta" will be appended to the input file name.


  return( $fasta, $out );

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
