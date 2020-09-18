vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libexpat/libexpat
    REF c092d40c300c6d219cb3b111932a824022265370 #Head from commit 2020-08-18
    SHA512 5a5d41b500f5602a32aea8f4e15593e639206bb3f97553497e80b2975360cac88ac90386f5efc11728614f24bbb620fb908a3c8ca71c9e7b312f6157b2477afe
    HEAD_REF master
    PATCHES
        pkgconfig.patch
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(EXPAT_LINKAGE ON)
else()
    set(EXPAT_LINKAGE OFF)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/expat
    PREFER_NINJA
    OPTIONS
        -DEXPAT_BUILD_EXAMPLES=OFF
        -DEXPAT_BUILD_TESTS=OFF
        -DEXPAT_BUILD_TOOLS=OFF
        -DEXPAT_SHARED_LIBS=${EXPAT_LINKAGE}
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/expat-2.2.9)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/include/expat_external.h
        "! defined(XML_STATIC)"
        "/* vcpkg static build ! defined(XML_STATIC) */ 0"
    )
endif()

vcpkg_copy_pdbs()

#Handle copyright
file(INSTALL ${SOURCE_PATH}/expat/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
