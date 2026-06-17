# SPDX-License-Identifier: MIT
# Header-only port — no libs are built, only headers + CMake config are installed.
set(VCPKG_BUILD_TYPE release)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO        stescobedo92/stellar
    REF         "v${VERSION}"
    SHA512      9fc4441626ceeaaaf730da8e886e133bec57613e39e51005a3678fd6e9d8163d20232bfe6cd54273f04e53d756bed475fd1d9fd70c7758b64fd20198ad80ce3d
    HEAD_REF    master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSTELLAR_BUILD_TESTS=OFF
        -DSTELLAR_BUILD_BENCHMARKS=OFF
        -DSTELLAR_BUILD_EXAMPLES=OFF
        -DSTELLAR_ENABLE_WARNINGS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME stellar CONFIG_PATH lib/cmake/stellar)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug"
    "${CURRENT_PACKAGES_DIR}/lib"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
