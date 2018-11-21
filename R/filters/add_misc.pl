#!/usr/bin/env perl

use strict;
use warnings;
use 5.012;

use List::Util qw/sum/;

my $fn_data = $ARGV[0];

# parse calculated stats
open my $in, '<', $fn_data;
my $h = <$in>;
chomp $h;
my ($id, @fields) = split "\t", $h;
my $n_fields = scalar @fields;

my %data;

while (my $line = <$in>) {
    chomp $line;
    my ($id, @other) = split "\t", $line;
    $data{$id} = \@other;
}

close $in;

$h = <STDIN>;
chomp $h;
say join "\t",
    split("\t", $h),
    @fields,
;

while (my $line = <STDIN>) {

    chomp $line;
    my @parts = split "\t", $line;
    my @all;

    ACC:
    for my $acc (split /\|/, $parts[0]) {

        if (! defined $data{$acc}) {
            warn "failed to find match for $acc\n";
            next ACC;
        }
        push @all, $data{$acc};

    }

    my @means;

    if (scalar @all < 1) {
        push @means, ('NA') x $n_fields;
    }
    else {
        for my $i (0..$n_fields-1) {
            push @means, mean( map {$_->[$i]} @all );
        }
    }

    say join "\t",
        @parts,
        @means,
    ;

}

sub mean { return sum(@_)/scalar(@_) }

