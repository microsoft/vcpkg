if (VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
    if (VCPKG_TARGET_IS_WINDOWS)
        vcpkg_download_distfile(ARCHIVE
            URLS "https://naif.jpl.nasa.gov/pub/naif/toolkit/C/PC_Windows_VisualC_32bit/packages/cspice.zip"
            FILENAME "cspice_32bit.zip"
            SHA512 4f6129b26543729f4eb4f8240b43ca87530db9c6d9a5c0e3f43faf30561eaad95dcf507e3fecfd1c3d4388ccaa4e22a76df7bf7945b6ce9a68eb3b4893885992
        )
    elseif (VCPKG_TARGET_IS_OSX)
        vcpkg_download_distfile(ARCHIVE
            URLS "https://naif.jpl.nasa.gov/pub/naif/toolkit//C/MacIntel_OSX_AppleC_32bit/packages/cspice.tar.Z"
            FILENAME "cspice_32bit.tar.Z"
            SHA512 bd5cc20206e48b3712c5077a2beb05c98cd58a25ce374ed363699a04998eb8ba93e42b5f7c2104c5296db95b3bccdc7cc9b6a2ba45875454d0c3914834aa4c42
        )
    else ()
        vcpkg_download_distfile(ARCHIVE
            URLS "https://naif.jpl.nasa.gov/pub/naif/toolkit/C/PC_Linux_GCC_32bit/packages/cspice.tar.Z"
            FILENAME "cspice_32bit.tar.Z"
            SHA512 b387bc2cfca4deccc451d198af49564ea0b19cf665ba143d39196ed532639cbc11aad7e1d63f71f1bb88d72c0e6ac30757b6e1babca9e0ee3b92f9c205c1b908
        )
    endif()
else()
    if (VCPKG_TARGET_IS_WINDOWS)
        vcpkg_download_distfile(ARCHIVE
            URLS "https://naif.jpl.nasa.gov/pub/naif/toolkit/C/PC_Windows_VisualC_64bit/packages/cspice.zip"
            FILENAME "cspice_64bit.zip"
            SHA512 7b5353c638fdba67ed2e9fd21c4f78ac56c0afba408caa70f910f23bb025f6dc822fbaa7d6d7fa277d1038f835e6a962563f4b11a6adf63150d48354959e3c62
        )
    elseif (VCPKG_TARGET_IS_OSX)
        vcpkg_download_distfile(ARCHIVE
            URLS "https://naif.jpl.nasa.gov/pub/naif/toolkit//C/MacIntel_OSX_AppleC_64bit/packages/cspice.tar.Z"
            FILENAME "cspice_64bit.tar.Z"
            SHA512 0d4ef95dfa65d127c1d6f9cf1f637d41ca6680660ee3003f357652f12ed9d04a21888ef796f347ba90354a445b5aea9ffca7dedc6c1617f253b0002683d54a0f
        )
    else ()
        vcpkg_download_distfile(ARCHIVE
            URLS "https://naif.jpl.nasa.gov/pub/naif/toolkit/C/PC_Linux_GCC_64bit/packages/cspice.tar.Z"
            FILENAME "cspice_64bit.tar.Z"
            SHA512 7d090e9196596436740b53180a7c6ca885c12e301771a83fc62d625a63691129c69012cb0385a6c8f246cc5edf1c1af57ffac8a9d766061e1bde8584c57c6ca4
        )
    endif()
endif()

set(PATCHES isatty.patch)
if (NOT VCPKG_TARGET_IS_WINDOWS)
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

if (VCPKG_TARGET_IS_UWP)
    set(VCPKG_C_FLAGS "/sdl- ${VCPKG_C_FLAGS}")
    set(VCPKG_CXX_FLAGS "/sdl- ${VCPKG_CXX_FLAGS}")
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
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}
    RENAME copyright
)
