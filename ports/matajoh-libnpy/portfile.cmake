vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO matajoh/libnpy
    REF "v${VERSION}"
    SHA512 5959f7a27efdc25d463aff12ff3858772f628c703a5f99d6842aa26b4f6cc15e394b2fe2dc7b7a5277692c67a3bfe42c5749ed1a98b86ecb416a7b6bffac0029
    HEAD_REF main
)

file(REMOVE_RECURSE "${SOURCE_PATH}/src/miniz")

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DLIBNPY_BUILD_TESTS=OFF
        -DLIBNPY_BUILD_DOCUMENTATION=OFF
        -DLIBNPY_USE_SYSTEM_MINIZ=ON
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME npy)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")