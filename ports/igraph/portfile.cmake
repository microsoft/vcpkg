
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/igraph/igraph/releases/download/0.9.2/igraph-0.9.2.tar.gz"
    FILENAME "igraph-0.9.2.tar.gz"
    SHA512 8feb0c23c28e62f1e538fc41917e941f45421060b6240653ee03153b13551c454be019343a314b7913edb9c908518a131034c8e2098d9dd8e5c923fb84d195b3
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    # (Optional) A friendly name to use instead of the filename of the archive (e.g.: a version number or tag).
    # REF 1.0.0
    # (Optional) Read the docs for how to generate patches at:
    # https://github.com/Microsoft/vcpkg/blob/master/docs/examples/patching.md
    # PATCHES
    #   001_port_fixes.patch
    #   002_more_port_fixes.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
  FEATURES
    graphml   IGRAPH_GRAPHML_SUPPORT
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DIGRAPH_ENABLE_LTO=AUTO
        -DIGRAPH_USE_INTERNAL_ARPACK=ON
        -DIGRAPH_USE_INTERNAL_BLAS=ON
        -DIGRAPH_USE_INTERNAL_CXSPARSE=ON
        -DIGRAPH_USE_INTERNAL_GLPK=ON
        -DIGRAPH_USE_INTERNAL_GMP=ON
        -DIGRAPH_USE_INTERNAL_LAPACK=ON
        ${FEATURE_OPTIONS}
)

vcpkg_install_cmake()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/igraph TARGET_PATH share/igraph)

# # Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/igraph RENAME copyright)
