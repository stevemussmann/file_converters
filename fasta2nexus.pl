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


open( A, $fas ) or die "Can't open $fas: $!\n\n";

my( $i, $id, @ids, %seq, @seqNames );
my $max_name_length = 0;
my $name_alignment_gap = 8;

# read in file
while (<A>){
  chomp;
  if( /^>(.*)/ ){
    # my @tmp = split / /, $1;
    # $id = shift @tmp;
    $id = $1;
    push @ids, $id;
    length $id > $max_name_length and $max_name_length = length $id;
  }else{
    $seq{$id} .= $_;
  }
}

close A;

#format names, so they have the proper number of spaces after each one
for( $i = 0; $i < @ids; $i++ ){
  my $numSpaces = $max_name_length - (length $ids[$i]) + $name_alignment_gap;
  my $spaces = ' ' x $numSpaces;
  $seqNames[$i] = $ids[$i];
  $seqNames[$i] .= $spaces;
}

my( $seq, $len, $matrix );

for( $i = 0; $i < @ids; $i++ ){
  $seq = $seq{$ids[$i]};
  $len = length $seq;
  $matrix .= $seqNames[$i];
  $matrix .= "$seq\n";
}


my $ntax = scalar @ids;


open( OUT, '>', $out ) or die "Can't open $out: $!\n\n";

print OUT
"#NEXUS

BEGIN DATA;
  DIMENSIONS NTAX=$ntax NCHAR=$len;
  FORMAT DATATYPE=DNA MISSING=\? GAP=- ;

MATRIX

";
print OUT $matrix, "\n";
print OUT ";\n";
print OUT "END;\n";

close OUT;

exit;

#####################################################################################################
############################################ Subroutines ############################################
#####################################################################################################

# subroutine to print help
sub help{
  
  print "\nfasta2nexus.pl is a perl script developed by Steven Michael Mussmann\n\n";
  print "To report bugs send an email to mussmann\@email.uark.edu\n";
  print "When submitting bugs please include all input files, options used for the program, and all error messages that were printed to the screen\n\n";
  print "Program Options:\n";
  print "\t\t[ -f | -h | -o ]\n\n";
  print "\t-h:\tUse this flag to display this help message.\n";
  print "\t\tThe program will die after the help message is displayed.\n\n";
  print "\t-o:\tUse this flag to specify the output file name.\n";
  print "\t\tIf no name is provided, the file extension \".nex\" will be appended to the input file name.\n\n";
  print "\t-f:\tSpecify the name of a fasta file.\n\n";
  
}

#####################################################################################################
# subroutine to parse the command line options

sub parsecom{ 
  
  my( $params ) =  @_;
  my %opts = %$params;
  
  # set default values for command line arguments
  my $fasta = $opts{f} || die "No input file specified.\n\n"; #used to specify input fasta file.
  my $out = $opts{o} || "$fasta.nex"  ; #used to specify output file name.  If no name is provided, the file extension ".fasta" will be appended to the input file name.


  return( $fasta, $out );

}

#####################################################################################################
