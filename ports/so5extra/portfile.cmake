vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stiffstream/so5extra
    REF 20f4c83ecde1509fbaf337dcf40f2f49dcf2690d # v.1.4.1.1
    SHA512 a3df042b60afc4c57361b5b3c21f4b7c077f1b0ab7a4d33fda14cc915f10b22a42ef0acbb1c7c8b356ce31ee84f24391164120642faf96235549204c83b40294
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/dev/so_5_extra
    PREFER_NINJA
    OPTIONS
        -DSO5EXTRA_INSTALL=ON
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/so5extra)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib ${CURRENT_PACKAGES_DIR}/debug)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/so5extra RENAME copyright)

