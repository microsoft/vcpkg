string(REPLACE "." "_" REF "R_${VERSION}")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libexpat/libexpat
    REF "${REF}"
    SHA512 773703165d51170485503e54be47d56cbf19cb7383cb3daf5e5b5d7e2671ec7a9f2f9b4d26c85edd07c36eba9f7e7d02c1d7d178481695abdc35e3a69a67c07e
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" EXPAT_LINKAGE)
string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" EXPAT_CRT_LINKAGE)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/expat"
    OPTIONS
        -DEXPAT_BUILD_EXAMPLES=OFF
        -DEXPAT_BUILD_TESTS=OFF
        -DEXPAT_BUILD_TOOLS=OFF
        -DEXPAT_BUILD_DOCS=OFF
        -DEXPAT_SHARED_LIBS=${EXPAT_LINKAGE}
        -DEXPAT_MSVC_STATIC_CRT=${EXPAT_CRT_LINKAGE}
        -DEXPAT_BUILD_PKGCONFIG=ON
    MAYBE_UNUSED_VARIABLES EXPAT_MSVC_STATIC_CRT
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
