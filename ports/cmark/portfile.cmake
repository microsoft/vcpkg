vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO commonmark/cmark
    REF "${VERSION}"
    SHA512 8dcf4f25b53e84a16afa506214f17c3d2d7b0cc78d9d289b469ad8d1e481c4b355263eca3fb1e2b595c30734bc2d617fd38e00d17a14dcfa9de8c71580916265
    HEAD_REF master
    PATCHES
        add-feature-tools.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" CMARK_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" CMARK_SHARED)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tools BUILD_TOOLS
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        ${FEATURE_OPTIONS}
        -DBUILD_TESTING=OFF
        -DCMARK_SHARED=${CMARK_SHARED}
        -DCMARK_STATIC=${CMARK_STATIC}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/cmark)

vcpkg_fixup_pkgconfig()

if ("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES cmark SEARCH_DIR "${CURRENT_PACKAGES_DIR}/tools/cmark" AUTO_CLEAN)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
