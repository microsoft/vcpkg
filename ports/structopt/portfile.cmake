vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO p-ranav/structopt
    REF "v${VERSION}"
    SHA512 f284ec20379a1bfecfe1622e45d0570128455ecf0c24f2a1d26420c13a277112ca7ba350e2d40c0b0b37b38eba4ffa6ff164590b32262a5ba23186f7cd904511
    HEAD_REF master
    PATCHES
        0000-vendored-dependencies.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSTRUCTOPT_TESTS=OFF
        -DSTRUCTOPT_SAMPLES=OFF
)

vcpkg_cmake_install()

# Header-only library.
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/structopt")
vcpkg_fixup_pkgconfig()

# Delete all third-party header files vendored by the structopt library.  The library has been patched to instead use
# the external versions of these libraries.
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/structopt/third_party")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/LICENSE"
)

# Remove redundant license files that are installed by the library.
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/share/licenses)

configure_file(
    "${CMAKE_CURRENT_LIST_DIR}/usage"
    "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage"
    COPYONLY
)
