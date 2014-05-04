#!/bin/bash

(
    find high_freq_noise/ launcher/ starbox/ grit_core/src gtasa/src dependencies/util luaimg/  \( -name '*.cpp' -o -name '*.h' -o -name '*.c' \) |
    grep -v 'tex_dups.\(h\|cpp\)' |
    grep -v 'tcol_lexer.cpp' |
    grep -v 'tcol_lexer-core-engine.cpp'


    find grit_core/media  \( -name '*.lua' \) |
    grep -v 'gtasa/\(carcols\|map\|classes\|materials\|\)[.]lua' |
    grep -v 'gtasa\/[a-z0-9]\+\/init[.]lua' |
    grep -v 'gtasa\/phys_mats[.]lua' |
    grep -v 'gtasa\/vehicles[.]lua' |
    grep -v 'gtasa\/all_vehicles[.]lua' |
    grep -v 'gtasa\/non_cars[.]lua'

    find exporters \( -name '*.ms' \)

    find exporters \( -name '*.py' \)
) | xargs wc -l

(
    find grit_core/doc/grit_book \( -name '*.xml' \)
) | xargs wc
