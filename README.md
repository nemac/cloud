cloud
=====

This project servers as a small top-level "umbrella" container for the various codebases
and configuration files used to maintain NEMAC AWS cloud servers.

To set it up:

* get a copy of NEMAC's AWS keys from a NEMAC staff member and put them
  in the correct location on your computer
* clone a copy of the `cirrus` project into this directory
* clone a copy of the `cloudconf` project into this directory
* clone a copy of the `cloudmanager` project into this directory
* clone a copy of the `cloudusers` project into this directory
* source the file `setup.sh` to set the relevant environment variables

See cloudmanager/README.md for more instructions.
