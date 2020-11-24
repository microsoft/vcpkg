vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO  strukturag/libheif 
    REF 2e218ef40440e258b5da1e513f72c7f3b1611c7c #v1.9.1
    SHA512 78fc62813f088133dfc12799d8e1989580630e80865e33e43450ae4bba0d9ef03fe250dcc734f7905ea1d02dcb7ae77a9b461b25da27fcb2ef98562c69ab0b87 
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
