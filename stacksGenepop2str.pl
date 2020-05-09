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
getopts( 'g:ho:', \%opts );

# if -h flag is used, or if no command line arguments were specified, kill program and print help
if( $opts{h} ){
  &help;
  die "Exiting program because help flag was used.\n\n";
}

# parse the command line
my( $gen, $out ) = &parsecom( \%opts );

my @genlines; #holds genotype file lines
my @lines; #holds individual data lines
my @loci; #holds list of loci

#read input file
&filetoarray($gen, \@genlines);

foreach my $item( @genlines ){
	if( $item =~ /^Stacks/ ){
		next;
	}elsif( $item =~ /^\d+,\d+,\d+/ ){
 		@loci = split( /,/, $item );
	}elsif( $item =~ /^pop/ ){
		next;
	}else{
		push( @lines, $item );
	}
}

# process and print data
open( OUT, '>', $out ) or die "Can't open $out: $!\n\n";

foreach my $line( @lines ){
	my @loci = split( /\s+/, $line );
	my $ind = shift( @loci );
	$ind =~ s/,//g;
	my @allele1;
	my @allele2;
	foreach my $locus( @loci ){
		my $a1 = substr( $locus, 0,2 );
		if( $a1 eq "00" ){
			push( @allele1, "-9")
		}else{
			push( @allele1, $a1-0 );
		}
		my $a2 = substr( $locus, 2,2 );
		if( $a2 eq "00" ){
			push( @allele2, "-9")
		}else{
			push( @allele2, $a2-0 );
		}
	}
	print OUT $ind, "\t\t\t\t\t";
	foreach my $allele( @allele1 ){
		print OUT "\t", $allele;
	}
	print OUT "\n";
	print OUT $ind, "\t\t\t\t\t";
	foreach my $allele( @allele2 ){
		print OUT "\t", $allele;
	}
	print OUT "\n";
}

close OUT;

open( OUT, '>', "$out.loci.numbers.txt" ) or die "Can't open $out.loci.numbers.txt: $!\n\n";

for( my $i=1; $i<@loci; $i++ ){
	print OUT $i, "\t", $loci[$i], "\n";
}

close OUT;

#print Dumper(\@loci);

exit;
#####################################################################################################
############################################ Subroutines ############################################
#####################################################################################################

# subroutine to print help
sub help{
  
  print "\ngenepop2str.pl is a perl script developed by Steven Michael Mussmann\n\n";
  print "To report bugs send an email to smussmann\@gmail.com\n";
  print "When submitting bugs please include all input files, options used for the program, and all error messages that were printed to the screen\n\n";
  print "Program Options:\n";
  print "\t\t[ -h | -o | -g ]\n\n";
  print "\t-h:\tUse this flag to display this help message.\n";
  print "\t\tThe program will die after the help message is displayed.\n\n";
  print "\t-o:\tUse this flag to specify the output file name.\n";
  print "\t\tIf no name is provided, the file extension \".newhybrids\" will be appended to the input file name.\n\n";
  print "\t-g:\tUse this to specify the name of a genepop file.\n\n";
  
}

#####################################################################################################
# subroutine to parse the command line options

sub parsecom{ 
  
  my( $params ) =  @_;
  my %opts = %$params;
  
  # set default values for command line arguments
  my $gen = $opts{g} || die "No input file specified.\n\n"; #used to specify input file name.
  my $out = $opts{o} || "$gen.str"  ; #used to specify output file name.

  return( $gen, $out );

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
