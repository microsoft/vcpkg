vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jtv/libpqxx
    REF "${VERSION}"
    SHA512 bc7fa622b48352b0bcc4d5a49e5b5c47c29e1863547d9f7652c300f324c8f3302c8ffc06d7c77b2ec562ef879ec6b22c96a74b0de7b03b8763f75d7806cb1eaf
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
