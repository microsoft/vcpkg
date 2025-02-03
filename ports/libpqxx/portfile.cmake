vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jtv/libpqxx
    REF "${VERSION}"
    SHA512 f4035b1d976580f0ca101d484940f18a5af8299e249b754098c6c4bbe8198a855013112965300f7d978ca127b75547f2e2f4fb567b77114f010392952f0ed642
    HEAD_REF master
    PATCHES
        fix_build_with_vs2017.patch
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/config-public-compiler.h.in" DESTINATION "${SOURCE_PATH}")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/config-internal-compiler.h.in" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSKIP_BUILD_TEST=ON
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/libpqxx)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")

vcpkg_fixup_pkgconfig()
