vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Soundux/lockpp
    REF "v${VERSION}"
    SHA512 79cd7bbfdf2a336b67f954e3ffa06a5dc117bd0b184929d125c15930ea57c06acf58dbd2f713e9f58c7be708905cb89732f4bbff4f67924e76ba636722f68232
    HEAD_REF master
)

vcpkg_cmake_configure(SOURCE_PATH ${SOURCE_PATH})

vcpkg_cmake_install()


file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
