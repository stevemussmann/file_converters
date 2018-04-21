#! /usr/bin/perl

use strict;
use warnings;

# Input and output files
my $usage = "\nUsage: $0 tree-file \n\n";

$ARGV[0] or die $usage;

my( $tree ) = @ARGV;
my $outfile = "$tree.figtree";

# Open the tree output by RAxML and convert it to a format readable by FigTree
open ( OUT, '>', $outfile ) || die "Can't open $outfile: $!\n";
open ( RAXML, $tree ) || die "Can't open $tree: $!\n";
while (my $line = <RAXML> ) {
	if( $line =~ /^\(/ ){
	$line =~ s/([:]\d+[.]\d+)[[](\d+)[]]/$2$1/g;
	print OUT $line, "\n";
	}
}
close RAXML;
close OUT;

print "\nOutput written to $tree.figtree \n\n";

exit;