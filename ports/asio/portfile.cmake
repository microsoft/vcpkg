#header-only library
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO chriskohlhoff/asio
    REF asio-1-12-1
    SHA512 e335eea05c27a72faae95dd5d5ca997ac8bb144cd5fb68e5538129ea6afb3b4d88e2be1c31a1effdbbbe4c93e07ee274a7e5817453c29faf56abf9ab692b2dd6
    HEAD_REF master
)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/asio/LICENSE_1_0.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

# Copy the asio header files
file(INSTALL ${SOURCE_PATH}/asio/include DESTINATION ${CURRENT_PACKAGES_DIR} FILES_MATCHING PATTERN "*.hpp" PATTERN "*.ipp")

# Always use "ASIO_STANDALONE" to avoid boost dependency
file(READ "${CURRENT_PACKAGES_DIR}/include/asio/detail/config.hpp" _contents)
string(REPLACE "defined(ASIO_STANDALONE)" "!defined(VCPKG_DISABLE_ASIO_STANDALONE)" _contents "${_contents}")
file(WRITE "${CURRENT_PACKAGES_DIR}/include/asio/detail/config.hpp" "${_contents}")
