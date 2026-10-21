vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO realtimechris/benchmarksuite
    REF "v${VERSION}"
    SHA512 8fd2254289952d2f9a1697cde1f3ee7b278ad5e00a38c49a0f114d311e504deed9d05b2b482aa05d3d6f1289e27477b107cb83b969bdf7dfa0cb04c0b6649c1c
    HEAD_REF main
)

set(VCPKG_BUILD_TYPE release)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/License.md")
