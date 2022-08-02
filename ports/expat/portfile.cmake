set(EX_VERSION 2.4.8)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libexpat/libexpat
    REF 3bab6c09bbe8bf42d84b81563ddbcf4cca4be838 #v2.4.8
    SHA512 6bddf6514183b3bfa6bf869e63cf838cfe2912941ef04543bce00bee84a305f494368fb7cbd80404d06877a1d8da82de5ac2b44074b25e34aeaee7949d37e451
    HEAD_REF master
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

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/expat-${EX_VERSION}")
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
