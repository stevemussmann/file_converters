#!/usr/bin/perl

use warnings;
use strict;
use Data::Dumper;

my $file = "map.txt";
my %hash;
my %pophash;
my %maphash;

open( FILE, $file ) or die "Can't open $file: $!\n\n";

while( my $line = <FILE> ){
	chomp $line;
	$line =~ s/;//g;
	my @temp = split( /\t/, $line );
	$hash{$temp[0]}=$temp[1];
	$pophash{$temp[1]}++;
}

close FILE;

my $count = keys(%hash);

foreach my $sample( sort keys %hash ){
	foreach my $site( sort keys %pophash ){
		if( $hash{$sample} eq $site ){
			push( @{$maphash{$sample}}, "1");
		}else{
			push( @{$maphash{$sample}}, "0");
		}
	}
}


print "BEGIN TRAITS;\n";
print "\tDimensions NTRAITS=", $count, ";\n";
print "\tFormat labels=yes missing=? separator=Comma;\n";
print "\tTraitLabels";
foreach my $site( sort keys %pophash ){
	print " ", $site;
}
print ";\n";
print "Matrix\n";

foreach my $sample( sort keys %maphash ){
	print $sample, " ";
	my $string = join( ',', @{$maphash{$sample}} );
	print $string, "\n";
}
print ";\n";
print "END;\n";

#print Dumper(\%hash);
#print Dumper(\%maphash);

exit;
