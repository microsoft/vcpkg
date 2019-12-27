vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO winsoft666/akali
    REF f24058a7c75ffcd794748edd7548f4b40cf78597
    SHA512 fa9a5fe54eddab283fd8ef9129867870c1dcaf84e3b2218fb55b1671131ec8f01cc18885346b34ee51c2060a85850389ad1a10f41ef7740e5b67bee351742177
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
	PREFER_NINJA
    OPTIONS
        -DBUILD_TESTS:BOOL=OFF
)

vcpkg_fail_port_install(ON_TARGET "x64-uwp")
vcpkg_fail_port_install(ON_TARGET "arm-uwp")
vcpkg_fail_port_install(ON_TARGET "arm64-windows")

vcpkg_install_cmake()

if(EXISTS ${CURRENT_PACKAGES_DIR}/lib/cmake/akali)
    vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/akali)
elseif(EXISTS ${CURRENT_PACKAGES_DIR}/share/akali)
    vcpkg_fixup_cmake_targets(CONFIG_PATH share/akali)
endif()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/akali RENAME copyright)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

vcpkg_copy_pdbs()