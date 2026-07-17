vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ng-log/ng-log
    REF "v${VERSION}"
    SHA512 321ea867b4ef2c73d0d54ae7906942ad1341605f5a837c296170f3295e96cf87a42c4c71ce707983e09d865dd29e6cc0656fc640c2214381f9c0f0f242365e70
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
