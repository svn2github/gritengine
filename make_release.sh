#!/bin/bash

DIR=Grit_Prerelease_`TZ= date +%Y%m%d_%H%M`

# build up the release in this directory
mkdir "$DIR"
mkdir "$DIR"/gostown/
mkdir "$DIR"/gtasa/

# copy in the main game files
FILES="Grit.exe Grit.dat cg.dll icuuc42.dll icuin42.dll icudt42.dll system movie common vehicles top_gear island testville playground earth wipeout Tools"
for i in $FILES ; do
    cp -r "grit_core/media/$i" "$DIR"
done

cp -a grit_core/linux/grit.x11.stripped "$DIR"/Grit.x11

# explicitly copy files from the gostown and gtasa dirs so that we don't accidently package copyright content
for i in gostown/init.lua ; do
    cp -r "grit_core/media/$i" "$DIR"/gostown
done
for i in gtasa/init.lua gtasa/cars.lua ; do
    cp -r "grit_core/media/$i" "$DIR"/gtasa
done

#omit files that we don't want to package with normal releases -- not to hide from the user but to reduce zip size
find "$DIR" -name '.svn' | xargs rm -rf
find "$DIR" -name '*.blend' | xargs rm -rf
find "$DIR" -name '*.xml' | xargs rm -rf

#finally, make the zip
cd "$DIR"
zip -r ../"$DIR".zip *
