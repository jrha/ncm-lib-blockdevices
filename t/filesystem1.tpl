object template filesystem1;
include {"bddummy"};

include {"quattor/blockdevices"};
include {"quattor/filesystems"};
include {"fsdummy"};
"/system/blockdevices" = nlist (
	"physical_devs", nlist (
		"hdb", nlist ("label", "gpt")
		),
	"partitions", nlist (
		"hdb1", nlist (
			"holding_dev", "hdb",
			"size", 4096,
			)
		)
	);

"/system/filesystems" = list (
	nlist (
		"mount", true,
		"mountpoint", "/Lagoon",
		"preserve", true,
		"format", false,
		"mountopts", "auto",
		"block_device", "partitions/hdb1",
		"type", "ext3",
		"freq", 0,
		"pass", 1
		)
	);
