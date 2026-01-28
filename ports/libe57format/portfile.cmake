vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO asmaloney/libE57Format
    REF "v${VERSION}"
    SHA512 2a224bd9ff88cdfd182267c96e4d6151a51a0ae6959c41dbe11d65e31cd1c9d5ecbf7f69c355daef6331181b454b123978036478f14cbf1cd2e51544bab16102
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" E57_BUILD_SHARED)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DE57_BUILD_TEST=OFF
        -DE57_BUILD_SHARED=${E57_BUILD_SHARED}
        -DE57_RELEASE_LTO=OFF
)
vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME E57Format CONFIG_PATH "lib/cmake/E57Format")

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
