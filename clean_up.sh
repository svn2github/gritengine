#!/bin/sh

find -name '*~' -o -name '.*.swp' -o -name 'svn-commit*.tmp' -o -name '*.blend1' -o -name '*.blend2' -o -name '*.log' -o -name '*.skeleton.xml' -o -name '*.mesh.xml' -o -name '*.mk.bak' | xargs rm -vf
find gtasa grit_core -name 'core' -o -name 'vgcore.*' -o -name 'core.*' | xargs rm -vf

