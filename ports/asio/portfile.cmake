set(VCPKG_BUILD_TYPE release) # header-only

string(REPLACE "." "-" ref "asio-${VERSION}")
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO chriskohlhoff/asio
    REF "${ref}"
    SHA512 9374ff97bd4af7b5b41754970b2bcb468f450fee46a80c9c3344f732c64091f2ac5a73ebf4ac1831c623793c08a3c109ae90b601273c40d062bfd4f026f1d94d
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
