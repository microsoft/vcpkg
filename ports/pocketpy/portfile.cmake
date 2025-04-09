vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pocketpy/pocketpy
    REF "v${VERSION}"
    SHA512 6c9872c4a402bc702e577067c05d593034f45f150ebbf033ef204b4c7deff6cd2da0f9db44e0bb37aefdeb7a4d99e5a9c4a93ece57316f561c5bf4cd33cd12e3
    HEAD_REF master
    PATCHES
        fix-conflict.patch
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
