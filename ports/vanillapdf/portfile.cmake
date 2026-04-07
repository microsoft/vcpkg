vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vanillapdf/vanillapdf
    REF "v${VERSION}"
    SHA512 7e8e555901ea8c60d0bbd69933b284b88930c8bff771363d83228302832f43e3ae560f9666b1410ce388e60285c4a41b297a2d99fa465cbe23b406afd0647612
    PATCHES
        disable-autosubscribe.diff
)

string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" VANILLAPDF_USE_STATIC_CRT)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
      -DVANILLAPDF_INTERNAL_VCPKG=OFF
      -DVANILLAPDF_ENABLE_TESTS=OFF
      -DVANILLAPDF_ENABLE_BENCHMARK=OFF
      -DVANILLAPDF_USE_STATIC_CRT=${VANILLAPDF_USE_STATIC_CRT}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME "vanillapdf"
    CONFIG_PATH "lib/cmake/vanillapdf"
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/LICENSE.txt"
        "${SOURCE_PATH}/NOTICE.md"
)
