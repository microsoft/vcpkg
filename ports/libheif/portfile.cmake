vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO  strukturag/libheif 
    REF 56c8a2613370562fc330af2c70c1510aa5fd9ff6 #v1.12.0
    SHA512 11ac7f32d1f49963046b1a4479a41f39004475211563ba7f41b2398f07f7b4d90339ea663e528b3cc80deeef1fff374987208d48b447116a806564ef05487e97
    HEAD_REF master
    PATCHES
        gdk-pixbuf.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DWITH_EXAMPLES=OFF
        -DWITH_DAV1D=OFF
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/libheif/)
# libheif's pc file assumes libstdc++, which isn't always true.
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/libheif.pc" " -lstdc++" "")
if(NOT VCPKG_BUILD_TYPE)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libheif.pc" " -lstdc++" "")
endif()
vcpkg_fixup_pkgconfig()

if (VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/libheif/heif.h" "defined(_MSC_VER) && !defined(LIBHEIF_STATIC_BUILD)" "defined(_WIN32)")
else()
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/libheif/heif.h" "defined(_MSC_VER) && !defined(LIBHEIF_STATIC_BUILD)" "0")
endif()
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/libheif/heif.h" "#ifdef LIBHEIF_EXPORTS" "#if 0")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
