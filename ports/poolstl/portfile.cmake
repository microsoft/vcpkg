set(VCPKG_BUILD_TYPE release) # header-only

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO alugowski/poolSTL
    REF "v${VERSION}"
    SHA512 a2d29056b29f32f034560f88e05f7257ff1f43b46579b940da3e340c97cf8bfbb7d886f5101044d5e22931af37bbcf72f956a0157e135cdf10c7a987e56ba081
    HEAD_REF main
    PATCHES
        fix-find-dependency.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH share/cmake/poolSTL)

vcpkg_install_copyright(
    COMMENT [[
poolSTL is triple-licensed under the BSD 2-Clause License,
the Boost Software License 1.0, and the MIT license.
You may select, at your option, one of the above-listed licenses.
]]
    FILE_LIST
        "${SOURCE_PATH}/LICENSE-BSD.txt"
        "${SOURCE_PATH}/LICENSE-Boost.txt"
        "${SOURCE_PATH}/LICENSE-MIT.txt"
)
