string(REGEX REPLACE "^([0-9]+)[.]([0-9])$" "\\1.0\\2" TURBO_VERSION "${VERSION}")

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO powturbo/Turbo-Base64
    REF ${TURBO_VERSION}
    SHA512 de8aaace0faf6552cf692f131a4d03882b88252732bb4160c48e5cc630a0c2f637fa27309e084d02305cdf7ef28020e6c9fbb82b50c1916e46aabc95baea75ad
    HEAD_REF master
    PATCHES
        fix-library-conflict.diff
        fix-apple-silicon-arm64-detection.diff # https://github.com/powturbo/Turbo-Base64/pull/29
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
