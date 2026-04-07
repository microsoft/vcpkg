# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kunitoki/LuaBridge3
    REF 0e17140276d215e98764813078f48731125e4784 # 3.0-rc3
    SHA512 b0cafc817abf6408bb26ba76ca05641cc311e2defa3a78481af7dbd56be49f3d28c81d2b2a152aa5f0ea18721578eb9e36515614dca40f813603af5abe45d0ce
    HEAD_REF master
)

# Copy the header files
file(COPY "${SOURCE_PATH}/Source/LuaBridge" DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
