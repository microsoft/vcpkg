vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO LTLA/CppIrlba
    REF "v${VERSION}"
    SHA512 17e84cf3d5de06dc9c599695a9d2b5b6d48f9ec1c3f04b6c1f875ab809d42dfddc7a97e400d02e7fd55e88e708df6162ba4e7aadf0a47f8eea6004e3efbb4dd3
    HEAD_REF master
    PATCHES
        0001-fix-eigen3.patch
)

set(VCPKG_BUILD_TYPE "release") # header-only port

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DIRLBA_FETCH_EXTERN=OFF
        -DIRLBA_TESTS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
    PACKAGE_NAME ltla_irlba
    CONFIG_PATH lib/cmake/ltla_irlba
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
