#!/usr/bin/env perl

use strict;
use warnings;
use 5.012;

use List::Util qw/any sum/;
use List::MoreUtils qw/first_index/;

my %lines;
my %counts;
my %modeled;

# parse header
my $h = <STDIN>;
chomp $h;
my @fields = split /\t/, $h;
say $h;

my $idx_group   = 0;
my $idx_psms    = first_index {$_ eq 'psm_sum'}   @fields;
my $idx_modeled = first_index {$_ eq 'n_modeled'} @fields;
die "Error parsing headers\n"
    if (any {$_ < 0} ($idx_group, $idx_psms, $idx_modeled));

while (my $line = <STDIN>) {
    chomp $line;
    my @parts = split "\t", $line;
    my $grp   = $parts[ $idx_group ];
    $counts{  $grp } = $parts[ $idx_psms ];
    $modeled{ $grp } = $parts[ $idx_modeled ];
    next if ($modeled{ $grp } < 1);
    $lines{   $grp } = $line;
}


GROUP:
for my $grp (sort keys %lines) {

    my @accs = split /\|/, $grp;

    # ignore non-Arabidopsis proteins
    next GROUP if (any {$_ !~ /^AT/} @accs);

    if (@accs > 1) {
       
        # skip if any proteins in group exist individually
        next GROUP if (any {defined $lines{$_}} @accs);

        my $best_match;

        # skip if any proteins in group exist in any "better" groups (in this
        # case, groups with more total PSM counts
        ACC:
        for my $acc (@accs) {
            TGT:
            for my $tgt (keys %lines) {
                next TGT if ($tgt !~ /$acc/);
                next GROUP if ($counts{$tgt} > $counts{$grp});
            }
        }

    }

    say $lines{$grp};
}

