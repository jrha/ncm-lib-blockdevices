#!/usr/bin/perl
# -*- mode: cperl -*-
# ${license-info}
# ${developer-info}
# ${author-info}
# ${build-info}

use strict;
use warnings;

use EDG::WP4::CCM::Element qw(escape);
use Test::More;
use Test::Quattor qw(raid1);
use helper;

use Test::Quattor::RegexpTest;
use Cwd;
use NCM::MD;

#$CAF::Object::NoAction = 1;
set_disks({sdb => 1});

mkdir('target/test') if ! -d 'target/test';

my $regexpdir= getcwd()."/src/test/resources/regexps";
my $cfg = get_config_for_profile('raid1');

my $md = NCM::MD->new ("/system/blockdevices/md/md1", $cfg);
is (ref ($md), "NCM::MD", "MD correctly instantiated");

# test some ks functions, those just print to default FH
my $fhmd = CAF::FileWriter->new("target/test/ksfs");

my $origfh = select($fhmd);

$md->create_ks;
diag "$fhmd";

Test::Quattor::RegexpTest->new(
    regexp => "$regexpdir/raid1_create_ks_1",
    text => "$fhmd"
)->test();

# restore FH for DESTROY
select($origfh);

done_testing();
