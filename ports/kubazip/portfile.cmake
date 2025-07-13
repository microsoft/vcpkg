vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SamuelMarks/zip
    REF 062f58125fc954e3bc22859fca1cf3c62b5ffbc8
    SHA512 ca4013d59edbdd868504a5f82f028d4cc20df37d46227f822d60a820e3a6b8493e683160d75b275a7283f8e6e1d9d6c45d1585f5b0333730f32e7ffa1185204b
    HEAD_REF c89-vcpkg
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DCMAKE_DISABLE_TESTING=ON"
        "-DCMAKE_PROJECT_NAME=${PORT}"
        "-DCMAKE_INSTALL_INCLUDEDIR=${CURRENT_PACKAGES_DIR}/include/${PORT}"
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}" PACKAGE_NAME "${PORT}")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
