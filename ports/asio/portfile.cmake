#header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO chriskohlhoff/asio
    REF asio-1-16-1
    SHA512 7e5f8a503b6e8e939b3e77921bea2a11312dbe2ec609669c387ff11ebb97c2fbba96a57d064b34946b3db2cd45de6524a39d3050fd5b7d5b7f4fb595848a27ed
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

