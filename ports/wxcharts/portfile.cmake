vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO wxIshiko/wxCharts
    REF 979c3ab781b276c96c860db9fb8ecd72f25287f6
    SHA512 3bba60432f3b7f9e866731bef01ede9f19dbd4e0ff6aaecce761ff7d82de6cc55bcbfc51da770aeccd857e41453c075d15fd7ea906092fe370dca643f5c313cb
    PATCHES support-cmake-and-dll.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)