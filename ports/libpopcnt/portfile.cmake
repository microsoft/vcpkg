set(VCPKG_BUILD_TYPE release) # Header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kimwalisch/libpopcnt
    REF "v${VERSION}"
    SHA512 5c79fb6690bd39f322430657b26508b8092c1d1d078b435d35fd20771053c021cbc7e819d7a4fb2bb88bf527f5fbab7ba992dca02009eb20cff70d2d369a6658
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/libpopcnt.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
