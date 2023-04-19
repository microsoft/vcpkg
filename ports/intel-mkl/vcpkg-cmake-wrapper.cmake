set(MKL_THREADING "@threading@")
if("@VCPKG_TARGET_ARCHITECTURE@" STREQUAL "x64")
    set(MKL_INTERFACE "@interface@")
endif()

_find_package(${ARGS})