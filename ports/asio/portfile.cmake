#header-only library
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO chriskohlhoff/asio
    REF be7badc31abcc395cf868de6a1e240c2350bdbf2 # asio-1-18-0
    SHA512 a43d9ced5a7539e191e1b9be1f8be3b6573f8b12ac01cfe6f0cd8f1d887667971e1cf5fd3a632f972fa656442239547cf0f705d4b5c439b2b256dd5c5c5adc1e
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

