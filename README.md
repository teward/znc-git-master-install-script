# ZNC Git Master Helper Script

## Install Git Master and Dependencies on Ubuntu automatically!

This is an Installation Helper Script to install Git Master on Ubuntu.

It automatically checks your Ubuntu version to make sure you have specific
versions of Ubuntu, and determines the prerequisite requirements you will
need.  This includes PPAs containing sufficiently updated build dependencies
to run and build ZNC git master on Ubuntu.

This is designed to just be a utility script.  It is NOT smart enough to detect
build failures, so you have to look through output yourself if there is a build
problem.  This also installs certain other `gcc`/`g++` compiler versions if you
are on older releases, or have newer `gcc`/`g++` compilers.  We do this to be
certain you have the required compatibilities for building and such.

------

This script was designed on Ubuntu 14.04 and was initially designed for 1.5-git
of ZNC (pre 1.6).

To use it, simply run the included .sh script.  It is a Bash script.

***LIMITATION:*** Unfortuantely this relies on PPAs.  These PPAs do not have support 
for any architecture other than i386 and amd64 at this time.  This script, therefore, 
cannot be used on non-standard architecture (such as ARM or PowerPC) at this time.

------

The current compatibility version for this script is as follows:

ZNC Git Master: 1.5-git (pre-1.6)
Minimum Ubuntu Version Required.: 12.04

------

If you have an issue with this script, please report the issue here:
https://github.com/teward/znc-git-master-install-script/issues

If you have a code change you would like to suggest, then please fork 
this repository on Github, and file a pull request.

------

This script is released under the Apache 2.0 license.
