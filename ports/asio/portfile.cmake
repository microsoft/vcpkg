#header-only library
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO chriskohlhoff/asio
    REF 90f32660cd503494b3707840cfbd5434d8e9dabe
    SHA512 bd9c71e7fa296ea72ec8bba7cd790f078ef74a8f7f9da9e1909a5f907efc59a34ef5599bade21b74a19aa302cdc0d171a409ec6eb019554262b728e7b74e4f1f
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
