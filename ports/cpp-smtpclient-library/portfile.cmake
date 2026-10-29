vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jeremydumais/CPP-SMTPClient-library
    REF "v${VERSION}"
    SHA512 2630305fd29f74b044623ed11a31610a6e46b0b36becfe763446340b1c6af8da6f8703c113a88b4d61ed8f52b5faab5eb05729a63b763e9ee4e1b43a60f534bd
    HEAD_REF master
)

# Configure with explicit install dirs to avoid absolute /smtpclient
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCMAKE_INSTALL_INCLUDEDIR=include # must be initialized
        -DBUILD_TESTING=OFF # avoid gtest download/build in vcpkg
)
vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME "smtpclient" CONFIG_PATH "lib/cmake/smtpclient")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/smtpclient/cpp/example")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
