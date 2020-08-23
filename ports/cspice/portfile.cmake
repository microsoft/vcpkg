include(vcpkg_common_functions)

if (VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(FATAL_ERROR "${PORT} does not currently support UWP")
endif()

if (WIN32)
    vcpkg_download_distfile(ARCHIVE
        URLS "https://naif.jpl.nasa.gov/pub/naif/toolkit/C/PC_Windows_VisualC_32bit/packages/cspice.zip"
        FILENAME "cspice.zip"
        SHA512 4f6129b26543729f4eb4f8240b43ca87530db9c6d9a5c0e3f43faf30561eaad95dcf507e3fecfd1c3d4388ccaa4e22a76df7bf7945b6ce9a68eb3b4893885992
    )
elseif (APPLE)
    vcpkg_download_distfile(ARCHIVE
        URLS "https://naif.jpl.nasa.gov/pub/naif/toolkit//C/MacIntel_OSX_AppleC_32bit/packages/cspice.tar.Z"
        FILENAME "cspice.tar.Z"
        SHA512 bd5cc20206e48b3712c5077a2beb05c98cd58a25ce374ed363699a04998eb8ba93e42b5f7c2104c5296db95b3bccdc7cc9b6a2ba45875454d0c3914834aa4c42
    )
else ()
    vcpkg_download_distfile(ARCHIVE
        URLS "https://naif.jpl.nasa.gov/pub/naif/toolkit/C/PC_Linux_GCC_32bit/packages/cspice.tar.Z"
        FILENAME "cspice.tar.Z"
        SHA512 b387bc2cfca4deccc451d198af49564ea0b19cf665ba143d39196ed532639cbc11aad7e1d63f71f1bb88d72c0e6ac30757b6e1babca9e0ee3b92f9c205c1b908
    )
endif()

set(PATCHES isatty.patch)
if (NOT WIN32)
    set(PATCHES ${PATCHES} mktemp.patch)
endif()

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    NO_REMOVE_ONE_LEVEL
    PATCHES ${PATCHES}
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    set(_STATIC_BUILD ON)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -D_STATIC_BUILD=${_STATIC_BUILD}
    OPTIONS_DEBUG -D_SKIP_HEADERS=ON
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

file(
    INSTALL ${CMAKE_CURRENT_LIST_DIR}/License.txt
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/cspice
    RENAME copyright
)
