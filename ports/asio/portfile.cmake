#header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO chriskohlhoff/asio
    REF asio-1-20-0
    SHA512 dc2def1f2b93866100b5d645f77c4a231fe3feae457010abf4e659df76b08b46870d608cf792a2f82e1b28c69c320055862647fb29aa0677a58d6141d58e76b2
    HEAD_REF master
)

# Always use "ASIO_STANDALONE" to avoid boost dependency
vcpkg_replace_string("${SOURCE_PATH}/asio/include/asio/detail/config.hpp" "defined(ASIO_STANDALONE)" "!defined(VCPKG_DISABLE_ASIO_STANDALONE)")

# CMake install
file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)
vcpkg_cmake_install()

vcpkg_cmake_config_fixup()
file(INSTALL
    "${CMAKE_CURRENT_LIST_DIR}/asio-config.cmake"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/asio/LICENSE_1_0.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
