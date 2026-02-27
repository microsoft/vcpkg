vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO DAarno/tclap
    REF "${VERSION}"
    SHA512 e698e5a973f48cafce03f2b9dd41b9f507a7a728fbd35050b4aaedc80b39ff898bb7ca515f8a054f39b5277d29c430e238015ed4fd97ae2f40c194269036a83c
    PATCHES
        disable-test.patch 
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/tclap")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include"
                    "${CURRENT_PACKAGES_DIR}/debug/share"
)

file(COPY "${SOURCE_PATH}/include/tclap" DESTINATION "${CURRENT_PACKAGES_DIR}/include" FILES_MATCHING PATTERN "*.h")

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
