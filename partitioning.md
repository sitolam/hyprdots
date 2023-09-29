# --// Hyprdots guided partitioning //--

### Partitioning

#### Making the partitions

```bash
# Check which disks are plugged in
lsblk

# Open the partition tool
cfdisk
```

Make tree partitions

* `512MB` boot partion
* `16GB` swap partition
* The rest is your root partiton

```bash
# Use this command to keep you track of everything
lsblk
```

#### Formatting the partitions

```bash
# Formatting the boot partition
mkfs.fat -F 32 -n ARCHBOOT </dev/sda1>

# Formatting the swap partition
mkswap -L archswap </dev/sda2>

# Formatting the root partition
mkfs.ext4 -L archroot </dev/sda3>
```

#### Mounting the partitions

```bash
# Mounting the root partition
mount /dev/disk/by-label/archroot /mnt

# Mounting the boot partition
mkdir -p /mnt/boot/efi
mount /dev/disk/by-label/ARCHBOOT /mnt/boot/efi

# Turning on the swap partition
swapon /dev/disk/by-label/archswap

# Use this command to check if everything is ok
lsblk
```

#### Exiting to the script

```bash
# Type 'exit' to go back to the script
exit
```