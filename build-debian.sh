#!/bin/bash
# Repackage Sonicwall's proprietay NetExtender Client RPM to a better DEB than 
# a basic alien run.
#
# You will need alien, fakeroot and what else?

if [[ "$1" == "" && "$2" == "" ]] ; then
   echo "Usage: build-debian.sh <name of Sonicwall RPM> <arch>"
   exit
fi

if [[ "$2" == "" ]] ; then
   echo "You forgot arch (i386,amd64) parameter!"
   echo "Usage: build-debian.sh <name of Sonicwall RPM> <arch>"
   exit
fi

rm -rf netextender

# Debian-fashion with some optimizations.
fakeroot alien --to-deb --generate --scripts --verbose $1 > tmp.txt

# SonicWall's package version numbers sometimes don't  match packages name. Great :-(
NX=$(echo 'NetExtender-'$(tail -1 tmp.txt | cut -f2 -d' ' | cut -f2 -d'-'))
rm tmp.txt

mv $NX netextender

# Copy some prepared files so we don't have to patch anymore, less error-prone
cp -v debian/postinst netextender/debian/
cp -v debian/postrm netextender/debian/
cp -v debian/control.$2 netextender/debian/control

# Users with gnome at least will have a correct Icon in the menu
mkdir -p netextender/usr/share/applications
cp -v debian/NetExtender.desktop netextender/usr/share/applications/

echo OK, I did the 
echo - Uncompress the RPM
echo - Copy some files for better Debian package
echo - Add you a nice icon in the gnome menu
echo
echo  Now we gonna package that kid
read

# Build package use explicitely with arch parameter
#  (in case building machine is amd64) and target i386 for example 
# And -b because it's only binary bits and there is nothing to compiles 
cd netextender
# 
echo "dpkg-buildpackage -a$2 -b"

# Cleanup
cd ..
# rm -rf netextender
rm -rf $NX.orig
