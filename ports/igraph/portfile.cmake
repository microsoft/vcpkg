
# We use the release tarball from GitHub instead of the sources in the repo because:
#  - igraph will not compile from the git sources unless there is an actual git repository to back it. This is because it detects the version from git tags. The release tarball has the version hard-coded.
#  - The release tarball contains pre-generated parser sources, which eliminates the dependency on bison/flex.

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/igraph/igraph/releases/download/${VERSION}/igraph-${VERSION}.tar.gz"
    FILENAME "igraph-${VERSION}.tar.gz"
    SHA512 821a8ef3fa4d4049d0ca09fa54e0824b3b31ce2c3329cca902899a8fd2441ad4e106ea9c65e7ad8ef643c906e7b5f4d276b670f0fdbf80c8e6c473cf6536bc96
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    PATCHES
      "glpk-uwp.patch" # patch GLPK for UWP compatibility
      "constant-nan.patch" # Workaround https://developercommunity.visualstudio.com/t/NAN-is-no-longer-compile-time-constant-i/10688907
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        graphml         IGRAPH_GRAPHML_SUPPORT
        openmp          IGRAPH_OPENMP_SUPPORT
)

# Allow cross-compilation. See https://igraph.org/c/html/latest/igraph-Installation.html#igraph-Installation-cross-compiling
set(ARITH_H "")
if (VCPKG_TARGET_IS_OSX)
    set(ARITH_H ${CURRENT_PORT_DIR}/arith_osx.h)
elseif (VCPKG_TARGET_IS_WINDOWS OR VCPKG_TARGET_IS_UWP)
    if (VCPKG_TARGET_ARCHITECTURE STREQUAL "x86" OR VCPKG_TARGET_ARCHITECTURE STREQUAL "arm")
        set(ARITH_H ${CURRENT_PORT_DIR}/arith_win32.h)
    elseif (VCPKG_TARGET_ARCHITECTURE STREQUAL "x64" OR VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
        set(ARITH_H ${CURRENT_PORT_DIR}/arith_win64.h)
    endif()
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DIGRAPH_ENABLE_LTO=AUTO
        # ARPACK not yet available in vcpkg.
        -DIGRAPH_USE_INTERNAL_ARPACK=ON
        # GLPK is not yet available in vcpkg.
        -DIGRAPH_USE_INTERNAL_GLPK=ON
        # Currently, external GMP provides no performance or functionality benefits.
        -DIGRAPH_USE_INTERNAL_GMP=ON
        # PLFIT is not yet available in vcpkg.
        -DIGRAPH_USE_INTERNAL_PLFIT=ON
        # Use BLAS and LAPACK from vcpkg
        -DIGRAPH_USE_INTERNAL_BLAS=OFF
        -DIGRAPH_USE_INTERNAL_LAPACK=OFF
        -DF2C_EXTERNAL_ARITH_HEADER=${ARITH_H}
        -DIGRAPH_WARNINGS_AS_ERRORS=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/igraph)

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

vcpkg_fixup_pkgconfig()
