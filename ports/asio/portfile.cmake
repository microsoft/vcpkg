set(VCPKG_BUILD_TYPE release) # header-only

string(REPLACE "." "-" ref "asio-${VERSION}")
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO chriskohlhoff/asio
    REF "${ref}"
    SHA512 d340396e320f352a860c9f4904457a365969a95e2e564675e024a3a5885194382f37708a87505904a99688a2f1fd3f1abe64959316bf7e73032d3250bc3b76be
    HEAD_REF master
)
file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

# Always use "ASIO_STANDALONE" to avoid boost dependency
vcpkg_replace_string("${SOURCE_PATH}/include/asio/detail/config.hpp" "# if !defined(ASIO_ENABLE_BOOST)" "# if !defined(ASIO_ENABLE_BOOST) && !defined(VCPKG_DISABLE_ASIO_STANDALONE)")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DPACKAGE_VERSION=${VERSION}
)
vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()

vcpkg_cmake_config_fixup()
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/asio-config.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE_1_0.txt")
