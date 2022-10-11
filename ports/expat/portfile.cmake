file(READ ${CMAKE_CURRENT_LIST_DIR}/vcpkg.json vcpkg_json)
string(JSON VERSION GET "${vcpkg_json}" "version")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libexpat/libexpat
    REF R_2_4_9
    SHA512 6bf92516ce2642b2cdcbc586aaac0f706f125394fa428670f9b8b042a1f393e3b9dda1a24e58e6c8ad8b4ff3303cb5a8700628c6c04a881a06251c08be3759d3
    HEAD_REF master
    PATCHES
        "pkgconfig_fix.patch" # https://github.com/libexpat/libexpat/pull/656
        "mingw_static_fix.patch" # https://github.com/libexpat/libexpat/pull/658
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" EXPAT_LINKAGE)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/expat"
    OPTIONS
        -DEXPAT_BUILD_EXAMPLES=OFF
        -DEXPAT_BUILD_TESTS=OFF
        -DEXPAT_BUILD_TOOLS=OFF
        -DEXPAT_BUILD_DOCS=OFF
        -DEXPAT_SHARED_LIBS=${EXPAT_LINKAGE}
        -DEXPAT_BUILD_PKGCONFIG=ON
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/expat-${VERSION}")
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/doc")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/expat_external.h"
        "! defined(XML_STATIC)"
        "/* vcpkg static build ! defined(XML_STATIC) */ 0"
    )
endif()

vcpkg_copy_pdbs()

file(COPY "${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/expat/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
