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
    SHA512 6991f3d82b4e0f331eea87d3234e87a1439c1c403d4e3d8489b8612451b098fbbc51f3d27282eeeb3a319623c10eda110893807ed38dbfc97b893279cbbd0986
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
