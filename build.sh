#!/bin/sh
# Type './build.sh' to make iOS libraries.
# Type './build.sh -arch arm64' to make iOS libraries for iOS 64-bit.
# Type './build.sh clean' to remove object files.

if [ ! -f ../vgcore/ios/build.sh ] ; then
    git clone https://github.com/touchvg/vgcore ../vgcore
fi
if [ ! -f ../vgios/build.sh ] ; then
    git clone https://github.com/touchvg/vgios ../vgios
fi

iphoneos71=`xcodebuild -showsdks | grep -i iphoneos7.1`
iphoneos70=`xcodebuild -showsdks | grep -i iphoneos7.0`
iphoneos61=`xcodebuild -showsdks | grep -i iphoneos6.1`
iphoneos51=`xcodebuild -showsdks | grep -i iphoneos5.1`
iphoneos43=`xcodebuild -showsdks | grep -i iphoneos4.3`

vgiospath=../vgios
corepath=../vgcore/ios/TouchVGCore

if [ -n "$iphoneos71" ]; then
    xcodebuild -project $vgiospath/TouchVG.xcodeproj $1 $2 -sdk iphoneos7.1 -configuration Release
    xcodebuild -project $corepath/TouchVGCore.xcodeproj $1 $2 -sdk iphoneos7.1 -configuration Release
else
if [ -n "$iphoneos70" ]; then
    xcodebuild -project $vgiospath/TouchVG.xcodeproj $1 $2 -sdk iphoneos7.0 -configuration Release
    xcodebuild -project $corepath/TouchVGCore.xcodeproj $1 $2 -sdk iphoneos7.0 -configuration Release
else
if [ -n "$iphoneos61" ]; then
    xcodebuild -project $vgiospath/TouchVG.xcodeproj $1 $2 -sdk iphoneos6.1 -configuration Release
    xcodebuild -project $corepath/TouchVGCore.xcodeproj $1 $2 -sdk iphoneos6.1 -configuration Release
else
if [ -n "$iphoneos51" ]; then
    xcodebuild -project $vgiospath/TouchVG.xcodeproj $1 $2 -sdk iphoneos5.1 -configuration Release
    xcodebuild -project $corepath/TouchVGCore.xcodeproj $1 $2 -sdk iphoneos5.1 -configuration Release
else
if [ -n "$iphoneos43" ]; then
    xcodebuild -project $vgiospath/TouchVG.xcodeproj $1 $2 -sdk iphoneos4.3 -configuration Release
    xcodebuild -project $corepath/TouchVGCore.xcodeproj $1 $2 -sdk iphoneos4.3 -configuration Release
fi
fi
fi
fi
fi

mkdir -p output/TouchVG
cp -R $vgiospath/build/Release-universal/libTouchVG.a output
cp -R $vgiospath/build/Release-universal/include/TouchVG output

mkdir -p output/TouchVGCore
cp -R $corepath/build/Release-universal/libTouchVGCore.a output
cp -R $corepath/build/Release-universal/include/TouchVGCore output

if [ -f ../vgplay/ios/build.sh ] ; then
    cd ../vgplay/ios; sh build.sh $1 $2; cd ../../vgplay-ios
    mkdir -p vgplay
    cp ../vgplay/ios/output/libTouchVGPlay.a vgplay
    cp ../vgplay/ios/output/TouchVGPlay/*.h vgplay
fi