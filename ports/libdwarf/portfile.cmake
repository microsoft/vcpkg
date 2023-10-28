vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO davea42/libdwarf-code
    REF "v${VERSION}"
    SHA512 3117c69cc77d5a1189aeb1ea7e74d917dedfb84e9e9e98e3df7fec930f8183d12f55bb12e4871ed3746cdb19a29aba924bc73d6334b23bbb6413a1f4be67d499
    HEAD_REF main
    PATCHES v0.8.0-patches.patch
)

# Apparently -DBUILD_NON_SHARED=On is the right option regardless of VCPKG_LIBRARY_LINKAGE being static or not. I'm very
# confused what the libdwarf cmake script is doing.
vcpkg_list(SET options -DBUILD_NON_SHARED=On)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${options}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
    PACKAGE_NAME "libdwarf"
    CONFIG_PATH "lib/cmake/libdwarf"
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/pkgconfig")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" COPYONLY)
