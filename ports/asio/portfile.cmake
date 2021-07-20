#header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO chriskohlhoff/asio
    REF asio-1-18-2
    SHA512 5a2312f1a14106e3109a9f02e8ac65a1d639b411834f0aa301767a4dd30d8384f6f1a94034b6016ef989c7d7880fd4c8de11c7be0cb58b4dc64a49ec335a7113
    HEAD_REF master
)

# Always use "ASIO_STANDALONE" to avoid boost dependency
vcpkg_replace_string("${SOURCE_PATH}/asio/include/asio/detail/config.hpp" "defined(ASIO_STANDALONE)" "!defined(VCPKG_DISABLE_ASIO_STANDALONE)")

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
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}
)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/asio/LICENSE_1_0.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
