# header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cppfastio/fast_io
    REF e3df753a74a27e00bcb288bc97ab203645ed9579
    SHA512 9afe554570241a64e6f155419635aa6c0f97898902f7e4fcace883ed532142174e8b584e300223e0b8f2fa9831ee031f92465b2d5ffd9466de323b59efd37b59
    HEAD_REF master
)

set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/license.txt")
