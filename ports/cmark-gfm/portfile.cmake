vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO github/cmark-gfm
    REF 0.29.0.gfm.13
    SHA512 0c527e83664c65b17042cdb7ea2fee0e53dfb76e84800d15d5b3e45c3925464a2f392266b6e7a30cb19642b1fa719cc42fe7dde1340238841ffd9bffad13322b
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    PREFER_NINJA
    OPTIONS
        -DCMARK_TESTS=OFF
        -DCMARK_STATIC=ON
        -DCMARK_SHARED=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/cmark-gfm)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
