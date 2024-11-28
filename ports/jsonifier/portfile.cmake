vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO realtimechris/jsonifier
    REF "v${VERSION}"
    SHA512 6168378a117850297fcda78853a0babd0ce7e0ca21b3e8c276acb7e75e04d85ed8909061a62e3324c309fe9e31bc59d89ea06e47853b50481843273e95172ab8
    HEAD_REF main
)

set(VCPKG_BUILD_TYPE release) # header-only

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    # Due to CMake/JsonifierDetectArchitecture.cmake invoking a sub-CMake and using the source tree as the target
    DISABLE_PARALLEL_CONFIGURE
)

vcpkg_cmake_install()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/License.md")
