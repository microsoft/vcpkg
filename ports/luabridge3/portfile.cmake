# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kunitoki/LuaBridge3
    REF d811afc00bc3d19f548d5aa28ccfe16b09e62ea4 # 3.0-beta4
    SHA512 93c6187ac171ea3cc8c01ebdd3ea215b599b06268f83e4c35e9532dbeec94fde9219b26bc1cf8929bbafa1881f5258cbaf61abf89514ee8b557e52df0f05c2eb
    HEAD_REF master
)

# Copy the header files
file(COPY "${SOURCE_PATH}/Source/LuaBridge" DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
