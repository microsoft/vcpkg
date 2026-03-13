vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO matajoh/libnpy
    REF "v${VERSION}"
    SHA512 f01e4621899b1ad80507df485b9bd4ec65b0ae1a8f4e32fd6f34d52ce567b158926337117119e62e3a1ad78665d95d1edebaf549b0c73e9049b2d4deafdf31cd
    HEAD_REF main
)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DLIBNPY_BUILD_TESTS=OFF
        -DLIBNPY_BUILD_DOCUMENTATION=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME npy)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
