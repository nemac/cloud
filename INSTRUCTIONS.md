Instructions for Rebuilding a NEMAC AWS Cloud Server
====================================================

NEMAC has a cluster of Linux servers ("instances") running in Amazon's
EC2, which is part of AWS.

Overview
--------

In general, an EC2 instance can use either "ephemeral" or "EBS"
storage for its virtual disk drive(s).  Ephemeral storage is lost when
the instance stops or is terminated.  EBS, which stands for "Elastic
Block Store", provides storage which is persistent --- it is organized
into volumes that can survive even after the associated instance stops
or is terminated.  EBS volumes can also be backed up in "snapshots".

All of NEMAC's instances use EBS storage.  None of them use any
ephemeral storage.  The snapshots of the EBS volumes associated with
an EC2 instance provide a complete backup of the state of the instance
and its data, and these snapshots can be used to "rebuild" a new EC2
instance which is identical to the original one.  These instructions
describe how to do this.

*Important Note:* All of the steps in these instructions can be
carried out without affecting the currently running server or its EBS
volumes.  The ideal way to rebuild an instance is to use these steps
to build a new instance with new EBS volumes created from snapshots of
the existing ones, while the old instance continues to run.  This new
instance will be like a clone of the original one and all its data ---
it's a separate copy that exists independently.  Once the new instance
is up and running (and with the old one still running), login to it to
confirm that it is running correctly, then move the elastic IP address
from the old instance to the new one.  This act of moving the elastic
IP address to the new instance is what will cause the new instance to
start to function in place of the old one. Leave the old instance
running, with its old volumes intact, so that you can easily switch
back to the old one if problems are discovered with the new one.  Only
after several days or weeks of successful use of the new instance
should you terminate the old instance and delete its EBS volumes.

In practice, of course, one of the main reasons you might be carrying
out these instructions to rebuild an instance is because the old one
is not functioning properly or has already stopped, in which case
switching back to the old one is not an option.  But you should still
avoid deleting it or its volumes until you are sure the replacement
has a long (month or so?) track record of working correctly.


Steps
-----

1. Assume that the instance you are rebuilding is named `cloudx`.
   This instance will have several resources associated with it
   in AWS:  

   * the EC2 instance itself
   * one or more "Block devices" which are EBS volumes
   * exactly one of the above "Block devices" listed as "Root device"
   * an Elastic IP address
   * a DNS entry in Route 53 (AWS's DNS) that maps the name `cloudx.nemac.org`
     to the associated Elastic IP address

1. Make note of the volume ids, and Name tag values, of all of the
   block devices (EBS volumes), taking care to note which one is the
   root device.
   
1. For each of the above EBS volumes, identify the snapshot of that
   volume that you want to use to create the clone (usually the most
   recent snapshot), and create a new volume from each of these
   snapshots.  Give each of these volumes a Name tag value that is the
   same as the name of the old volume, but with a prefix of `new-`.
   For example, if `cloudx` has volumes named `cloudx-root` and
   `cloudx-data1`, create new volumes named `new-cloudx-root` and
   `new-cloudx-data1`.
   
1. Use the "launch more like this" option from the EC2 instance
   dashboard to launch a new instance like `cloudx`.  You can do this
   even if `cloudx` itself is stopped or otherwise having problems.
   In the sequence of configuration screens for the new instance, give
   it a Name tag value of `new-cloudx`, and accept the default
   settings for everything else.

1. The act of launching this new instance will create a new root
   volume that you do not need -- you're going to replace the default
   root volume with the clone you created above.  Immediately after
   the new instance launches, find its root volume and give it a Name
   tag value of `new-cloudx-root-default` (this is to make it easier
   to find that volume and delete it below).
   
1. As soon as the `new-cloudx` instance has finished launching, stop it
   (do NOT terminate it).
   
1. Once `new-cloudx` has finished stopping, detatch the
   `new-cloudx-root-default` volume from it.  (In general you will not
   need this volume at all from this point on, but refrain from
   actually deleting it until one of the last steps below, just in
   case there are problems booting the instance with the clone
   drives.)
   
1. Attach the `new-cloudx-root` volume (the clone of the original root
   volume that you created above) to the `new-cloudx` instance, using
   the device name `/dev/sda1`.  Note that the root device MUST be
   `/dev/sda1`, and you cannot attach a new volume using this device
   name until the original one has been detached.
   
1. If there were any additional EBS volumes on `cloudx`, attach the
   clones you made for them now.  These additional volumes must be
   attached AFTER the root device is attached.
   
1. Restart `new-cloudx`.

1. Once `new-cloudx` has finished booting, make note of its public IP
   address and ssh to it.  (You should be able to ssh in using
   whatever credentials work for the original `cloudx`.)  Poke around
   in the shell to confirm that everything looks good (verify that the
   nappl applications are present in /var/vsites/..., that all data
   drives are present in the correct places, etc).
   
1. Assuming everything looks good on `new-cloudx`, disassociate the
   relevant elastic ip address from `cloudx` and re-associate it to
   `new-cloudx`.  This will cause all internet traffic for the name
   `cloudx.nemac.org` to go to the new instance rather than the old
   one.

1. Test the new instance thoroughly by visiting any web sites running
   on it and checking that its applications work property.  Also make
   sure you can ssh to it using the name `cloudx.nemac.org`.  Note
   that assuming everything has worked correctly, you won't be able to
   easily tell the difference between an ssh session on the new server
   and one on the old server.  You can use the following command,
   however, to confirm the EC2 instance id of the server:

       wget -q -O - http://instance-data/latest/meta-data/instance-id
       
   Make sure this instance id corresponds to the new `new-cloudx`
   instance.
   
1. Change the Name tag values for the `cloudx` instance and its old
   volumes to have an `old-` prefix.  So the instance name will become
   `old-cloudx`, and its volume names will become `old-cloudx-root`
   and `old-cloudx-data1` (for example).
   
1. Set the `Backup` tag value for the `old-cloudx-*` volumes to be
   "false"; this prevents further snapshots of the old volumes.
   
1. Change the Name tag values for the `new-cloudx` instance and its
   new volumes to remove the `new-` prefix.  So the instance name will
   be `cloudx`, and its volume names will be `cloudx-root` and
   `cloudx-data1` (for example).

1. Set the `Backup`, `Frequency`, and `Retention` tags for the new
   volumes (which are now named the same as the old ones were, but
   which do not yet have these tags set).  This causes these volumes
   to be included in the regular snapshotting process.
   
1. Delete the `new-cloudx-root-default` volume that got created when
   you launched the new instance above.
   
1. Once you are sure that the new instance is succesfully functioning
   in place of the old one, stop the old instance (now known as
   `old-cloudx`) if it is still running.  Do NOT terminate it yet, and
   do not delete its volumes yet.
   
1. After several more weeks of the new instance working successfully
   and the old one being shut down, terminate the old instance and
   delete the old EBS volumes.  Double (triple!) check that any
   instance you terminate (a) is already stopped, and (b) has a name
   that starts with `old-`'.  Wait for the instance to show as
   "terminated" in the EC2 dashboard before deleting the old volumes.
   Once the old instance shows as "terminated" in the EC2 dashboard,
   make sure that the EBS volumes you delete show as "available" and
   have names that start with `old-`.
