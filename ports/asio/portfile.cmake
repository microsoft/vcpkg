set(VCPKG_BUILD_TYPE release) # header-only

string(REPLACE "." "-" ref "asio-${VERSION}")
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO chriskohlhoff/asio
    REF "${ref}"
    SHA512 989e1b453cd5ab3cd8d9d35ea828c6fefb539b41c5e7f57b1dcba9a0a0f1cb2f90a80b4e03cc071fc904e2cf82212e6afb29062d50c2ebf36e798ce171f3ed48
    HEAD_REF master
)
file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

# Always use "ASIO_STANDALONE" to avoid boost dependency
vcpkg_replace_string("${SOURCE_PATH}/asio/include/asio/detail/config.hpp" "defined(ASIO_STANDALONE)" "!defined(VCPKG_DISABLE_ASIO_STANDALONE)")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DPACKAGE_VERSION=${VERSION}
)
vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()
    
vcpkg_cmake_config_fixup()
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/asio-config.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/asio/LICENSE_1_0.txt")
