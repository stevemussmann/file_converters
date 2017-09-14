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
getopts( 'hm:o:s:', \%opts );

# if -h flag is used, or if no command line arguments were specified, kill program and print help
if( $opts{h} ){
  &help;
  die "Exiting program because help flag was used.\n\n";
}

# parse the command line
my( $str, $out, $map, $pops, $select ) = &parsecom( \%opts );

# declare variables
my @strlines; # array to hold lines from structure file
my @maplines; # array to hold lines from map file
my %popmap; # hash to hold population map
my %data; # holds data from structure file
my $length; # holds number of loci
my %allelecounts; # holds allele counts per locus per population
my %popallelecounts; # holds counts per allele per locus per population
my %poploci; # holds global counts for each allele at each locus
my %popnums; # maps population names to numbers

# put files into array
&filetoarray( $str, \@strlines );
&filetoarray( $map, \@maplines );

# push structure data into hash
for(my $i = 0; $i < @strlines; $i++){
	my @ima;
	my @temp = split(/\s+/, $strlines[$i]);
	my $name = shift(@temp);
	foreach my $allele(@temp){
		if($i%2==0){
			push( @{$data{$name}{"a1"}}, $allele );
		}else{
			push( @{$data{$name}{"a2"}}, $allele );
		}
	}
	$length = scalar(@{$data{$name}{"a1"}});
}

# read in popmap
foreach my $item( @maplines ){
	my @temp = split( /\s+/, $item );
	$popmap{$temp[0]} = $temp[1];
}


for( my $i=0; $i<$length; $i++ ){
	foreach my $samp(sort keys %data){
		$allelecounts{$popmap{$samp}}{$i} = 0;
	}
}

for( my $i=0; $i<$length; $i++ ){
	foreach my $samp(sort keys %data){
		my $a1 = ${$data{$samp}{"a1"}}[$i];
		my $a2 = ${$data{$samp}{"a2"}}[$i];
		if($a1 != "-9"){
			$allelecounts{$popmap{$samp}}{$i}+=1;
			$popallelecounts{$popmap{$samp}}{$i}{$a1}+=1;
			$poploci{$i}{$a1}+=1;
		}
		if($a2 != "-9"){
			$allelecounts{$popmap{$samp}}{$i}+=1;
			$popallelecounts{$popmap{$samp}}{$i}{$a2}+=1;
			$poploci{$i}{$a2}+=1;
		}
	}
}

foreach my $locus(sort keys %poploci){
	foreach my $allele(sort keys %{$poploci{$locus}}){
		foreach my $pop(sort keys %popallelecounts){
			$popallelecounts{$pop}{$locus}{$allele}+=0;
		}
	}
}

#print output file
open(OUT, '>', $out) or die "Can't open $out: $!\n\n";
print OUT "[loci]=$length\n\n";
print OUT "[populations]=", scalar keys(%popallelecounts), "\n\n";
my $counter=0;
foreach my $pop(sort keys %popallelecounts){
	$counter++;
	print OUT "[pop]=$counter\n";
	$popnums{$counter} = $pop;
	foreach my $i( sort {$a <=> $b} keys %{$popallelecounts{$pop}} ){
		print OUT $i+1, "\t", $allelecounts{$pop}{$i}, "\t", scalar keys(%{$poploci{$i}});
		foreach my $allele( sort {$a <=> $b} keys %{$popallelecounts{$pop}{$i}}){
			print OUT "\t", $popallelecounts{$pop}{$i}{$allele};
		}
		print OUT "\n";
	}
}
close OUT;

open(OUT, '>', "$out.popnums") or die "Can't open $out: $!\n\n";
foreach my $pop(sort {$a <=> $b} keys %popnums){
	print OUT "$pop\t$popnums{$pop}\n";
}
close OUT;


#print Dumper(\%data);
#print Dumper(\%popmap);
#print Dumper(\%allelecounts);
#print Dumper(\%popallelecounts);
#print Dumper(\%poploci);

exit;

#####################################################################################################
############################################ Subroutines ############################################
#####################################################################################################

# subroutine to print help
sub help{
  
  print "\nstr2bayescan.pl is a perl script developed by Steven Michael Mussmann\n\n";
  print "To report bugs send an email to mussmann\@email.uark.edu\n";
  print "When submitting bugs please include all input files, options used for the program, and all error messages that were printed to the screen\n\n";
  print "Program Options:\n";
  print "\t\t[ -h | -m | -o | -s ]\n\n";
  print "\t-h:\tDisplay this help message.\n";
  print "\t\tThe program will die after the help message is displayed.\n\n";
  print "\t-m:\tSpecify your population map text file (required).\n";
  print "\t\tThis is a tab delimited file specifying the sample name in the first column and population name in the second.\n\n";
  print "\t-o:\tSpecify the output file name (optional).\n";
  print "\t\tIf no name is provided, the file extension \".bayescan.txt\" will be appended to the input file name.\n\n";
  print "\t-s:\tUse this flag to specify the name of the structure file produced by pyRAD (required).\n\n";
  
}

#####################################################################################################
# subroutine to parse the command line options

sub parsecom{ 
  
	my( $params ) =  @_;
	my %opts = %$params;
  
	# set default values for command line arguments
	my $str = $opts{s} || die "No input file specified.\n\n"; #used to specify input file name.  This is the input structure file produced by pyRAD
	my $out = $opts{o} || "$str.bayescan.txt"  ; #used to specify output file name.  If no name is provided, the file extension ".bayescan.txt" will be appended to the input file name.

	my $map = $opts{m} || die "No input population map file specified.\n\n"; #used to specify tab-delimited population map file  

	return( $str, $out, $map, $pops, $select );

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
