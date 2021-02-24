# 1. Install the library via vcpkg
# This install jsoncpp for the 4 android target ABIs and for the host computer.
# see the correspondence between ABIs and vcpkg triplets in the table below: 
#
# |VCPKG_TARGET_TRIPLET       | ANDROID_ABI          |
# |---------------------------|----------------------|
# |arm64-android              | arm64-v8a            |
# |arm-android                | armeabi-v7a          |
# |x64-android                | x86_64               |
# |x86-android                | x86                  |
$VCPKG_ROOT/vcpkg install \
  jsoncpp \
  jsoncpp:arm-android \
  jsoncpp:arm64-android \
  jsoncpp:x86-android \
  jsoncpp:x64-android


# 2. Test the build
#
# First, select an android ABI
# Uncomment one of the four possibilities below
#
android_abi=armeabi-v7a
# android_abi=x86
# android_abi=arm64-v8a
# android_abi=x86_64

rm -rf build 
mkdir build && cd build 

# DVCPKG_TARGET_ANDROID will load vcpkg_android.cmake,
# which will then load the android + vcpkg toolchains.
cmake .. \
  -DVCPKG_TARGET_ANDROID=ON \
  -DANDROID_ABI=$android_abi
make
