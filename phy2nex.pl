#! /usr/bin/perl

use warnings;
use strict;

# $0 holds the absolute path of this script
my $usage = "\nUsage: $0 phylip_file output_file\n\n";

# kill program and print usage if not at least one command line argument
$ARGV[1] or die $usage;

# @ARGV holds the command line arguments
my( $phy, $out ) = @ARGV;

# declare variables
my @lines; # array to hold lines from input unlinked_snps file
my @names; # array to hold sequence names
my @seqs; # array to hold sequences
my $outfile = "$phy.nex";

open( PHY, $phy ) or die "Can't open $phy: $!\n\n";

while( my $line = <PHY> ){
	chomp( $line );
	push( @lines, $line );
}

close PHY;

# print out lines for testing
foreach my $item( @lines ){
	#print $item, "\n";
	my @temp = split( /\s+/, $item );
	push( @names, $temp[0] );
	push( @seqs, $temp[1] );
}

# get rid of phylip header
shift(@names);
shift(@seqs);

my $seq_length = length($seqs[0]);
foreach my $item( @seqs ){
	my $current_length = length($item);
	if($current_length != $seq_length){
		die "Check the alignment.\n\n";
	}
	$seq_length = $current_length;
}

my $align_length = scalar(@names);
if($align_length != scalar(@seqs)){
	die "You have different numbers of sequence names and individuals.\n\n";
}

open( OUT, '>', $outfile ) or die "Can't open $outfile: $!\n\n";

print OUT "#NEXUS\n";
print OUT "Begin data;\n";
print OUT "\tDimensions ntax=$align_length nchar=$seq_length;\n";
print OUT "\tFormat datatype=dna missing=? gap=-;\n";
print OUT "\tMatrix\n";

for( my $i=0; $i<$align_length; $i++){
	print OUT $names[$i], "\t";
	print OUT $seqs[$i], "\n";
}

print OUT "\t;\n";
print OUT "End;\n";

close OUT;

exit;