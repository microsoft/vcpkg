vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO winsoft666/ppxbase
    REF 289f55183a76d924cbba650124e17efb4d9a9d7c
    SHA512 57517cddb43ce0fad64aa4ce91e95174e2a1102bc17e548f02cfc9e9a3601ed14681be1cb214ed6afd8b69ce7cfb2964bd93d755d06e55d7da2e6ca6a9642aa2
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

if(EXISTS ${CURRENT_PACKAGES_DIR}/lib/cmake/ppxbase)
    vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/ppxbase)
elseif(EXISTS ${CURRENT_PACKAGES_DIR}/share/ppxbase)
    vcpkg_fixup_cmake_targets(CONFIG_PATH share/ppxbase)
endif()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/ppxbase RENAME copyright)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

vcpkg_copy_pdbs()