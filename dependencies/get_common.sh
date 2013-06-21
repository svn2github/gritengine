#!/bin/bash


UNZIP=unzip
WGET=wget
TAR=tar
SVN=svn
PATCH="patch -l"
RM=rm
HG=hg

do_patch() {
    cd "$1"
    echo "Patching (dry run)"
    if $PATCH --dry-run -p0 < ../"$2" ; then
            echo "Patching (for real)"
            $PATCH -p0 < ../"$2"
    else
            echo "Patching failed!  Aborting script."
            exit 1
    fi
    cd ..
}

