vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO recp/cglm
    REF "v${VERSION}"
    SHA512 5493b9c19a9aae556e579f41687d8e7184aa0b03d4c5358975521102fe8dbb456493f858512564b2c30093bbd2ea801f0280592a54cc5454045fcac762e71eaf
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
