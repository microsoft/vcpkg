vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO a4z/libsl3
    REF "v${VERSION}"
    SHA512 70c9e8f1f2bfb31e9a442eae91c90c7984083ce025027117a2d62c4a97b75a3815165b1a7e61ffc4201523bae3eee77df74eb9a6eeb3cdd030575c0cd4235a41
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DCMAKE_CXX_STANDARD=17
        -DCMAKE_CXX_STANDARD_REQUIRED=ON
        -Dsl3_BUILD_DOCS=OFF
        -Dsl3_BUILD_TESTING=OFF
        -Dsl3_USE_COMMON_COMPILER_WARNINGS=OFF
        -Dsl3_USE_INTERNAL_SQLITE3=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME sl3 CONFIG_PATH lib/cmake/sl3)
vcpkg_copy_pdbs()

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/README.md")
