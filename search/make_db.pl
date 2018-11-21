#!/usr/bin/env perl

use strict;
use warnings;

use MS::Search::DB;

my $TAIR10 = 'ftp://ftp.arabidopsis.org/home/tair/Sequences/blast_datasets/TAIR10_blastsets/TAIR10_pep_20110103_representative_gene_model_updated';

my $db = MS::Search::DB->new;

$db->add_from_url( $TAIR10 );

$db->add_crap;
$db->add_decoys(
    type   => 'reverse',
    prefix => 'DECOY_',
);

$db->write( randomize => 1 );

exit;
