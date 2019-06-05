#header-only library
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO chriskohlhoff/asio
    REF asio-1-13-0
    SHA512 bd9c71e7fa296ea72ec8bba7cd790f078ef74a8f7f9da9e1909a5f907efc59a34ef5599bade21b74a19aa302cdc0d171a409ec6eb019554262b728e7b74e4f1f
    HEAD_REF master
)

# CMake install
file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)
vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH "share/asio")
file(INSTALL
    ${CMAKE_CURRENT_LIST_DIR}/asio-config.cmake
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/asio/
)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/asio/LICENSE_1_0.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

