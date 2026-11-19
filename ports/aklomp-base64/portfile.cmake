vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO aklomp/base64
    REF "v${VERSION}"
    SHA512 577ebae6ebf385b1d1241d8927f407ded229ac2df7a05bb36f30c20f9873bfcdd07bc8d1e74ca3b10b2f74cf27113f135de0d4962bb8da270017e50e0338da27
    HEAD_REF master
    PATCHES
        version.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBASE64_BUILD_CLI=OFF
        -DBASE64_REGENERATE_TABLES=OFF
        -DBASE64_WERROR=OFF
        -DBASE64_WITH_OpenMP=OFF
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/libbase64.h" "#if defined(BASE64_STATIC_DEFINE)" "#if 1")
else()
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/libbase64.h" "#if defined(BASE64_STATIC_DEFINE)" "#if 0")
endif()

vcpkg_cmake_config_fixup(
	PACKAGE_NAME base64
	CONFIG_PATH "lib/cmake/base64"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
