vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO recp/cglm
    REF "v${VERSION}"
    SHA512 34796bd13dbc158f4f0f5e14092297bf31065901f11e483a58feebf95c0a0d627106e67b7de78ec911df58e58aa3b7c78e67f56f09a0fad77c5583398b4d812a
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" CGLM_BUILD_SHARED)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" CGLM_BUILD_STATIC)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DCGLM_SHARED=${CGLM_BUILD_SHARED}"
        "-DCGLM_STATIC=${CGLM_BUILD_STATIC}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/cglm")
vcpkg_fixup_pkgconfig()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
