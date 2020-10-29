vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lloyd/yajl
    REF 2.1.0
    SHA512 9e786d080803df80ec03a9c2f447501e6e8e433a6baf636824bc1d50ecf4f5f80d7dfb1d47958aeb0a30fe459bd0ef033d41bc6a79e1dc6e6b5eade930b19b02
    HEAD_REF master
    PATCHES ${CMAKE_CURRENT_LIST_DIR}/cmake.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/yajl RENAME copyright)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share ${CURRENT_PACKAGES_DIR}/share/pkgconfig)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
    file(GLOB SHAREDOBJECTS ${CURRENT_PACKAGES_DIR}/lib/libyajl.so* ${CURRENT_PACKAGES_DIR}/debug/lib/libyajl.so*)
    file(REMOVE_RECURSE ${SHAREDOBJECTS} ${CURRENT_PACKAGES_DIR}/lib/yajl.lib ${CURRENT_PACKAGES_DIR}/debug/lib/yajl.lib)
else()
    file(GLOB EXES ${CURRENT_PACKAGES_DIR}/bin/*.exe ${CURRENT_PACKAGES_DIR}/debug/bin/*.exe)
    file(REMOVE_RECURSE
        ${EXES}
        ${CURRENT_PACKAGES_DIR}/lib/yajl_s.lib ${CURRENT_PACKAGES_DIR}/debug/lib/yajl_s.lib
        ${CURRENT_PACKAGES_DIR}/lib/libyajl_s.a ${CURRENT_PACKAGES_DIR}/debug/lib/libyajl_s.a
    )
endif()
