# SPDX-FileCopyrightText: 2026 Arnaldo Mendes Pires Junior
# SPDX-License-Identifier: MIT

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Arnime/grasp_ils_vnd_pr
    REF v${VERSION}
    SHA512 f64004dec9f5913adca5d79ee4c71821aadbc9cd9527680bcfc3d1c6f8511355739fd0b78fa657d2aae0e0f6e2ff47dad1d7e8816e1435e0ae14de7336a5d715
    FILENAME grasp_ils_vnd_pr-${VERSION}.tar.gz
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/cpp"
    OPTIONS
        -DGIVP_BUILD_TESTS=OFF
        -DGIVP_BUILD_BENCHMARKS=OFF
        -DGIVP_BUILD_FUZZ=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME givp
    CONFIG_PATH lib/cmake/givp
)

# Header-only, no need to keep debug files
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

# Install license
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
