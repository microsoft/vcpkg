#header-only library
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO chriskohlhoff/asio
    REF asio-1-14-0
    SHA512 056ef5b0fe7def4fb5c8b176a1469658150b38110cc40825f2b07a7dd4c7b1800445e438c06a753d6a006aef6045789134b0ab32b1b74643fb287ee5a8f85fb9
    HEAD_REF master
)

# Always use "ASIO_STANDALONE" to avoid boost dependency
file(READ "${SOURCE_PATH}/asio/include/asio/detail/config.hpp" _contents)
string(REPLACE "defined(ASIO_STANDALONE)" "!defined(VCPKG_DISABLE_ASIO_STANDALONE)" _contents "${_contents}")
file(WRITE "${SOURCE_PATH}/asio/include/asio/detail/config.hpp" "${_contents}")

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

