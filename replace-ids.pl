#!/usr/bin/perl

my %hash;

#gi.accs file
open FILE, $ARGV[0] or die $!;
my $line;
while (my $line = <FILE>) {
     chomp($line);
     my @accs = split(' ',$line);
     $accs[1] = 12908 if $accs[1] < 0;
     $hash{$accs[0]} = $accs[1];
 }
 close FILE;

#file to do replacements on
open FILE, $ARGV[1] or die $!;
while (my $line = <FILE>) {
    if ($line =~ m/^>/) {
    	$line =~ s/^>(\w+)\./>gi|$hash{$1}|$1/;
    	print $line;
	} else { $line =~ s/U/T/g; print $line }
}
 close FILE;
 
 
