vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO WangHaiPi/codepy
    REF v1.1.0
    SHA512 0
)

file(COPY ${SOURCE_PATH}/codepy.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
