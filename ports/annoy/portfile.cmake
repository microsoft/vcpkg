vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO spotify/annoy
    REF 0457742d12cf7a263f7c709ef1d470e5f08f791d # master on 2023-02-25
    SHA512 df26b18a5a165081a9373076f974ee977b0b4b54e7a58da3723f608e4cc46aab1d0978f2663965c8bbb81d123c8efff1a77040ef2bfdc0287b08214514b40ecc
    HEAD_REF master
)

set(VCPKG_BUILD_TYPE "release") # header-only port

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/annoy)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
