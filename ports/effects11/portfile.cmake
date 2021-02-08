vcpkg_check_linkage(ONLY_STATIC_LIBRARY ONLY_DYNAMIC_CRT)

vcpkg_fail_port_install(ON_TARGET "LINUX" "OSX" "UWP" "ANDROID" ON_ARCH "arm")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO microsoft/FX11
    REF feb2021
    SHA512 ccff9a8bbac137a0363e925201c0b64ac11770ec96b65b8c880714ee4850f158c6776c00da4d3f53552877dce1fe5ed16241a3986a1a8e1134b7f48829422dc6
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH cmake)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
