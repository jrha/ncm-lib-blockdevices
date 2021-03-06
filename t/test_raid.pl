#!/usr/bin/perl -w

BEGIN {
  unshift(@INC, '/var/ncm/lib/perl');
  unshift(@INC, '/usr/lib/perl');
  unshift(@INC,'/opt/edg/lib/perl');
  use dummyapp;

  our $this_app = dummyapp->new;
}

use strict;
use warnings;
use EDG::WP4::CCM::CacheManager;
use EDG::WP4::CCM::Fetch;
use NCM::Blockdevices;
use NCM::Disk;
use NCM::LVM;
use NCM::MD;
use NCM::Partition;
use Test::More  tests=>16;
use NCM::Filesystem;
use Data::Dumper;
use CAF::Application;
use POSIX;

$ENV{LANG}='C';

system (qw {dd if=/dev/zero of=/dev/sda bs=1M count=10});
system (qw {parted -s /dev/sda mklabel gpt});
my $fh = EDG::WP4::CCM::Fetch->new ({PROFILE => "http://uraha.ft.uam.es/spec/raid1.xml",
				     FOREIGN => 1});
$fh->fetchProfile;

my $cm = EDG::WP4::CCM::CacheManager->new ($fh->{CACHE_ROOT});
my $cfg = $cm->getLockedConfiguration (0);
my $md = NCM::MD->new ("/system/blockdevices/md/md0", $cfg);
my $err = $md->create;
ok (!$err, "Software RAID md0 successfully created");
ok (!$md->has_filesystem, "MD detects it doesn't have any filesystems");
$err = system ("grep -q md0 /proc/mdstat");
ok (!$err, "Software RAID md0 actually created");
my $out = `grep -c sda /proc/partitions`;
chomp $out;
is ($out, 3, "Software RAID md0 created with the appropriate devices");
$err = $md->remove;
ok (!$err, "Software RAID md0 successfully removed");
$err = system ("grep md0 /proc/mdstat &>/dev/null");
ok ($err, "Software RAID md0 actually removed");
$out = `grep -c sda /proc/partitions`;
chomp $out;
is ($out, 1, "Partitions depending on md0 successfully removed");
my $fh2 = EDG::WP4::CCM::Fetch->new ({PROFILE => "http://uraha.ft.uam.es/spec/raid2.xml",
				     FOREIGN => 1});
$fh2->fetchProfile;
my $cm2 = EDG::WP4::CCM::CacheManager->new ($fh2->{CACHE_ROOT});
my $cfg2 = $cm2->getLockedConfiguration (0);
my $fs = NCM::Filesystem->new ("/system/filesystems/0", $cfg2);
$err = $fs->create_if_needed;
ok (!$err, "Filesystem correctly created");
ok ($fs->{block_device}->has_filesystem, "MD detects it has a filesystem");
$err = system ("grep md0 /proc/mdstat &>/dev/null");
ok (!$err, "MD0 under filesystem correctly created");
my $l =`grep /Mokona /etc/fstab`;
my $fs2 = NCM::Filesystem->new_from_fstab ($l, $cfg2);
ok (!$fs2->{preserve}, "Filesystem from fstab shouldn't be preserved");
ok ($fs2->{format}, "Filesystem from fstab should be formatted");
is (ref ($fs2->{block_device}), 'NCM::MD',
    "Block device correctly instantiated");
is ($fs2->{block_device}->devpath, "/dev/md0",
    "Correct path on /dev/md0");
$fs2->remove_if_needed;
$err = system ("grep -q /Mokona /etc/fstab");
ok ($err, "Filesystem correctly removed");
$err = system ("grep -q md0 /proc/mdstat");
ok ($err, "MD device from system correctly removed");
