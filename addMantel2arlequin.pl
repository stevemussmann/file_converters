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
getopts( 'ha:d:', \%opts );

# if -h flag is used, or if no command line arguments were specified, kill program and #print help
if( $opts{h} ){
  &help;
  die "Exiting program because help flag was used.\n\n";
}

# parse the command line
my( $arl, $dist ) = &parsecom( \%opts );

my @distances;
my %hoh;
my %list;
my @sorted;

&filetoarray($dist, \@distances);

foreach my $line( @distances ){
	my @temp = split(/\s+/, $line);
	#print $temp[2], "\n";
	$list{$temp[0]}+=1;
	$list{$temp[1]}+=1;
	$hoh{$temp[0]}{$temp[1]} = $temp[2];
	$hoh{$temp[1]}{$temp[0]} = $temp[2];
}

foreach my $item( sort keys %list ){
	push( @sorted, $item );
}

open( ARP, '>>', $arl ) or die "Can't open $arl: $!\n\n";

print ARP "[[Mantel]]", "\n";
print ARP "     MatrixSize=", scalar(@sorted), "\n";
print ARP "     MatrixNumber=2", "\n";
print ARP "     YMatrix=\"fst\"", "\n";
print ARP "     YMatrixLabels={", "\n";
foreach my $label( @sorted ){
	print ARP "                 \"$label\"", "\n";
}
print ARP "     }", "\n";
print ARP "     DistMatMantel={", "\n        ";

for( my $i=0; $i<@sorted; $i++ ){
	for( my $j=0; $j<$i+1; $j++ ){
		if($sorted[$i] eq $sorted[$j] ){
			print ARP " ", "0.0";
		}else{
			print ARP " ", $hoh{$sorted[$i]}{$sorted[$j]};
		}
	}
	print ARP "\n        ";
}
print ARP "}", "\n";
print ARP "     UsedYMatrixLabels={", "\n";
foreach my $label( @sorted ){
	print ARP "                 \"$label\"", "\n";
}
print ARP "     }", "\n";


close ARP;

#print Dumper(\@distances);
#print Dumper(\%hoh);
#print Dumper(\@sorted);


exit;

#####################################################################################################
############################################ Subroutines ############################################
#####################################################################################################

# subroutine to print help
sub help{
  
  print "\nstr2arlequin.pl is a perl script developed by Steven Michael Mussmann\n\n";
  print "To report bugs send an email to mussmann\@email.uark.edu\n";
  print "When submitting bugs please include all input files, options used for the program, and all error messages that were printed to the screen\n\n";
  print "Program Options:\n";
  print "\t\t[ -a | -d | -h ]\n\n";
  print "\t-a:\tSpecify the Arlequin project to which you want to append the geographic distance matrix.\n\n";
  print "\t-d:\tSpecify the tab-delimited distance matrix. Format=Pop1<tab>Pop2<tab>Distance.\n\n";
  print "\t-h:\tUse this flag to display this help message.\n\n";
}

#####################################################################################################
# subroutine to parse the command line options

sub parsecom{ 
  
  my( $params ) =  @_;
  my %opts = %$params;
  
  # set default values for command line arguments
  my $arl = $opts{a} || die "Arlequin file that will have matrix appended to it was not specified."  ; #used to specify arlequin project file name.
  my $dist = $opts{d} || die "No geographic distance data specified."; 

  return( $arl, $dist );

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
