# ZNC Git Master Helper Script

## Install Git Master and Dependencies on Ubuntu by default.

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

This script was designed on Ubuntu 14.04 and was initially designed for 1.5-git
of ZNC (pre 1.6).

The current compatibility version for this script is as follows:

ZNC Git Master: 1.5-git (pre-1.6)
Minimum Ubuntu Version Required.: 12.04





This script is released under the Apache 2.0 license.
