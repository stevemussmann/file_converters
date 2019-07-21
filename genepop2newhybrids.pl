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
getopts( 'g:ho:z:Z:', \%opts );

# if -h flag is used, or if no command line arguments were specified, kill program and print help
if( $opts{h} ){
  &help;
  die "Exiting program because help flag was used.\n\n";
}

# parse the command line
my( $gen, $out, $z, $Z ) = &parsecom( \%opts );

my @genlines; #holds genotype file lines
my %z0;
my %z1;
my @lines; #holds individual data lines
my @loci; #holds list of loci

#get parental population lists
my @zlist = split( /,/, $z );
foreach my $item( @zlist ){
	$z0{$item}++;
}
my @Zlist = split( /,/, $Z );
foreach my $item( @Zlist ){
	$z1{$item}++;
}

#read input file
&filetoarray($gen, \@genlines);

foreach my $item( @genlines ){
	if( $item =~ /^Title/ ){
		next;
	}elsif( $item =~ /^Locus/ ){
		push( @loci, $item );
	}elsif( $item =~ /^Pop/ ){
		next;
	}else{
		push( @lines, $item );
	}
}


open( OUT, '>', $out ) or die "Can't open $out: $!\n\n";

print OUT "NumIndivs\t", scalar(@lines), "\n";
print OUT "NumLoci\t", scalar(@loci), "\n";
print OUT "Digits\t2\n";
print OUT "Format\tLumped\n\n";

my $string = join( "\t", @loci );

print OUT "LocusNames\t$string\n";

my $indcounter = 0;
foreach my $line( @lines ){
	$indcounter++;
	my @temp = split( /\s+/, $line );
	print OUT $indcounter, "\t";
	my $name = shift( @temp );
	my $pop = $name;
	$pop =~ s/\d+//g;
	if( exists $z0{$pop} ){
		print OUT "z0";
	}elsif( exists $z1{$pop} ){
		print OUT "z1";
	}
	shift( @temp );
	foreach my $locus( @temp ){
		print OUT "\t";
		if( $locus eq "0000" ){
			print OUT "0"
		}else{
			print OUT $locus;
		}
	}
	print OUT "\n";
	
}

close OUT;

#print Dumper(\%locusmap);

exit;
#####################################################################################################
############################################ Subroutines ############################################
#####################################################################################################

# subroutine to print help
sub help{
  
  print "\ngenepop2newhybrids.pl is a perl script developed by Steven Michael Mussmann\n\n";
  print "To report bugs send an email to mussmann\@email.uark.edu\n";
  print "When submitting bugs please include all input files, options used for the program, and all error messages that were printed to the screen\n\n";
  print "Program Options:\n";
  print "\t\t[ -h | -o | -g | -z | -Z ]\n\n";
  print "\t-h:\tUse this flag to display this help message.\n";
  print "\t\tThe program will die after the help message is displayed.\n\n";
  print "\t-o:\tUse this flag to specify the output file name.\n";
  print "\t\tIf no name is provided, the file extension \".newhybrids\" will be appended to the input file name.\n\n";
  print "\t-g:\tUse this to specify the name of a genepop file.\n\n";
  print "\t-z:\tUse this to specify the population name that corresponds to the first parental populations (z0). Multiple names should be comma-delimited.\n\n";
  print "\t-Z:\tUse this to specify the population name that corresponds to the second parental populations (z1). Multiple names should be comma-delimited.\n\n";
  
}

#####################################################################################################
# subroutine to parse the command line options

sub parsecom{ 
  
  my( $params ) =  @_;
  my %opts = %$params;
  
  # set default values for command line arguments
  my $gen = $opts{g} || die "No input file specified.\n\n"; #used to specify input file name.
  my $out = $opts{o} || "$gen.newhybrids"  ; #used to specify output file name.
  my $z0 = $opts{z} || ""; #used to specify z0
  my $z1 = $opts{Z} || ""; #used to specify z1

  return( $gen, $out, $z0, $z1 );

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
