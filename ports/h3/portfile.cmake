vcpkg_fail_port_install(ON_TARGET "UWP")
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO uber/h3
    REF 26a6409156ba8539b2b332f799486572f1f8bab2 #v3.6.3
    SHA512 ee3450a5720951254fcdd9bb3acc4b33ed4a58c214e1ed8a091791674b57f0a48de76f0483b31b0b2ad9c316af6a5fcb0c3b72428b8f6380d6b6f717aaed73d7
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DBUILD_BENCHMARKS=OFF
        -DBUILD_FILTERS=OFF
        -DBUILD_GENERATORS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin" "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)