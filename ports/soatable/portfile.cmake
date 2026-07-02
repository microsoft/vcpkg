vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO bbalouki/soatable
    REF "v${VERSION}"
    SHA512 0c51a4557e563a8b3216a72a837e50db739743453f71d6c7ff24ab74f8785201da037c8bd30804e53b940f92e1e5cf9500485a5c8bede01dc2442a01b6ea967d
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSOATABLE_BUILD_TESTS=OFF
        -DSOATABLE_BUILD_EXAMPLES=OFF
        -DSOATABLE_BUILD_BENCHMARKS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME "soatable"
    CONFIG_PATH "lib/cmake/soatable"
)
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

# An interface library installs no binaries.
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/lib")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
