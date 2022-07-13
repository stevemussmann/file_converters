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
my %hash;
my %list1;
my %list2;
my %locuslist;
my $parse = 0; #boolean to indicate when to start parsing file
my $bon = int(($alpha/(($msat*($msat-1))/2))*1000000);
print $bon/1000000, "\n";

&filetoarray($genepop, \@infile);

foreach my $line( @infile ){
	if( $line =~ /^P\-value/ ){
		$parse = 0;
	}
	if( $parse == 1 ){
		my @temp = split( /\s+/, $line );
		$list1{$temp[1]}++;
		$list2{$temp[1]}++;
		if(!(exists $hash{$temp[1]}{$temp[2]})){
			push( @{$hash{$temp[1]}{$temp[2]}}, "" );
		}
		if(!(exists $hash{$temp[2]}{$temp[1]})){
			push( @{$hash{$temp[2]}{$temp[1]}}, "" );
		}
		if( $temp[3] !~ /No/ ){
			#print $temp[3], "\n";
			my $integer = $temp[3] * 1000000;
			if( $integer < $bon ){
				push( @{$hash{$temp[1]}{$temp[2]}}, $temp[0]);
				push( @{$hash{$temp[2]}{$temp[1]}}, $temp[0]);
			}

		}
	}
	if( $line =~ /^\-\-\-\-\-\-\-\-\-\-\s/ ){
		$parse = 1;
	}
	
}

#make sure all possible combinations are filled out for the matrix
foreach my $site1(sort keys %list1){
	foreach my $site2(sort keys %list2){
		if(!(exists $hash{$site1}{$site2})){
			push( @{$hash{$site1}{$site2}}, "" );
		}
	}
}

open( OUT, '>', $out) or die "Can't open $out: $!\n\n";

print OUT "\t";
foreach my $key( sort keys %hash ){
	print OUT $key, "\t";
}
print OUT "\n";

foreach my $first( sort keys %hash ){
	print OUT $first, "\t";
	foreach my $second( sort keys %{$hash{$first}} ){
		if( scalar(@{$hash{$first}{$second}}) > 1){
			shift(@{$hash{$first}{$second}});
		}
		my $string = "";
		if($first eq $second){
			$string = "x";
		}else{
			$string = join(",", @{$hash{$first}{$second}});
		}
		print OUT $string, "\t";

	}
	print OUT "\n";
}
print OUT "\n";

#print Dumper(\%hash);

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
