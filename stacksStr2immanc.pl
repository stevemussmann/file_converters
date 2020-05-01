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
getopts( 'ho:p:s:', \%opts );

# if -h flag is used, or if no command line arguments were specified, kill program and print help
if( $opts{h} ){
  &help;
  die "Exiting program because help flag was used.\n\n";
}

# parse the command line
my( $str, $out, $pops, $select ) = &parsecom( \%opts );

# declare variables
my @strlines; # array to hold lines from structure file
my %popmap; # hash to hold population map
my %data; # holds converted data from structure file
my %selecthash; #holds selected populations that will be output
my %droploci;

# put files into array
&filetoarray( $str, \@strlines );

#remove first two lines from input file
my $header = shift( @strlines );
my $loci = shift( @strlines );

# convert structure format to immanc format, and push data into hash
for(my $i = 0; $i < @strlines; $i++){
	my @ima;
	my @temp = split(/\s+/, $strlines[$i]);
	my $name = shift(@temp);
	my $pop = shift( @temp );
	$popmap{$name} = $pop;
	foreach my $allele(@temp){
		push( @ima, $allele );
	}
	my $alleles = join("\t", @ima);
	if($i%2==0){
		$data{$name}{"a1"} = $alleles;
	}else{
		$data{$name}{"a2"} = $alleles;
	}
}

if( $select == 1){
	my @temp = split(/,/, $pops);
	foreach my $thing(@temp){
		$selecthash{$thing} = 1;
	}
}

#get number of individuals
my $numinds = keys %selecthash;

#count how many individuals have missing data at a locus
if( $select == 1){
	foreach my $ind( sort keys %data ){	
		if(exists $selecthash{$popmap{$ind}} ){
			my @temp = split( /\t/, $data{$ind}{"a1"} );
			for(my $i=0; $i<@temp; $i++ ){
				if( $temp[$i] == 0 ){
					$droploci{"locus$i"}++;
				}
			}
		}
	}
}

open(OUT, '>', $out) or die "Can't open $out: $!\n\n";
# print output file
foreach my $ind( sort keys %data  ){
	if( $select == 1){
		if(exists $selecthash{$popmap{$ind}} ){
			my @a1 = split( /\t/, $data{$ind}{"a1"} );
			my @a2 = split( /\t/, $data{$ind}{"a2"} );
			for( my $i=0; $i<@a1; $i++ ){
				if(!(exists $droploci{"locus$i"})){
					print OUT "$ind $popmap{$ind} locus$i $a1[$i] $a2[$i]\n";
				}elsif($droploci{"locus$i"} != $numinds){
					print OUT "$ind $popmap{$ind} locus$i $a1[$i] $a2[$i]\n";
				}
			}
		}
	}else{
		my @a1 = split( /\t/, $data{$ind}{"a1"} );
		my @a2 = split( /\t/, $data{$ind}{"a2"} );
		for( my $i=0; $i<@a1; $i++ ){
			print OUT "$ind $popmap{$ind} locus$i $a1[$i] $a2[$i]\n";
		}
	}
}
close OUT;

#print Dumper(\%data);
#print Dumper(\%popmap);

exit;

#####################################################################################################
############################################ Subroutines ############################################
#####################################################################################################

# subroutine to print help
sub help{
  
  print "\nstr2immanc.pl is a perl script developed by Steven Michael Mussmann\n\n";
  print "To report bugs send an email to mussmann\@email.uark.edu\n";
  print "When submitting bugs please include all input files, options used for the program, and all error messages that were printed to the screen\n\n";
  print "Program Options:\n";
  print "\t\t[ -h | -o | -p | -s ]\n\n";
  print "\t-h:\tDisplay this help message.\n";
  print "\t\tThe program will die after the help message is displayed.\n\n";
  print "\t-o:\tUse this flag to specify the output file name.\n";
  print "\t\tIf no name is provided, the file extension \".immanc\" will be appended to the input file name.\n\n";
  print "\t-p:\tUse this flag to provide a comma-delimited list of populations to select for output.\n";
  print "\t\tFor example, enter \"NFV,NTH,WFA\" to select only these populations from the input file.\n\n";
  print "\t-s:\tUse this flag to specify the name of the structure file produced by pyRAD.\n\n";
  
}

#####################################################################################################
# subroutine to parse the command line options

sub parsecom{ 
  
	my( $params ) =  @_;
	my %opts = %$params;
  
	# set default values for command line arguments
	my $str = $opts{s} || die "No input file specified.\n\n"; #used to specify input file name.  This is the input snps file produced by pyRAD
	my $out = $opts{o} || "$str.immanc"  ; #used to specify output file name.  If no name is provided, the file extension ".genepop" will be appended to the input file name.

	my $pops;
	my $select=0;
	if($opts{p}){
		$pops = $opts{p};
		$select=1;
	}

	return( $str, $out, $pops, $select );

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
