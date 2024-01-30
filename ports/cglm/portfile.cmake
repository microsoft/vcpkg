vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO recp/cglm
    REF "v${VERSION}"
    SHA512 d5de879b2510f534dbc82c88b6f4f324088468af7218a635aff08cc3327787f95b0dc896816b9610e5a319cd071bf2443923d3c1d426fd58509f39867d684e5f
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
