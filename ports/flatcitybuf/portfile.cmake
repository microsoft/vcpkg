# The C++ library is one subdirectory of a multi-language repository; the rest
# of the tree (Rust, Python, TypeScript) is not built here.
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cityjson/flatcitybuf
    REF "v${VERSION}"
    SHA512 3679d687b7cba64832b6a18a04246c20431c5b1f641d9c2506edd785d53eb24f54b32a14f41bff19a89037bb878cbab8fc9f45533ad6af7457cb65367865279d
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
