vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ng-log/ng-log
    REF "v${VERSION}"
    SHA512 0685e92f5d147d162be71e666cfaae52aaf23b7f3e3d5bc1384345ac05dfd16e7163ff7c1c7d83a70fb00fb56a5c9be6a246c0690d9fb01ba2b5c1576ee8787b
    HEAD_REF master
)

set(CROSSCOMP_OPTIONS "")
if(VCPKG_CROSSCOMPILING)
    set(CROSSCOMP_OPTIONS -DHAVE_SYMBOLIZE_EXITCODE=0)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_COMPAT=OFF
        -DBUILD_EXAMPLES=OFF
        -DBUILD_TESTING=OFF
        -DPRINT_UNSYMBOLIZED_STACK_TRACES=OFF
        -DWITH_GFLAGS=ON
        -DWITH_GTEST=OFF
        -DWITH_PKGCONFIG=ON
        -DWITH_SYMBOLIZE=ON
        -DWITH_TLS=ON
        ${CROSSCOMP_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})

vcpkg_copy_pdbs()

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
