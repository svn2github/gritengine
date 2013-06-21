#!/bin/bash

source get_common.sh

echo "Downloading Bullet from googlecode via svn"
$SVN co -r "$(cat bullet_revision.txt)" 'http://bullet.googlecode.com/svn/trunk' bullet
    
do_patch "bullet" "bullet.patch"
