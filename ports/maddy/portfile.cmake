vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO progsource/maddy
    REF "${VERSION}"
    SHA512 f494dc83f6adc181666e8b77280fa341176128f4d66bf43b34dbfda07a2f6d5dcacd0772a730a0ceeaa766b5e3ea8850a758217377c0793da6636bd55a27de51
    HEAD_REF master
)

set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/maddy)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
