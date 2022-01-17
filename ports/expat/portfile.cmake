set (EX_VERSION 2.4.3)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libexpat/libexpat
    REF 57c7da69b78e3698e112a6b5da19d5109b8232d1 #v2.4.3
    SHA512 cb6915d8a0d79bca6ea1720a03033c95bda5df1906dfcbadea644a3f49bfe814ea0f21fc0d29c0d037f9f737598aa9cdb7058afaf9adf5066833fc4bcf51cd27
    HEAD_REF master
    PATCHES
        pkgconfig.patch
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(EXPAT_LINKAGE ON)
else()
    set(EXPAT_LINKAGE OFF)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/expat"
    OPTIONS
        -DEXPAT_BUILD_EXAMPLES=OFF
        -DEXPAT_BUILD_TESTS=OFF
        -DEXPAT_BUILD_TOOLS=OFF
        -DEXPAT_SHARED_LIBS=${EXPAT_LINKAGE}
        -DEXPAT_BUILD_PKGCONFIG=ON
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/expat-${EX_VERSION}")
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/include/expat_external.h
        "! defined(XML_STATIC)"
        "/* vcpkg static build ! defined(XML_STATIC) */ 0"
    )
endif()

vcpkg_copy_pdbs()

#Handle copyright
file(INSTALL "${SOURCE_PATH}/expat/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
