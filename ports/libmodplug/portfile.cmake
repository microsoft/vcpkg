vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Konstanty/libmodplug
    REF "v${VERSION}" # cf. https://github.com/Konstanty/libmodplug/issues/48
    SHA512 182270922d79c66c113b0bcd6acc45114606f5fc7421887ea23fd03c832bbf2a35f535ac7b8799782012a31ae230e3b99f53672353fe2b7553e4c197e042744e
    PATCHES
        002-detect_sinf.patch
        003-use-static-cast-for-ctype.patch
        004-export-pkgconfig.patch
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
