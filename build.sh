#!/bin/sh
# Type './build.sh' to make iOS libraries.
# Type './build.sh -arch arm64' to make iOS libraries for iOS 64-bit.
# Type './build.sh clean' to remove object files.

if [ ! -f ../vgcore/ios/build.sh ] ; then
    git clone https://github.com/rhcad/vgcore ../vgcore
fi
if [ ! -f ../vgios/build.sh ] ; then
    git clone https://github.com/rhcad/vgios ../vgios
fi
if [ ! -f ../vgplay/ios/build.sh ] ; then
    git clone https://github.com/rhcad/vgplay ../vgplay
fi

if [ ! -f output/libTouchVGPlay.a ] ; then
    cd ../vgplay/ios
    sh build.sh $1 $2
    cd ../../vgplay-ios
fi

mkdir -p output
cp -R ../vgplay/ios/output/libTouch*.a output
