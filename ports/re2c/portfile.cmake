vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO skvadrik/re2c
    REF "${VERSION}"
    SHA512 CB837B796D09F61E456F27FDCDB3CBFF804DDD85F7BAD1A5488769BED0467F7483F02E72B5F40FCD2DAA70DA9F9C48654E7DD9033C29DA715A0E1BDF1A6BAB09
    HEAD_REF master
)

set(BUILD_OPTIONS
    -DRE2C_BUILD_TESTS=OFF
    -DRE2C_BUILD_BENCHMARKS=OFF
    -DRE2C_REBUILD_DOCS=OFF
    -DRE2C_REBUILD_LEXERS=OFF
    -DRE2C_REBUILD_PARSERS=OFF
    -DRE2C_BUILD_LIBS=OFF
    # Disable building language-specific executables (re2go, re2rust, etc.)
    # as they are just aliases for the main re2c executable with --lang flag
    -DRE2C_BUILD_RE2D=OFF
    -DRE2C_BUILD_RE2GO=OFF
    -DRE2C_BUILD_RE2HS=OFF
    -DRE2C_BUILD_RE2JAVA=OFF
    -DRE2C_BUILD_RE2JS=OFF
    -DRE2C_BUILD_RE2OCAML=OFF
    -DRE2C_BUILD_RE2PY=OFF
    -DRE2C_BUILD_RE2RUST=OFF
    -DRE2C_BUILD_RE2SWIFT=OFF
    -DRE2C_BUILD_RE2V=OFF
    -DRE2C_BUILD_RE2ZIG=OFF
)

if(VCPKG_CROSSCOMPILING)
    # When cross-compiling, we need the host re2c tool to be available
    list(APPEND BUILD_OPTIONS
        -DRE2C_FOR_BUILD=${CURRENT_HOST_INSTALLED_DIR}/tools/re2c/re2c${VCPKG_HOST_EXECUTABLE_SUFFIX}
    )
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${BUILD_OPTIONS}
)

vcpkg_cmake_install()

# Install the re2c tool
vcpkg_copy_tools(TOOL_NAMES re2c AUTO_CLEAN)

# Fix pkgconfig files if they exist
vcpkg_fixup_pkgconfig()

# Remove duplicate files
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# re2c is a code generation tool, not a library
set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include")

# Install copyright/license
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

# Install usage
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
