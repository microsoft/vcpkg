vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO  VcDevel/Vc
    REF 1.4.3
    SHA512 7c0c4ccf8c7c4585334482135f2daf1a5bc088114b880093893583bdcea1fbfcec02485da6059304c510c8b1bb1b768ef04fd7ac8ccb21b9ebbad5d0d5babaef
    HEAD_REF 1.4
    PATCHES 
       correct_cmake_config_path.patch
       Fix-internal-func-export.patch #remove it in next version
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        -DBUILD_EXAMPLES=OFF
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/Vc/")
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
