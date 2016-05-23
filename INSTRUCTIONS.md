Instructions for Rebuilding a NEMAC AWS Cloud Server
====================================================

NEMAC has a cluster of Linux servers ("instances") running in Amazon's EC2,
which is part of AWS.

Overview
--------

In general, an EC2 instance can use either "ephemeral" or "EBS"
storage for its virtual disk drive(s).  Ephemeral storage is lost when
the instance stops or is terminated.  EBS, which stands for "Elastic
Block Store", provides storage which is persistent --- it is organized
into volumes that can survive even after the associated instance stops
or is terminated.  EBS volumes can also be backed up in "snapshots".

All of NEMAC's instances use EBS storage.  None of them use
any ephemeral storage.  The snapshots of the EBS volumes associated
with an EC2 instance provide a complete backup of the state of the
instance and its data, and these snapshots can be used to "rebuild"
a new EC2 instance which is identical to the original one.
These instructions describe how to do this.

*Important Note:* All of the steps in these instructions can be
carried out without affecting the currently running server or its EBS
volumes.  The ideal way to rebuild an instance is to use these steps
to build a new instance with new EBS volumes created from snapshots of
the existing ones, while the old instance continues to run.  Once the
new instance is up and running (and with the old one still running),
login to it to confirm that it is running correctly, then move the
elastic IP address from the old instance to the new one.  This act of
moving the elastic IP address to the new instance is what will cause
the new instance to start to function in place of the old one. Leave
the old instance running, with its old volumes intact, so that you can
easily switch back to the old one if problems are discovered with the
new one.  Only after several days or weeks of successful use of the
new instance should you terminate the old instance and delete its EBS
volumes.

In practice, of course, one of the main reasons you might be carrying
out these instructions to rebuild an instance is because the old one
is not functioning properly or has already stopped, in which case
switching back to the old one is not an option.  But you should still
avoid deleting it or its volumes until  you are sure the replacement
has a long (month or so?) track record of working correctly.


Steps
-----

1. Assume that the instance we are rebuilding is named *cloudx*.
   This instance will have several resources associated with it
   in AWS:
   * the EC2 instance itself
   * one or more "Block devices" which are EBS volumes
   * exactly one of the above "Block devices" listed as "Root device"
   * an Elastic IP address
   * a DNS entry in Route 53 (AWS's DNS) that maps the name *cloudx.nemac.org*
     to the associated Elastic IP address

1. launch/create new instance NEWFRED with the same AMI as FRED (use the "launch more like this" menu item)
1. This will have the side-effect of creating a new root volume from the AMI; call this volume NEWFRED_ROOT_DEFAULT.
   1. create a new volume from most recent (good) snapshot of FRED's root drive; call this one NEWFRED_ROOT_RESTORE
1. shut down NEWFRED
1. detatch NEWFRED_ROOT_DEFAULT from NEWFRED
1. attach NEWFRED_ROOT_RESTORE to NEWFRED as its root volume (root vol must be attached at /dev/sda1)
1. boot NEWFRED
1. login to NEWFRED, check that all is good
1. re-assign FRED's elastic IP to NEWFRED
1. delete volume NEWFRED_ROOT_DEFAULT
1. rename NEWFRED_ROOT_RESTORE appropriately
1. rename FRED's original root drive to something like OLDFRED_ROOT; come back and delete it after a few days
1. set tags on NEWFRED to configure backup
1. rename FRED to OLDFRED, NEWFRED to FRED


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
    
