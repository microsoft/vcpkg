vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO goToMain/libosdp
    REF "v${VERSION}"
    SHA512 5ce034ada2963e822a248bda6028ec0afd6f9be8dcb09653a33af6b72cae067ecdc99a477ece740af858c0601364246061a73eec4db0701ee9e6c4bd8ba2dc83
    HEAD_REF master
)

# Download and extract the c-utils submodule at ${SOURCE_PATH}/utils as
# it would be during a recursive checkout.
#
# Note: During package upgrade, the submodule ref needs to be updated.
vcpkg_from_github(
    OUT_SOURCE_PATH UTILS_SOURCE_PATH
    REPO goToMain/c-utils
    REF "d832ba52a9c610f7b2f2c932e2d9114a17cf99d2"
    SHA512 ec0815349bd5d481dac9a772f2c671b9e5c559b28c4041db03b2565cfb7e51c6b5ab3b5cf5ffc72484ace725ac01245eca57ceb495e02a7e6f47ae47407a0edd
    HEAD_REF master
)

file(REMOVE_RECURSE "${SOURCE_PATH}/utils")
file(COPY "${UTILS_SOURCE_PATH}/" DESTINATION "${SOURCE_PATH}/utils")

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC)

# Main commands
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DOPT_OSDP_LIB_ONLY=ON
        -DOPT_BUILD_SHARED=${BUILD_SHARED}
        -DOPT_BUILD_STATIC=${BUILD_STATIC}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/libosdp)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
