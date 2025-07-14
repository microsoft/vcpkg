vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ng-log/ng-log
    REF "v${VERSION}"
    SHA512 bc97ab17f7421003d8dd7cd42cfb6880006c7d9b84d3201df5e14536f62cc39cafa6e7e1f6f1a34d48d085cdf557b90faf347f672b5fb29c92cc1b2859fde32d
    HEAD_REF master
)

set(CROSSCOMP_OPTIONS "")
if(VCPKG_CROSSCOMPILING)
    set(CROSSCOMP_OPTIONS -DHAVE_SYMBOLIZE_EXITCODE=0)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
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
