#!/usr/bin/perl

use warnings;
use strict;
use Data::Dumper;

my $in = "spd_dv.unlinked_snps.select.vcf";
my $outmap = "spd_dv.unlinked_snps.select.map";
my $ped = "spd_dv.unlinked_snps.select.ped";

my @lines;
my %hash;
my %hoa;
my @order;

open( IN, $in ) or die "Can't open $in: $!\n\n";
while( my $line = <IN> ){
	chomp( $line );
	push( @lines, $line );
}
close IN;

open( MAP, '>', $outmap ) or die "Can't open $outmap: $!\n\n";

foreach my $line( @lines ){
	if( $line =~ /^#CHROM/ ){
		print $line, "\n";
		my @temp = split( /\s+/, $line );
		for( my $i=0; $i<@temp; $i++ ){
			if( $i > 8 ){
				$hash{$i} = $temp[$i];
				push( @order, $temp[$i] );
			}
		}
	}elsif( $line !~ /^##/ ){
		my @temp = split( /\s+/, $line );
		my $chrom;
		my $pos;
		for( my $i=0; $i<@temp; $i++ ){
			if( $i < 9 ){
				if( $i == 0 ){
					$chrom = $temp[$i];
				}
				if( $i == 1 ){
					$pos = $temp[$i];
				}
			}else{
				if( $temp[$i] =~ /\|/){
					my @loc = split( /\|/, $temp[$i] );
					foreach my $al( @loc ){
						push( @{$hoa{$hash{$i}}}, $al+1 );
					}
				}else{
					push( @{$hoa{$hash{$i}}}, 0 );
					push( @{$hoa{$hash{$i}}}, 0 );
				}
			}
		}
		print MAP "0\t", $chrom, ":", $pos, "\t0\t", $pos, "\n";
	}
}

close MAP;

open( PED, '>', $ped ) or die "Can't open $ped: $!\n\n";
foreach my $ind( @order ){
	print PED $ind, " ", $ind, " 0 0 0 -9 ";
	my $string = join( " ", @{$hoa{$ind}} );
	print PED $string;
	print PED "\n";
}
close PED;

#print Dumper( \%hoa );

exit;
