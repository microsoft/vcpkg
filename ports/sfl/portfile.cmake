vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO slavenf/sfl-library
    REF "${VERSION}"
    SHA512 c73e604cec16224cd290be0dfbccb279c79706135185b864657e6a192129cfd30658d1d18defe44a34892f1b21caccabafdcc09d8b7b988dd3dabb73724c9031
    HEAD_REF master
)

# header-only
set(VCPKG_BUILD_TYPE "release")

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")

vcpkg_cmake_install()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
