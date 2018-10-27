include(vcpkg_common_functions)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    # Note: fails due to missing cmark_export.h -- fix should be to always generate the correct export header.
    message(FATAL_ERROR "cmark does not currently support static library linkage")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO commonmark/cmark
    REF 0.28.3
    SHA512 409105a3228a8ae22ba6acf95cd99bc9a2c20f8603aa0e803a33172eb6ef53f80f8f0262d2258b77f9fd6e1f2e9017a6c906b88f761e053c09ef88c9ffab7d29
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
