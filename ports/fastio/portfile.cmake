# header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cppfastio/fast_io
    REF 804d943e30df0da782538d508da6ea6e427fc2cf
    SHA512 543f91bb55e3dec305a5d0103b2eba9304b3d0a5f8874a38d4ebb584c027fcc2f9cedfb5716bac2951f1474b2467fe287f70b8287452f8ba277663f8342a112c
    HEAD_REF master
)

set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/license.txt")
