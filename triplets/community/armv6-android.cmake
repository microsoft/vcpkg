set(VCPKG_TARGET_ARCHITECTURE arm)
set(VCPKG_CRT_LINKAGE static)
set(VCPKG_LIBRARY_LINKAGE static)
set(VCPKG_CMAKE_SYSTEM_NAME Android)
# If you need to specify the ANDROID_NATIVE_API_LEVEL,
# please use the overlay triplet and set the value below
set(ENV{VCPKG_ANDROID_NATIVE_API_LEVEL} "detect")
