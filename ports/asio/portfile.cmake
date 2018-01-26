#header-only library
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO chriskohlhoff/asio
    REF asio-1-10-8
    SHA512 55c26a6daf893f6e91ec7e8b5d70f1e27f2c1886552b2c9cb5c47b7c3bb08f78c9d6cec0a3bc6edbfb657a5094a001f742db0f18f81f51d79661b01fafea293e
    HEAD_REF master
)

# Handle copyright
file(COPY ${SOURCE_PATH}/asio/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(RENAME ${CURRENT_PACKAGES_DIR}/share/${PORT}/COPYING ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright)

# Copy the asio header files
file(INSTALL ${SOURCE_PATH}/asio/include DESTINATION ${CURRENT_PACKAGES_DIR} FILES_MATCHING PATTERN "*.hpp" PATTERN "*.ipp")
