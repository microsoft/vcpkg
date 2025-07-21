vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO openslide/openslide
    REF "v${VERSION}" 
    SHA512 98822994dd437f5a7d40e0a769fc9c63eda46823ede0547f530390b78b256631a50f66ac0d63d32a8875fc38283f96bc2f624f1023fe98772e9a89a8d6afb514
    HEAD_REF main
    PATCHES
        cross-build.diff
        fix-win-build.patch
        slidetool-unicode.patch
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
