vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jeremydumais/CPP-SMTPClient-library
    REF "v${VERSION}"
    SHA512 1f1b28519e9cc4c37746dcb083ac00180ef249cffd60feb8f13365c9655b2c66f4c05c46e5fd7953254a20d4708eb1e80ea883a205411554ae23f5709935f901
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
