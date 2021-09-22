# Header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO scottt/debugbreak
    REF v1.0
    SHA512 bf8c43d42d9b19c9a3cb1fa5955a24efb48c2c21f0d89685f23702c3e2644637f2e8c6ec599024866138519b107787baef838b6d981779e2484e30d20a7386b9
    HEAD_REF master
)

file(
    COPY "${SOURCE_PATH}/debugbreak.h"
    DESTINATION "${CURRENT_PACKAGES_DIR}/include"
)

# Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
