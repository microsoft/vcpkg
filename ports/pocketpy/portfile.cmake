vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pocketpy/pocketpy
    REF "v${VERSION}"
    SHA512 e0c4b70727d47ae0b26c520528ffadfe63a8986b674f12b91260f42ae25975af4f64dfd71e056e7627d35b10eddcd34b396ca3b01c931f5bb8a4b15431da5426
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DPK_BUILD_SHARED_LIB=${BUILD_SHARED}
        -DPK_BUILD_STATIC_LIB=${BUILD_STATIC}
        -DPK_ENABLE_OS=OFF
        -DPK_USE_CJSON=OFF
        -DPK_INSTALL=ON
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE 
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
