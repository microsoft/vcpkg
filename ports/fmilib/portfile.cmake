vcpkg_minimum_required(VERSION 2022-10-12) # for ${VERSION}

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_download_distfile(ARCHIVE
    URLS "https://jmodelica.org/fmil/FMILibrary-${VERSION}-src.zip"
    FILENAME "FMILibrary-${VERSION}-src.zip"
    SHA512 86e4b5019d8f2a76b01141411845d977fb3949617604de0b34351f23647e3e8b378477de184e1c4f2f59297bc4c7de3155e0edba9099b8924594a36b37b04cc8
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
        0001-remove-install-prefix.patch
        0002-include-sys-stat.h-for-mkdir.patch
        0003-export-targets.patch
)

# Note that if you have configured and built both static and shared library on Windows
# but want to link with the static library compile time define "FMILIB_BUILDING_LIBRARY" must be set.
if ((NOT VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore") AND VCPKG_LIBRARY_LINKAGE STREQUAL static)
    SET(FMILIB_BUILDING_LIBRARY ON)
else()
    SET(FMILIB_BUILDING_LIBRARY OFF)
endif()

# Use static run-time libraries (/MT or /MTd code generation flags)
# This is only used when generating Microsoft Visual Studio solutions. If the options is on then the library will
# be built against static runtime, otherwise - dynamic runtime (/MD or /MDd). Make sure the client code is using
# matching runtime
if ((NOT VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore") AND VCPKG_CRT_LINKAGE STREQUAL static)
    SET(FMILIB_BUILD_WITH_STATIC_RTLIB ON)
else()
    SET(FMILIB_BUILD_WITH_STATIC_RTLIB OFF)
endif()

# On LINUX position independent code (-fPIC) must be used on all files to be linked into a shared library (.so file).
# On other systems this is not needed (either is default or relocation is done). Set this option to OFF if you
# are building an application on Linux and use static library only
if ((VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Linux" OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Darwin") AND VCPKG_LIBRARY_LINKAGE STREQUAL static)
    SET(FMILIB_BUILD_FOR_SHARED_LIBS OFF)
else()
    SET(FMILIB_BUILD_FOR_SHARED_LIBS ON)
endif()

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DFMILIB_BUILD_TESTS=OFF
        -DFMILIB_BUILD_STATIC_LIB=${BUILD_STATIC}
        -DFMILIB_BUILD_SHARED_LIB=${BUILD_SHARED}
        -DFMILIB_BUILDING_LIBRARY=${FMILIB_BUILDING_LIBRARY}
        -DFMILIB_BUILD_WITH_STATIC_RTLIB=${FMILIB_BUILD_WITH_STATIC_RTLIB}
    MAYBE_UNUSED_VARIABLES
        FMILIB_BUILDING_LIBRARY
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-fmilib)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
