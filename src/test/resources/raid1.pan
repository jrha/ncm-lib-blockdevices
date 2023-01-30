object template raid1;

# keep BlockDevices happy
"/system/network/hostname" = 'x';
"/system/network/domainname" = 'y';

"/hardware/harddisks/sdb" = dict(
  "sda", dict(
    "boot", true,
    "capacity", 1843200,
    "interface", "sata",
    "model", "Generic SATA disk",
  ),
  "sdb", dict(
    "capacity", 1907729,
    "interface", "sata",
  ),
);



"/system/blockdevices" = dict(
    "md", dict(
        "md1", dict(
            "device_list", list(
                "partitions/sda2",
                "partitions/sdb2"
            ),
            "raid_level", "RAID1",
            "stripe_size", 64
        ),
        "md2", dict(
            "device_list", list(
                "partitions/sda4",
                "partitions/sdb4"
            ),
            "raid_level", "RAID1",
            "stripe_size", 64
        ),
        "md3", dict(
            "device_list", list(
                "partitions/sda5",
                "partitions/sdb5"
            ),
            "raid_level", "RAID1",
            "stripe_size", 64
        ),
    ),
    "partitions", dict(
        "sda1", dict(
            "flags", dict(
                "bios_grub", true
            ),
            "holding_dev", "sda",
            "size", 100,
            "type", "primary"
        ),
        "sda2", dict(
            "holding_dev", "sda",
            "size", 512,
            "type", "primary"
        ),
        "sda3", dict(
            "holding_dev", "sda",
            "size", 65536,
            "type", "primary"
        ),
        "sda4", dict(
            "holding_dev", "sda",
            "size", 102400,
            "type", "primary"
        ),
        "sda5", dict(
            "holding_dev", "sda",
            "type", "primary"
        ),
        "sdb1", dict(
            "flags", dict(
                "bios_grub", true
            ),
            "holding_dev", "sdb",
            "size", 100,
            "type", "primary"
        ),
        "sdb2", dict(
            "holding_dev", "sdb",
            "size", 512,
            "type", "primary"
        ),
        "sdb3", dict(
            "holding_dev", "sdb",
            "size", 65536,
            "type", "primary"
        ),
        "sdb4", dict(
            "holding_dev", "sdb",
            "size", 102400,
            "type", "primary"
        ),
        "sdb5", dict(
            "holding_dev", "sdb",
            "type", "primary"
        ),
    ),
    "physical_devs", dict(
        "sda", dict(
            "label", "gpt"
        ),
        "sdb", dict(
            "label", "gpt"
        ),
  ),
);

"/system/filesystems" = list(
    dict(
        "block_device", "md/md1",
        "format", true,
        "freq", 0,
        "mount", true,
        "mountopts", "defaults",
        "mountpoint", "/boot",
        "pass", 0,
        "preserve", true,
        "type", "ext2"
    ),
    dict(
        "block_device", "partitions/sda3",
        "format", true,
        "freq", 0,
        "mount", true,
        "mountopts", "defaults",
        "mountpoint", "swap",
        "pass", 0,
        "preserve", true,
        "type", "swap"
    ),
    dict(
        "block_device", "md/md2",
        "format", true,
        "freq", 0,
        "mkfsopts", "-l version=2 -i size=1024 -n size=65536",
        "mount", true,
        "mountopts", "noatime,swalloc",
        "mountpoint", "/",
        "pass", 0,
        "preserve", true,
        "type", "xfs"
    ),
    dict(
        "block_device", "md/md3",
        "format", true,
        "freq", 0,
        "mkfsopts", "-l version=2 -i size=1024 -n size=65536,ftype=1",
        "mount", true,
        "mountopts", "noatime,swalloc",
        "mountpoint", "/pool",
        "pass", 0,
        "preserve", true,
        "type", "xfs"
    ),
);
