#!/bin/bash
# Repackage Sonicwall's proprietay NetExtender Client RPM to a better DEB than 
# a basic alien run.
#
# You will need alien, fakeroot and what else?

if [[ "$1" == "" && "$2" == "" ]] ; then
   echo "Usage: build-debian.sh <name of Sonicwall RPM> <version> <arch>"
   exit
fi

if [[ "$2" == "" ]] ; then
   echo "You forgot version parameter!"
   echo "Usage: build-debian.sh <name of Sonicwall RPM> <version> <arch>"
   exit
fi

if [[ "$3" == "" ]] ; then
   echo "You forgot arch (i386,amd64) parameter!"
   echo "Usage: build-debian.sh <name of Sonicwall RPM> <version> <arch>"
   exit
fi

# Debian-fashion with some optimizations.
fakeroot alien --to-deb --generate --scripts --verbose $1

echo 'Debianize:' $1
echo 'You told me Version:' $2

echo 'GENERATE: Alien prepares Debian package'
NX='NetExtender-'$2
mv $NX netextender

# APPLY: Patch for better Debian Package
patch -p1 < ./pretify-netextenderRPM.patch

# Users with gnome at least will have a correct Icon in the menu
mkdir -p netextender/usr/share/applications
cp netextender/usr/share/netExtender/NetExtender.desktop netextender/usr/share/applications/

# Build package use explicitely with arch parameter
#  (in case building machine is amd64) and target i386 for example 
# And -b because it's only binary bits and there is nothing to compiles 
cd netextender
dpkg-buildpackage -a$3 -b

# Cleanup
cd ..
rm -rf netextender
rm -rf $NX.orig

