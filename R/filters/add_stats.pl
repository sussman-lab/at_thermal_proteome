#!/usr/bin/env perl

use strict;
use warnings;
use 5.012;

use MS::Protein;
use BioX::Seq::Stream;
use List::Util qw/sum/;
use List::MoreUtils qw/indexes/;

my @aas = qw/A C D E F G H I K L M N P Q R S T V W Y/;

my $fn_stats = $ARGV[0];

my %seqs;
my $p = BioX::Seq::Stream->new('search/TAIR10_search.fasta');
while (my $seq = $p->next_seq) {
    $seq->id =~ s/(AT\w+)\.\d+/$1/;
    $seqs{ $seq->id} = $seq->seq;
}

# parse calculated stats
open my $in, '<', $fn_stats;
my $h = <$in>;

my %stats;

while (my $line = <$in>) {
    chomp $line;
    my ($id, @other) = split "\t", $line;
    $stats{$id} = \@other;
}

close $in;

$h = <STDIN>;
chomp $h;
my @headers = split "\t", $h;
my @pep_seqs = indexes {$_ =~ /pep_seqs$/} @headers;
for (@pep_seqs) {
    $headers[$_] =~ s/pep_seqs$/protein_coverage/;
}
say join "\t",
    @headers,
    'length',
    'mw',
    'ai',
    'gravy',
    'pi',
    @aas,
;

LINE:
while (my $line = <STDIN>) {

    chomp $line;
    my @parts = split "\t", $line;
    my @stats;
    my @covs;

    for my $acc (split /\|/, $parts[0]) {

        if (! defined $stats{$acc}) {
            warn "failed to find stats for $acc\n";
            next LINE;
        }
        push @stats, $stats{$acc};

        # calculate protein coverage
        my $seq = $seqs{$acc}
            // die "Failed to find seq $acc in db";
        my $len = length($seq);
        for my $idx (@pep_seqs) {
            my $pep_str = $parts[$idx];
            my @peps = split ',', $pep_str;
            my @cov = (0) x $len;
            for my $p (@peps) {
                if ($seq =~ /$p/) {
                    for ($-[0]..$+[0]-1) {
                        $cov[$_] = 1;
                    }
                }
            }
            push @{ $covs[$idx] }, sum(@cov)/$len*100;
        }

    }
    my @means;
    for my $i (0..24) {
        push @means, mean( map {$_->[$i]} @stats );
    }

    # replace peptide lengths with protein coverage
    my $len = $means[0];
    for (@pep_seqs) {
        my $cov = $parts[$_] eq 'NA'
            ? 'NA'
            : sprintf("%0.1f", mean(@{ $covs[$_] }));
        $parts[$_] = $cov;
    }
    say join "\t",
        @parts,
        @means,
    ;

}

sub mean { return sum(@_)/scalar(@_) }

