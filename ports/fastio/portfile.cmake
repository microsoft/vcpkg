# header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cppfastio/fast_io
    REF dd78867b7ae27da71c2e6d5d4f543066c301c047
    SHA512 7376b4f2420c6b21d1b81f693a067c43ca16ad3110a53893687e1715acfdfa4d41604fb1d13c1537809a9f14321cfae6829f56a10bdceba72926feb45ec9d0a3
    HEAD_REF master
)

set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/license.txt")
