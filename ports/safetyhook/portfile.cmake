vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cursey/safetyhook
    REF "v${VERSION}"
    SHA512 863aad37f9236f151be6a2e6f29d962cd2d356c6ff80a1e9e5a4f6d6a22c1dddbd52462ce48203ae67ae124f7d71eb60f6e2829c8eba417bb6b5569aab5683f2
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
    	"-DCMKR_SKIP_GENERATION=ON"
        "-DSAFETYHOOK_FETCH_ZYDIS=OFF"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/safetyhook)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
