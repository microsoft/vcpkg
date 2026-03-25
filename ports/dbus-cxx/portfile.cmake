vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO dbus-cxx/dbus-cxx
    REF "${VERSION}"
    SHA512 57e5fc8363faa72b7958e049f9d42006bb85792101713518f1d232097aacb9c6cb84c742ab5248cd5729969076d0ac70902f63e42a1e9eb6a16c58db31b09f1d
    HEAD_REF master
    PATCHES
        create-cmakeconfig.patch    
        use-cmakeconfig.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "glib"          ENABLE_GLIB_SUPPORT
        "libuv"         ENABLE_UV_SUPPORT
        "qt6"           ENABLE_QT_SUPPORT
)

if (EXISTS "${CURRENT_INSTALLED_DIR}/lib/pkgconfig/libuv-static.pc")
    set(UV_STATIC ON)
else ()
    set(UV_STATIC OFF)
endif ()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DBUILD_TESTING=OFF
        -DENABLE_CODE_COVERAGE_REPORT=OFF
        -DENABLE_EXAMPLES=OFF
        -DENABLE_TOOLS=OFF
        -DBUILD_SITE=OFF
        -DUV_STATIC=${UV_STATIC}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME "dbus-cxx" CONFIG_PATH "lib/cmake/dbus-cxx")
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
