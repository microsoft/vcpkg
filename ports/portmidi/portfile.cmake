vcpkg_fail_port_install(ON_TARGET "UWP")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mixxxdj/portmidi
    REF 235.1
    SHA512 a2bbaa65d209060b156bba404daf8d3da7c42611b837e4fb854758c863024c64d63ea2f15227549ad73cd3916e7b3a259b61e8ec2b4a3a2e2355b874ee4a16ea
    HEAD_REF main
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/PortMidi TARGET_PATH share/PortMidi)

file(INSTALL ${SOURCE_PATH}/license.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
