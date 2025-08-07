vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO goToMain/libosdp
    REF "v${VERSION}"
    SHA512 ebfc2010a89eb1bca9c47c283016750805f38bd5996d478105782bc54add184d0aa7e0f1b8b2f145e6b3af9584c0635522af6191167eeade88a4d878a0552fa0
    HEAD_REF master
)

# Download and extract the c-utils submodule at ${SOURCE_PATH}/utils as
# it would be during a recursive checkout.
#
# Note: During package upgrade, the submodule ref needs to be updated.
vcpkg_from_github(
    OUT_SOURCE_PATH UTILS_SOURCE_PATH
    REPO goToMain/c-utils
    REF "d295048d0362674e2a4b489b689d029b8f1f3d01"
    SHA512 a0902a504fe6ffd1ce0f32d0a16decf0e113d1211d19e63f4fb539082254769f0a6484414a49f52956e45ed802b2c2f8430e87a06c24ac84205421cdffb4d3f0
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
        -DCONFIG_OSDP_LIB_ONLY=ON
        -DCONFIG_BUILD_SHARED=${BUILD_SHARED}
        -DCONFIG_BUILD_STATIC=${BUILD_STATIC}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/libosdp)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
