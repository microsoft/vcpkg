# Header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO beached/utf_range
    REF 105862ffe283e96ae514d4a6ec98d6ea16b25827 #v2.2.2
    SHA512 49772c7450ec432925b44ecddaee594ecec01afa4cc49db88e798347d6e5df51b7acf2bea7e11951b7de42a0a4d5a6c9046d5cb101a65e7da68b7d7242ad5b1c
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DDAW_USE_PACKAGE_MANAGEMENT=ON
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})

# remove empty lib and debug/lib directories (and duplicate files from debug/include)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/lib")

file(INSTALL "${SOURCE_PATH}/LICENSE.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
