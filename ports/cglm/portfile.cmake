vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO recp/cglm
    REF "v${VERSION}"
    SHA512 cfa836d5100912866d0678babca51e0ca818c1424ac8320c49ee55e5f9091403947a0d7b5c633bb0fb5df594d2b4fb01c2f634cc20cbe6266db5f7879488b02f
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

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
