# header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cppfastio/fast_io
    REF 621b461a12af1d4c52d867127753b2bc0b60f946
    SHA512 bdc651a06071d5e9b043d0295396351ef05552e98f80161f6026b0ba32ff6f65397cd95daa1da47e4811b2eb94c12a7d0dd47219385b7278e668bb117128f774
    HEAD_REF master
)

set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/license.txt")
