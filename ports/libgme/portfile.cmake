vcpkg_from_bitbucket(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mpyne/game-music-emu
    REF "${VERSION}"
    SHA512 3d5e0dafb7ba239fb1c4cebf47c7e195a350bfe7a43606deff1ecff1ab21a0aac47343205004c0aba06ae249a0e186122c1b7dec06fc52272d4baaea9a480796
    PATCHES
        disable-player-and-demo.patch
        disable-static-zlib-hack.patch
)

# This file is generated during the CMake build
file(REMOVE "${SOURCE_PATH}/gme/gme_types.h")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        ay      USE_GME_AY
        gbs     USE_GME_GBS
        gym     USE_GME_GYM
        hes     USE_GME_HES
        kss     USE_GME_KSS
        nsf     USE_GME_NSF
        nsfe    USE_GME_NSFE
        sap     USE_GME_SAP
        spc     USE_GME_SPC
        vgm     USE_GME_VGM
        spc-isolated-echo-buffer    GME_SPC_ISOLATED_ECHO_BUFFER
)

set(CMAKE_DISABLE_FIND_PACKAGE_ZLIB ON)
set(CMAKE_REQUIRE_FIND_PACKAGE_ZLIB OFF)
if("vgm" IN_LIST FEATURES)
    set(CMAKE_DISABLE_FIND_PACKAGE_ZLIB OFF)
    set(CMAKE_REQUIRE_FIND_PACKAGE_ZLIB ON)
endif()

if("vgm" IN_LIST FEATURES OR "gym" IN_LIST FEATURES)
    set(GME_YM2612_EMU Nuked)
    message(STATUS "This version of libgme uses the Nuked YM2612 emulator. To use the MAME or GENS instead, create an overlay port of this with GME_YM2612_EMU set to \"MAME\" or \"GENS\" accordingly.")
    message(STATUS "This recipe is at ${CMAKE_CURRENT_LIST_DIR}")
    message(STATUS "See the overlay ports documentation at https://github.com/microsoft/vcpkg/blob/master/docs/specifications/ports-overlay.md")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DGME_YM2612_EMU=${GME_YM2612_EMU}
        -DCMAKE_DISABLE_FIND_PACKAGE_ZLIB=${CMAKE_DISABLE_FIND_PACKAGE_ZLIB}
        -DCMAKE_REQUIRE_FIND_PACKAGE_ZLIB=${CMAKE_REQUIRE_FIND_PACKAGE_ZLIB}
        -DENABLE_UBSAN=OFF
    MAYBE_UNUSED_VARIABLES
        GME_YM2612_EMU
        GME_SPC_ISOLATED_ECHO_BUFFER
)

vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE 
    "${CURRENT_PACKAGES_DIR}/debug/include"
)

file(GLOB LICENSE_FILES "${SOURCE_PATH}/license*")
vcpkg_install_copyright(FILE_LIST ${LICENSE_FILES})
