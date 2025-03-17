vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO electronicarts/EABase
    REF 123363eb82e132c0181ac53e43226d8ee76dea12
    SHA512 8df5279d1b303047e832b8b0ddb6cdf51cca753efaeb2a36f7fa5ebc015c2f37cc6a68184b919deb45f09dfd89f9f8f79f18c487817d231f1b049102ceae610f
    HEAD_REF master
    PATCHES
    fix_cmake_install.patch
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/EABaseConfig.cmake.in" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
    -DEABASE_BUILD_TESTS:BOOL=OFF
)
vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/EABase)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_copy_pdbs()

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
