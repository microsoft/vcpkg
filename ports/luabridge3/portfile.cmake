# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kunitoki/LuaBridge3
    REF 3b5ccfb2331cecc4b1b9e8b8ccccb4bf5ce0a304 # 3.0
    SHA512 f09864f0dbb29f1ee5c1602371a7eaf38bb65d5dd7469cdc8a4c9681367bfc52743b71b9b15f3733c1cf556763d7beca62d18abef301ddb87d56cdf25a233882
    HEAD_REF master
)

# Copy the header files
file(COPY "${SOURCE_PATH}/Source/LuaBridge" DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
