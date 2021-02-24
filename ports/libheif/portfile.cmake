vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO  strukturag/libheif 
    REF 667eeabb553ce73094eb29faea3f31fb8610fec2 #v1.10.0
    SHA512 937290310ec6dda8840262d4bad5e3628033fa2caa6e9cc4a0df7a372cacf38c9b55cf29d2cb7ea2183641e263298fc2e87167c1b0f04f8697023f123d78aa9d
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DWITH_EXAMPLES=OFF
)
vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/libheif/)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
