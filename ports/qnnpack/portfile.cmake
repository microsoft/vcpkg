vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pytorch/QNNPACK
    REF 7d2a4e9931a82adc3814275b6219a03e24e36b4c
    SHA512 437a835acfedae851a9a8572fa6eea9854dcb8bcca499bc4a2582314e44f5f199778e857932da4aecf943bea7cb2eb5b1c41d4b4ca6075bddbe0f18b2c7b9127
    HEAD_REF master
    PATCHES
        use-packages.patch
        fix-arm64-osx.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DQNNPACK_BUILD_TESTS=OFF
        -DQNNPACK_BUILD_BENCHMARKS=OFF
)
vcpkg_cmake_install()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include"
                    "${CURRENT_PACKAGES_DIR}/debug/bin"
)
