# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kunitoki/LuaBridge3
    REF b892ce066217601928fbc3f37a6a8706faf410da # 3.0-rc11
    SHA512 2574c804b18581cc5ac0966690135b4ff8145bf821c6d682279af10ede5a4d2a58a0f20fa3f1485bd16b33ebfca38937e9aabad8198f0bf3c8070dcf31372af0
    HEAD_REF master
)

# Copy the header files
file(COPY "${SOURCE_PATH}/Source/LuaBridge" DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
