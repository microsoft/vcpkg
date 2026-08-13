# The C++ library is one subdirectory of a multi-language repository; the rest
# of the tree (Rust, Python, TypeScript) is not built here.
#
# C++ releases are tagged cpp-v<version> (like npm-v*/python-v*): a bare
# v<version> is the tag release.yml cuts for the Rust crates, which version
# independently.
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cityjson/flatcitybuf
    REF "cpp-v${VERSION}"
    SHA512 c808e4b7b78471c0abe5cf2cdb732cd50d365ae3fe0e2f61f3e7520474e475ac48294d70ef6571a7fce2a921ee734273dac7397c74004a090f467588dda91488
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
