vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ivmai/bdwgc
    REF v8.0.6
    SHA512 9e56a9b2cafa24465e40ae7b051948776ce03cf7b723553106934f5da17e61dade8bdea8ecac2851e3d1b77fbd52865ef29a8f19ca9188e0e33a65eeaf4526f3
    HEAD_REF master
    PATCHES
        001-install-libraries.patch 
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS 
        -Dbuild_tests=OFF
        -Dbuild_cord=OFF
    OPTIONS_DEBUG 
        -Dinstall_headers=OFF 
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

file(INSTALL "${SOURCE_PATH}/README.QUICK" DESTINATION "${CURRENT_PACKAGES_DIR}/share/bdwgc" RENAME copyright)
