vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO seleznevae/libfort
    REF ccb892f77dc30c2ebc42916a3f862a965e8c097f # v0.4.1
    SHA512 0397e52985b56b6740d22533c48039bf1d61fb90795e97a6153e9360702d1e89b5353ba74de92005bbc874822766d157de21d175387ffd00d0a5294e531d2d8b
    HEAD_REF main
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DFORT_ENABLE_TESTING=OFF
        -DFORT_ENABLE_ASTYLE=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
