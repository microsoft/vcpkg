# The library exports no symbols explicitly, so a shared build would produce an
# import library with nothing in it on Windows.
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Project-OSRM/gauche-rs
    REF "v${VERSION}"
    SHA512 eefae5bed6bfab30af646f182eaebafbf9120e4cd4ad0bb9b50c36bbcb5760c2378d28f468494e7acbc89a304edb64e39af96c3de7239d3a3f810411443cbce3
    HEAD_REF main
)

# The CMake project lives in cpp/ but compiles the transpiled C sources from the
# sibling c/ directory, so the whole repository has to be extracted.
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/cpp"
    OPTIONS
        -DGAUCHE_BUILD_EXAMPLES=OFF
        -DGAUCHE_ENABLE_LTO=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/gauche)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# The library embeds w2c2's header-only runtime, which is separately licensed.
vcpkg_install_copyright(FILE_LIST
    "${SOURCE_PATH}/LICENSE"
    "${SOURCE_PATH}/c/w2c2/LICENSE"
)

configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" COPYONLY)
