vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO dbus-cxx/dbus-cxx
    REF "${VERSION}"
    SHA512 6a0635a564a5172a975560d555e32c727727c48f61d172c75fee29b5f2d9d9caa561e2db5c0e8384325d4511f3f1bf19ad88e39cefbebca029d7ec8d947464ca
    HEAD_REF master
    PATCHES
        fix-cmake.patch
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
