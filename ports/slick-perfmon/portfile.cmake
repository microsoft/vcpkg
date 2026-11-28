set(VCPKG_BUILD_TYPE release) # header only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SlickQuant/slick-perfmon
    REF "v${VERSION}"
    SHA512 4278563388babb6e04f21bc30584c9c5a363175989371fda565dff0245061a8765a9c729abeb61be2cc2b7e925e806c82bc8880a74ab3534e690b79b010165ad
    HEAD_REF main
    PATCHES
        slick-dependencies.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_SLICK_PERFMON_TESTS=OFF
        -DBUILD_SLICK_PERFMON_EXAMPLES=OFF
        -DBUILD_SLICK_PERFMON_COLLECTOR=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    CONFIG_PATH lib/cmake/slick-perfmon
)

# Header-only library - remove lib directory
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

# Install license
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
