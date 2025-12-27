vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

string(REGEX MATCH "^([0-9]+)\\.([0-9]+)\\.([0-9]+)" VERSION ${VERSION})
set(VERSION "${CMAKE_MATCH_2}.${CMAKE_MATCH_3}")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO protocolbuffers/protobuf
    REF "v${VERSION}"
    SHA512 7b84fee0cb0a3b5de4b59899b12a7cccfe330b588a26bf397ec46c3ac61ce883018116f6a0ef73e621b35e7eacde1d13086317dad5cfa1066aa558c950ef48a2
    HEAD_REF main
    PATCHES
        fix-cmake.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/third_party/utf8_range"
    OPTIONS
        "-Dutf8_range_ENABLE_TESTS=off"
        "-Dprotobuf_VERSION=${VERSION}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME "utf8_range" CONFIG_PATH "lib/cmake/utf8_range")

vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/third_party/utf8_range/LICENSE")
