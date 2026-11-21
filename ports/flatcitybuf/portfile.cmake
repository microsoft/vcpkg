# The C++ library is one subdirectory of a multi-language repository; the rest
# of the tree (Rust, Python, TypeScript) is not built here.
#
# C++ releases are tagged cpp-v<version> (like npm-v*/python-v*): a bare
# v<version> is the tag release.yml cuts for the Rust crates, which version
# independently. REF is the commit of that tag, so the source cannot move.
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cityjson/flatcitybuf
    REF fb651f9e4800675972e0c22e8c73897507fe2ced # cpp-v0.10.0
    SHA512 6e5b3d6b4dee5ad2b0ea0c8eb189edc649fc4ab29b78bdc92e4c8c1e25d2f4134cf1567266844ff3341710fed25f27406bba143bb49caf00c0dcef204778667f
    HEAD_REF main
    PATCHES
        relax-flatbuffers-version-check.patch
)

# fcb_core_cpp is declared STATIC unconditionally upstream.
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        curl FCB_WITH_CURL
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/src/cpp"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DFCB_WITH_JSON=ON
        -DFCB_BUILD_TESTS=OFF
        -DFCB_BUILD_EXAMPLES=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/flatcitybuf)

# The headers are installed by both configurations; keep only the release copy.
file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
