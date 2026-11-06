vcpkg_check_linkage(ONLY_STATIC_LIBRARY) # upstream always builds a static library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tomwillow/tomsolver
    REF "${VERSION}"
    SHA512 18a58288c313f2abb8f356ef3868fa7d1eb9e06df4096108ca08aae06ebebfd618b6b6b5e3e629432082d9267224f772af38641a26960154503554317e6e818e
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_EXAMPLES=OFF
        -DBUILD_TESTS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
