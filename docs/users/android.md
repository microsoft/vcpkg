# Vcpkg and Android

Android is not officialy supported, and there are no official android triplets at the moment.

However, some packages can compile to Android, and the situation is improving: see the list of [PR related to Android](https://github.com/Microsoft/vcpkg/pulls?q=+android+).


## Android build requirements

1. Download the [android ndk](https://developer.android.com/ndk/downloads/)

2. Set environment variable `ANDROID_NDK_HOME` to your android ndk installation. 
   For example:

````bash
export ANDROID_NDK_HOME=/home/your-account/Android/Sdk/ndk-bundle
````

Or:
````bash
export ANDROID_NDK_HOME=/home/your-account/Android/android-ndk-r21b
````

3. Install [vcpkg](https://github.com/microsoft/vcpkg)

4. Set environment variable `VCPKG_ROOT` to your vcpkg installation.
````bash
export VCPKG_ROOT=/path/to/vcpkg
````

## Create the android triplets


### Android ABI and corresponding vcpkg triplets

There are four different Android ABI, each of which maps to 
a vcpkg triplet. The following table outlines the mapping from vcpkg architectures to android architectures

|VCPKG_TARGET_TRIPLET       | ANDROID_ABI          |
|---------------------------|----------------------|
|arm64-android              | arm64-v8a            |
|arm-android                | armeabi-v7a          |
|x64-android                | x86_64               |
|x86-android                | x86                  |

### Create the android triplets
You can copy-paste the script below to populate them, and adjust them to your needs if required.

````bash
cd $VCPKG_ROOT

echo "
set(VCPKG_TARGET_ARCHITECTURE arm)
set(VCPKG_CRT_LINKAGE dynamic)
set(VCPKG_LIBRARY_LINKAGE dynamic)
set(VCPKG_CMAKE_SYSTEM_NAME Android)
" > triplets/community/arm-android.cmake

echo "
set(VCPKG_TARGET_ARCHITECTURE arm64)
set(VCPKG_CRT_LINKAGE dynamic)
set(VCPKG_LIBRARY_LINKAGE dynamic)
set(VCPKG_CMAKE_SYSTEM_NAME Android)
" > triplets/community/arm64-android.cmake
 
echo "
set(VCPKG_TARGET_ARCHITECTURE x86)
set(VCPKG_CRT_LINKAGE dynamic)
set(VCPKG_LIBRARY_LINKAGE dynamic)
set(VCPKG_CMAKE_SYSTEM_NAME Android)
" > triplets/community/x86-android.cmake

echo "
set(VCPKG_TARGET_ARCHITECTURE x64)
set(VCPKG_CRT_LINKAGE dynamic)
set(VCPKG_LIBRARY_LINKAGE dynamic)
set(VCPKG_CMAKE_SYSTEM_NAME Android)
" > triplets/community/x64-android.cmake
````

## Install libraries for Android using vcpkg

Example for jsoncpp:

````bash
cd $VCPKG_ROOT

# specify the triplet like this
./vcpkg install jsoncpp --triplet arm-android   
# or like this
./vcpkg install jsoncpp:arm64-android           
./vcpkg install jsoncpp:x86-android
./vcpkg install jsoncpp:x64-android
````

## Consume libraries using vpckg, cmake and the android toolchain

1. Combine vcpkg and Android toolchains

vcpkg and android both provide dedicated toolchains:
````bash
vcpkg_toolchain_file=$VCPKG_ROOT/scripts/buildsystems/vcpkg.cmake
android_toolchain_file=$ANDROID_NDK_HOME/build/cmake/android.toolchain.cmake
````

When using vcpkg, the vcpkg toolchain shall be specified first. 

However, vcpkg provides a way to preload and additional toolchain, with the VCPKG_CHAINLOAD_TOOLCHAIN_FILE option. 

````bash
cmake \
  -DCMAKE_TOOLCHAIN_FILE=$vcpkg_toolchain_file \
  -DVCPKG_CHAINLOAD_TOOLCHAIN_FILE=$android_toolchain_file \
  ...
````

2. Specifiy the android abi and vcpkg triplet

When compiling for android, you need to select a matching "android abi" / "vcpkg triplet" pair.

For example:

````bash
android_abi=armeabi-v7a
vcpkg_target_triplet=arm-android

cmake 
  ...
  -DVCPKG_TARGET_TRIPLET=$vcpkg_target_triplet \
  -DANDROID_ABI=$android_abi
````

### Test on an example

The folder [docs/examples/vcpkg_android_example_cmake](../examples/vcpkg_android_example_cmake) provides a working example, with an android library that consumes the jsoncpp library:

*Details*

* The [CMakeLists](../examples/vcpkg_android_example_cmake/CMakeLists.txt) simply uses `find_package` and `target_link_library`

* The [compile.sh](../examples/vcpkg_android_example_cmake/compile.sh) script enables you to select any matching pair of "android abi" /  "vcpkg triplet" and to test the compilation

* The dummy [my_lib.cpp](../examples/vcpkg_android_example_cmake/my_lib.cpp) file uses the jsoncpp library

*Note*: this example only compiles an Android library, as the compilation of a full fledged Android App is beyond the scope of this document.

### Test on an example, using [vcpkg_android.cmake](../examples/vcpkg_android_example_cmake_script/cmake/vcpkg_android.cmake)

The folder [docs/examples/vcpkg_android_example_cmake_script](../examples/vcpkg_android_example_cmake_script) provides the same example, and uses a cmake script in order to simplify the usage.

*Details*

* The main [CMakeLists](../examples/vcpkg_android_example_cmake_script/CMakeLists.txt) loads [vcpkg_android.cmake](../examples/vcpkg_android_example_cmake_script/cmake/vcpkg_android.cmake) if the flag `VCPKG_TARGET_ANDROID` is set:
````cmake
if (VCPKG_TARGET_ANDROID)
    include("cmake/vcpkg_android.cmake")
endif()
````
*Important: place these lines before calling project() !*

* The [compile.sh](../examples/vcpkg_android_example_cmake_script/compile.sh) script shows that it is then possible to compile for android using a simple cmake invocation, for example:
````bash
cmake .. -DVCPKG_TARGET_ANDROID=ON -DANDROID_ABI=armeabi-v7a
````

## Consume libraries using vpckg, and Android prefab Archives (AAR files)

See [prefab.md](../specifications/prefab.md)