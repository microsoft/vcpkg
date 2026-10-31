# lemon-ng at the tag of its version, built without the LP and MIP backends,
# the tests, the demos, the tools and the documentation, and always as a
# static library, since LEMON declares no symbol for a DLL
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO dmeoli/lemon-ng
    REF ${VERSION}
    SHA512 80be79b51d1d7aa0eb4c135215ce3508ea225f0b8a23daa2f7912a446f2b4ba1acfd4a596eaaa87a779d08f8169170f2831c39b472764b7f47e01fe7a0d175df
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DLEMON_VERSION=${VERSION}
        -DLEMON_BUILD_TESTS=OFF
        -DLEMON_BUILD_DEMOS=OFF
        -DLEMON_BUILD_TOOLS=OFF
        -DLEMON_BUILD_DOC=OFF
        -DLEMON_ENABLE_GLPK=OFF
        -DLEMON_ENABLE_ILOG=OFF
        -DLEMON_ENABLE_COIN=OFF
        -DLEMON_ENABLE_SOPLEX=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH share/lemon/cmake PACKAGE_NAME lemon)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include"
                    "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
