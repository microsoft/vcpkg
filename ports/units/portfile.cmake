vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nholthaus/units
    REF v${VERSION}
    SHA512 2280782fe020fb60fe16f304105de73b30fa51c36e075bfa9b4d0c9d585936084802dd8cca6b1967ad10c7ad949afce27937050184151c2a67f2113f14c38c1b
)

set(VCPKG_BUILD_TYPE "release")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH share/units/cmake)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
