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
getopts( 'a:d:hm:o:', \%opts );

# if -h flag is used, or if no command line arguments were specified, kill program and print help
if( $opts{h} ){
  &help;
  die "Exiting program because help flag was used.\n\n";
}

# parse the command line
my( $genepop, $out, $alpha, $msat ) = &parsecom( \%opts );

# declare variables
my @infile;
my %hoh;
my %populations;
my $locus = "";
my $parse = 0;
my $bon = int($alpha/$msat*10000);

&filetoarray($genepop, \@infile);


for my $line( @infile ){
	if( $line =~ /^Locus/ ){
		my @temp = split( /\s+/, $line );
		$temp[1] =~ s/\"//g;
		if( $locus ne $temp[1] ){
			$parse = 0;
			$locus = $temp[1];
		}
	}

	my @temp = split( /\s+/, $line );
	if( $parse == 1 ){
		if( $temp[0] =~ /^\=/ ){
			last;
		}
		if( $line !~ /^\-/ ){
			$hoh{$locus}{$temp[0]} = $temp[1];
			$populations{$temp[0]}++;
		}
	}
	
	if($temp[0] eq "POP"){
		$parse = 1;
	}


	#print $locus, "\n";
}


open( OUT, '>', $out) or die "Can't open $out: $!\n\n";

foreach my $pop(sort keys %populations){
	print OUT "\t", $pop;
}
print OUT "\n";

foreach my $loc( sort keys %hoh ){
	print OUT $loc;
	foreach my $pop( sort keys %{$hoh{$loc}} ){
		#print "\t", $hoh{$loc}{$pop};
		if( $hoh{$loc}{$pop} ne "-"  ){
			if( $hoh{$loc}{$pop}*10000 < $bon  ){
				print OUT "\t", "+";
			}else{
				print OUT "\t";
			}
		}else{
			print OUT "\t";
		}
	}
	print OUT "\n";
}

close OUT;

#print Dumper(\%hoh);
#print Dumper(\%populations);

exit;

#####################################################################################################
############################################ Subroutines ############################################
#####################################################################################################

# subroutine to print help
sub help{
  
  print "\nsgenepopDisParse.pl is a perl script developed by Steven Michael Mussmann\n\n";
  print "To report bugs send an email to mussmann\@email.uark.edu\n";
  print "When submitting bugs please include all input files, options used for the program, and all error messages that were printed to the screen\n\n";
  print "Program Options:\n";
  print "\t\t[ -a | -d | -h | -m | -o ]\n\n";
  print "\t-a:\t[optional] Enter your alpha value.  Default = 0.05.\n\n";
  print "\t-d:\tUse this flag to specify the genepop output file.\n\n";
  print "\t-h:\tUse this flag to display this help message.\n";
  print "\t\tThe program will die after the help message is displayed.\n\n";
  print "\t-m:\tUse the number of microsatellites.\n\n";
  print "\t-o:\tUse this flag to specify the output file name.\n";
  print "\t\tIf no name is provided, the file extension \".txt\" will be appended to the input file name.\n\n";
  
}

#####################################################################################################
# subroutine to parse the command line options

sub parsecom{ 
  
  my( $params ) =  @_;
  my %opts = %$params;
  
  # set default values for command line arguments
  my $alpha = $opts{a} || "0.05";
  my $genal = $opts{d} || die "No input file specified.\n\n"; #used to specify input file name.  This is the linkage disequilibrium output from genepop
  my $msat = $opts{m} || die "Did not specify number of microsatellites.\n\n"; #used to specify number of microsatellites used in analysis
  my $out = $opts{o} || "$genal.tab"; #used to specify output file name.  If no name is provided, the file extension ".txt" will be appended to the input file name.

  return( $genal, $out, $alpha, $msat );

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

  # close input file
  close FILE;

}

#####################################################################################################
