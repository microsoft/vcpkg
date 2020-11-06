#header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mathisloge/comms_champion
    REF v3.1.1
    SHA512 167838aec1d42ce60e373aaa1c3b3f0093735e54b80c12229624fa5617b713462609b46585dbe9a1637404e88bd051eda2e619d21bff60056693e79dd9e53878
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