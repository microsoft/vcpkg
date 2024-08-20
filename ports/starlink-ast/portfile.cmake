if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/Starlink/ast/releases/download/v${VERSION}/ast-${VERSION}.tar.gz"
    FILENAME "starlink-ast-${VERSION}.tar.gz"
    SHA512 b559535496b88b33845bd3732bb6ee80572dc0d8d963173e0199d44be09add244244d9aab90642de84c65714bca6c73b5bdc3b3290a55f171e6f3ce7643250f5
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
        cminpack.diff
)
file(REMOVE_RECURSE "${SOURCE_PATH}/cminpack")

set(CONFIGURE_OPTIONS
    --without-fortran
    --with-external-cminpack
    "--with-starlink=${CURRENT_INSTALLED_DIR}"
    FC=false
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
    OPTIONS_DEBUG
        CMINPACK_DEBUG_SUFFIX=_d
)
vcpkg_install_make(
    OPTIONS
        STAR_LDFLAGS= # Do not override build type's lib dirs
)

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

# Remove cl preprocessing comments
foreach(file IN ITEMS "include/ast.h" "include/star/ast.h")
    file(READ "${CURRENT_PACKAGES_DIR}/${file}" cpp_output)
    string(REGEX REPLACE "#line [^ ]+ \"[^\"]*\"" "" cpp_output "${cpp_output}")
    file(WRITE "${CURRENT_PACKAGES_DIR}/${file}" "${cpp_output}")
endforeach()

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
