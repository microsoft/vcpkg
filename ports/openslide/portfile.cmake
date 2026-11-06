vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO openslide/openslide
    REF "v${VERSION}" 
    SHA512 52e6fc203d5ba81f332925aace61b29caacb430f9a09455392dfddd084d91994e85326c469e94769050695b47781c6aeaf06136bf8124cef5f9b92d60f5d8509
    HEAD_REF main
    PATCHES
        cross-build.diff
        slidetool-test-deps.diff
)
if(VCPKG_CROSSCOMPILING)
    file(COPY 
        "${CURRENT_HOST_INSTALLED_DIR}/share/${PORT}/${VERSION}/openslide-tables.c"
        DESTINATION "${SOURCE_PATH}"
    )
endif()

vcpkg_cmake_get_vars(cmake_vars_file)
include("${cmake_vars_file}")
if(VCPKG_DETECTED_CMAKE_C_COMPILER_ID STREQUAL "MSVC")
    message(FATAL_ERROR "MSVC is not supported; use clang-cl")
endif()

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS "-Dtest=disabled"
)
vcpkg_install_meson()
vcpkg_fixup_pkgconfig()

vcpkg_copy_tools(
    TOOL_NAMES
        openslide-quickhash1sum
        openslide-show-properties
        openslide-write-png
        slidetool
    AUTO_CLEAN
)

if(NOT VCPKG_CROSSCOMPILING)
    file(COPY 
        "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/src/openslide-tables.c"
        DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}/${VERSION}"
    )
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING.LESSER")
