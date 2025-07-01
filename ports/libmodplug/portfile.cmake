vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Konstanty/libmodplug
    REF 5a39f5913d07ba3e61d8d5afdba00b70165da81d # cf. https://github.com/Konstanty/libmodplug/issues/48
    SHA512 c43bb3190b62c3a4e3636bba121b5593bbf8e6577ca9f2aa04d90b03730ea7fb590e640cdadeb565758b92e81187bc456e693fe37f1f4deace9b9f37556e3ba1
    PATCHES
        002-detect_sinf.patch
        003-use-static-cast-for-ctype.patch
        004-export-pkgconfig.patch
        005-fix-install-paths.patch # https://github.com/Konstanty/libmodplug/pull/61
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCMAKE_CXX_STANDARD=11
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/libmodplug/modplug.h" "defined(MODPLUG_STATIC)" "1")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/libmodplug/stdafx.h" "defined(MODPLUG_STATIC)" "1")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
