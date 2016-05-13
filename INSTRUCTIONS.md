To rebuild server FRED


* launch/create new instance NEWFRED with the same AMI as FRED (use the "launch more like this" menu item)
  This will have the side-effect of creating a new root volume from the AMI; call this volume NEWFRED_ROOT_DEFAULT.
> * create a new volume from most recent (good) snapshot of FRED's root drive; call this one NEWFRED_ROOT_RESTORE
* shut down NEWFRED
* detatch NEWFRED_ROOT_DEFAULT from NEWFRED
* attach NEWFRED_ROOT_RESTORE to NEWFRED as its root volume (root vol must be attached at /dev/sda1)
* boot NEWFRED
* login to NEWFRED, check that all is good
* re-assign FRED's elastic IP to NEWFRED
* delete volume NEWFRED_ROOT_DEFAULT
* rename NEWFRED_ROOT_RESTORE appropriately
* rename FRED's original root drive to something like OLDFRED_ROOT; come back and delete it after a few days
* set tags on NEWFRED to configure backup
* rename FRED to OLDFRED, NEWFRED to FRED


------------------------------------------------------------------------

1. new drive  /  ebs vol
2. plug it in /  attach it
3. linux sees the new device and automatically gives it a device reference in the form
   of a "virtual" fs entry in "/dev", e.g. /dev/xvda.
4. you partition the device into partitions (fdisk, parted, gparted)
5. individual partitions are available within the system as /dev/xvda1, /dev/xvda2, ...
   individual partitions get unique UUIDs
6. you can assign labels to partitions with "e2label"
7. format each partition ("mkfs -t ext4 ...")

physical drive (ebs vol)
  partition table, partitions
  for each partition:
    UUID
    optional label
    filesystem (formatting)
    
