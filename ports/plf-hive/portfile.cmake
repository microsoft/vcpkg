# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mattreecebentley/plf_hive
    REF 5d4f13cafdc1bd5e23c4b5435e0f33f347d3b003
    SHA512 9f32c8ad70851ba9e2db32c6d47999c2fe554f5e7fdab5803c3743c5df5ca881afacebeb37594dbb8a587df793eab9c7ccae05f20c48e7931cfbb30dd680f5ee
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/plf_hive.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

file(INSTALL "${SOURCE_PATH}/LICENSE.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
