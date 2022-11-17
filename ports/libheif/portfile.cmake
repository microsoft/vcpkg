vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO  strukturag/libheif 
    REF 5fb52b6134d5e034b51637a86c6e8a7418b35df1 #v1.13.0
    SHA512 e1ebd5eb7ae436a604ae3bb50ea4d53b8efb97388081a0876c161927a8b31c48c03899075423048d3f10055332bf7f3472bb8a06b6d32312de1d88fbda760421
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
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
