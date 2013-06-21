#!/bin/bash

source get_common.sh

ICU='icu4c-4_2_1-src.tgz'

echo "Downloading libicu from its website via http..."
$WGET "http://download.icu-project.org/files/icu4c/4.2.1/$ICU"
$TAR -xzf "$ICU" && $RM "$ICU"
