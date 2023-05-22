# There is no 9.2.10 tarball with generated `configure`.
# Reconfiguration needs a custom starlink autoconf.
# Cf. https://github.com/Starlink/ast/issues/21
vcpkg_download_distfile(ARCHIVE
    # regular: "https://github.com/Starlink/ast/releases/download/v${VERSION}/ast-${VERSION}.tar.gz"
    URLS "https://github.com/Starlink/ast/files/8843897/ast-9.2.9.tar.gz" # not a release asset or tarball
    FILENAME "starlink-ast-${VERSION}.tar.gz"
    SHA512 af19cdf41e20d9e92850d90ea760bd21bc9a53ca5bb181a6e27322a610fd13cd6cef30aaf8de6193a2c3fe3c66428b3bd46492a6b22ac22f18cd9be712aa357b
)
vcpkg_download_distfile(UPDATE_DIFF
    URLS "https://github.com/Starlink/ast/compare/v9.2.9...v${VERSION}.diff"
    FILENAME "starlink-ast-v9.2.9...v${VERSION}.diff"
    SHA512 fd1255eaefcfdb57273ba241fc604e3ab5eabd2212c17f10daac8fd23436f6d50272bfa35bac292097441ff5334e3d28d12ea6d7d90838f6058e05fc7067c966
)
file(READ "${UPDATE_DIFF}" diff)
set(files_to_ignore "(configure\\.ac|Makefile|\\.gitignore|component\\.xml)")
string(REGEX REPLACE "diff --git a/${files_to_ignore}[^\n]*\n([-+@ i][^\n]*\n)*" "" diff "${diff}")
file(WRITE "${CURRENT_BUILDTREES_DIR}/update-${VERSION}.diff" "${diff}")

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
        cminpack.diff
        "${CURRENT_BUILDTREES_DIR}/update-${VERSION}.diff"
)
file(REMOVE_RECURSE "${SOURCE_PATH}/cminpack")
vcpkg_replace_string("${SOURCE_PATH}/configure" "9.2.9" "9.2.10")

set(CONFIGURE_OPTIONS
    --without-fortran
    --with-external-cminpack
)

if ("yaml" IN_LIST FEATURES)
    list(APPEND CONFIGURE_OPTIONS --with-yaml)
else()
    list(APPEND CONFIGURE_OPTIONS --without-yaml)
endif()

if ("pthreads" IN_LIST FEATURES)
    list(APPEND CONFIGURE_OPTIONS --with-pthreads)
else()
    list(APPEND CONFIGURE_OPTIONS --without-pthreads)
endif()

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    USE_WRAPPERS
    DETERMINE_BUILD_TRIPLET
    ADDITIONAL_MSYS_PACKAGES perl
    OPTIONS
        ${CONFIGURE_OPTIONS}
)
vcpkg_install_make()

# Avoid vcpkg artifact issues with symlinks
foreach(ast_lib IN ITEMS "${CURRENT_PACKAGES_DIR}/lib/libast" "${CURRENT_PACKAGES_DIR}/debug/lib/libast")
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static" AND EXISTS "${ast_lib}${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX}")
        file(REMOVE "${ast_lib}_pass2${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX}")
        file(COPY_FILE "${ast_lib}${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX}" "${ast_lib}_pass2${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX}")
    endif()
endforeach()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/docs"
    "${CURRENT_PACKAGES_DIR}/debug/help"
    "${CURRENT_PACKAGES_DIR}/debug/manifests"
    "${CURRENT_PACKAGES_DIR}/debug/news"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/docs"
    "${CURRENT_PACKAGES_DIR}/help"
    "${CURRENT_PACKAGES_DIR}/manifests"
    "${CURRENT_PACKAGES_DIR}/news"
    "${CURRENT_PACKAGES_DIR}/share/${PORT}/ast"
)

vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/COPYING.LESSER"
        "${SOURCE_PATH}/COPYING"
        "${SOURCE_PATH}/erfa/LICENSE"
    COMMENT [[
AST is distributed under the Lesser GPL licence (LGPL).

The AST distribution includes a cut down subset of the C version of the SLALIB library written
by Pat Wallace. This subset contains only the functions needed by the AST library. It is built as
part of the process of building AST and is distributed under GPL.

The AST distribution includes the ERFA library. See LICENSE below.
]])
