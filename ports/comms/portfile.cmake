#header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO commschamp/comms_champion
    REF v3.1.3
    SHA512 80aa3e0e53f3de21b8dcb4f02765f59ff58fc8c1b9e21beb09de26a3dd07fc4d6a3bc9fe78fb1c6cc633caabb1dd088f220d077b4a3a0d534cb1d243959c5a08
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DCC_COMMS_LIB_ONLY=ON
        -DCC_NO_UNIT_TESTS=ON
)
vcpkg_install_cmake()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)