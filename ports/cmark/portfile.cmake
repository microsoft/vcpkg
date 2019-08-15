include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO commonmark/cmark
    REF 0.29.0
    SHA512 06eb110cfd90c9e980c022b7588e28864d15a4da5d07d61ad4b27c6de47367492b9e58e9434e62b07517aa6dc484f17af13916808be3188f38c37d20cbf33112
    HEAD_REF master
    PATCHES
        "${CMAKE_CURRENT_LIST_DIR}/rename-shared-lib.patch"
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" CMARK_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" CMARK_SHARED)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DCMARK_TESTS=OFF
        -DCMARK_SHARED=${CMARK_SHARED}
        -DCMARK_STATIC=${CMARK_STATIC}
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake)

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/cmark RENAME copyright)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share)

if(EXISTS ${CURRENT_PACKAGES_DIR}/bin/cmark.exe)
    file(COPY ${CURRENT_PACKAGES_DIR}/bin/cmark.exe DESTINATION ${CURRENT_PACKAGES_DIR}/tools/cmark/)
    vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/cmark)
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static" AND NOT EXISTS ${CURRENT_PACKAGES_DIR}/bin/cmark)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
else()
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin/cmark.exe ${CURRENT_PACKAGES_DIR}/debug/bin/cmark.exe)
endif()
