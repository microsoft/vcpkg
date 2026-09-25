vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO machframework/mach
    REF "v${VERSION}"
    SHA512 8338091bb0fa98c2896e7fd33d9cbe46e02e0b042ead5bab259d6ef3d7d79c24114f07ca1c35ab4551c6bb0add1d01489195f578bc6f0edbe812a8601b57c708
    HEAD_REF main
    PATCHES fix-build-configuration.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DMACH_BUILD_TESTS=OFF
        -DMACH_BUILD_BENCHMARKS=OFF
        -DMACH_BUILD_EXAMPLES=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    CONFIG_PATH lib/cmake/Mach
)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

vcpkg_install_copyright(
    FILE_LIST "${SOURCE_PATH}/LICENSE"
)
