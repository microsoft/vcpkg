set(VCPKG_BUILD_TYPE release) # Header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sentomk/patternia
    REF "v${VERSION}"
    SHA512 6aa887910ab39b571ff20f2fd95b41e5d92be29f90a458318579c0d6750cfba8f32242cc8f69b58d56d9001e163a0f65d1b7d3186f66b3168db23cb094c89971
    HEAD_REF main
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DPTN_INSTALL=ON
        -DPTN_BUILD_TESTS=OFF
        -DPTN_BUILD_BENCHMARKS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
